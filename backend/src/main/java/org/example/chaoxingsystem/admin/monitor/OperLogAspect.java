package org.example.chaoxingsystem.admin.monitor;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

import jakarta.servlet.http.HttpServletRequest;

@Aspect
@Component
public class OperLogAspect {
  private final OperLogMapper mapper;
  private final HttpServletRequest request;
  private final ObjectMapper objectMapper = new ObjectMapper();

  public OperLogAspect(OperLogMapper mapper, HttpServletRequest request) {
    this.mapper = mapper;
    this.request = request;
  }

  @Around("execution(* org.example.chaoxingsystem..*Controller.*(..))")
  public Object record(ProceedingJoinPoint pjp) throws Throwable {
    long start = System.currentTimeMillis();
    Integer status = 0;
    String errorMsg = null;
    Object result = null;
    try {
      result = pjp.proceed();
      return result;
    } catch (Throwable ex) {
      status = 1;
      errorMsg = ex.getMessage();
      throw ex;
    } finally {
      OperLog log = new OperLog();
      String uri = request != null ? request.getRequestURI() : "";
      String method = request != null ? request.getMethod() : "";
      log.setTitle(resolveTitle(uri));
      log.setBusinessType(resolveBusinessType(method));
      log.setMethod(pjp.getSignature().toShortString());
      log.setRequestMethod(method);
      Authentication auth = SecurityContextHolder.getContext().getAuthentication();
      log.setOperName(auth != null ? auth.getName() : "");
      log.setOperUrl(uri);
      log.setOperIp(resolveIp());
      log.setOperLocation("");
      log.setOperParam(stringifyArgs(pjp.getArgs()));
      log.setJsonResult(stringifyResult(result));
      log.setStatus(status);
      log.setErrorMsg(errorMsg);
      log.setCostTime(System.currentTimeMillis() - start);
      try {
        mapper.insert(log);
      } catch (Exception ignored) {}
    }
  }

  private String resolveTitle(String uri) {
    if (uri == null || uri.isEmpty()) return "";
    String[] parts = uri.split("/");
    int idx = 2;
    if (parts.length > idx) {
      String seg = parts[idx];
      switch (seg) {
        case "system": return "系统模块";
        case "org": return "组织机构";
        case "monitor": return "系统日志";
        case "permission": return "权限管理";
        case "teacher": return "教师端";
        case "student": return "学生端";
        default: return seg;
      }
    }
    return uri;
  }

  private Integer resolveBusinessType(String method) {
    if (method == null) return 0;
    switch (method) {
      case "POST": return 1;
      case "PUT": return 2;
      case "DELETE": return 3;
      default: return 0;
    }
  }

  private String stringifyArgs(Object[] args) {
    try {
      String s = objectMapper.writeValueAsString(args);
      return truncate(s, 4000);
    } catch (Exception e) {
      return "";
    }
  }

  private String stringifyResult(Object result) {
    try {
      String s = objectMapper.writeValueAsString(result);
      return truncate(s, 4000);
    } catch (Exception e) {
      return "";
    }
  }

  private String resolveIp() {
    if (request == null) return "";
    String ip = request.getHeader("X-Forwarded-For");
    if (ip != null && !ip.isEmpty()) {
      int comma = ip.indexOf(',');
      return comma > 0 ? ip.substring(0, comma).trim() : ip.trim();
    }
    ip = request.getHeader("X-Real-IP");
    if (ip != null && !ip.isEmpty()) return ip.trim();
    return request.getRemoteAddr();
  }

  private String truncate(String s, int max) {
    if (s == null) return "";
    if (s.length() <= max) return s;
    return s.substring(0, max);
  }
}
