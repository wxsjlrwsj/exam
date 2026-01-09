package org.example.chaoxingsystem.common;

import org.example.chaoxingsystem.user.dto.ApiResponse;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.example.chaoxingsystem.user.TokenService.TokenData;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import org.example.chaoxingsystem.teacher.course.CourseService;

/** 科目管理接口 */
@RestController
@RequestMapping("/api")
public class SubjectController {
  private final SubjectService service;
  private final CourseService courseService;

  public SubjectController(SubjectService service, CourseService courseService) {
    this.service = service;
    this.courseService = courseService;
  }

  @GetMapping("/subjects")
  @PreAuthorize("hasAnyRole('TEACHER','ADMIN','STUDENT')")
  public ResponseEntity<ApiResponse<List<Subject>>> list() {
    Authentication auth = SecurityContextHolder.getContext().getAuthentication();
    if (auth != null && auth.getDetails() instanceof TokenData) {
      TokenData data = (TokenData) auth.getDetails();
      if ("teacher".equalsIgnoreCase(data.getUserType())) {
        List<Map<String, Object>> courses = courseService.listByTeacher(data.getId());
        List<Subject> list = new ArrayList<>();
        for (Map<String, Object> c : courses) {
          Subject s = new Subject();
          Object idObj = c.get("id");
          Long id = null;
          if (idObj instanceof Number) id = ((Number) idObj).longValue();
          else if (idObj instanceof String) try { id = Long.parseLong((String) idObj); } catch (Exception ignore) {}
          s.setId(id);
          s.setName(String.valueOf(c.getOrDefault("name", "")));
          Object desc = c.get("description");
          s.setDescription(desc != null ? String.valueOf(desc) : null);
          s.setCode(null);
          list.add(s);
        }
        if (list.isEmpty()) {
          List<Subject> all = service.listAll();
          return ResponseEntity.ok(ApiResponse.success("获取成功", all));
        }
        return ResponseEntity.ok(ApiResponse.success("获取成功", list));
      }
    }
    List<Subject> list = service.listAll();
    return ResponseEntity.ok(ApiResponse.success("获取成功", list));
  }

  @GetMapping("/subjects/{id}")
  @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
  public ResponseEntity<ApiResponse<Subject>> detail(@PathVariable("id") Long id) {
    Subject subject = service.getById(id);
    return ResponseEntity.ok(ApiResponse.success("获取成功", subject));
  }
}
