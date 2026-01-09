package org.example.chaoxingsystem.common;

import org.example.chaoxingsystem.user.dto.ApiResponse;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/** 班级管理接口 */
@RestController
@RequestMapping("/api")
public class ClassController {
  private final ClassService service;

  public ClassController(ClassService service) {
    this.service = service;
  }

  @GetMapping("/classes")
  @PreAuthorize("hasAnyRole('TEACHER','ADMIN','STUDENT')")
  public ResponseEntity<ApiResponse<HashMap<String, Object>>> list(
    @RequestParam(value = "page", defaultValue = "1") int page,
    @RequestParam(value = "size", defaultValue = "20") int size,
    @RequestParam(value = "keyword", required = false) String keyword,
    @RequestParam(value = "all", defaultValue = "false") boolean all
  ) {
    HashMap<String, Object> data = new HashMap<>();
    
    if (all) {
      // 返回所有班级，不分页
      List<Map<String, Object>> list = service.listAll();
      data.put("list", list);
      data.put("total", list.size());
    } else {
      // 分页返回
      long total = service.count(keyword);
      List<Map<String, Object>> list = service.page(keyword, page, size);
      data.put("list", list);
      data.put("total", total);
    }
    
    return ResponseEntity.ok(ApiResponse.success("获取成功", data));
  }

  @GetMapping("/classes/{classId}/students")
  @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
  public ResponseEntity<ApiResponse<HashMap<String, Object>>> getStudents(
    @PathVariable("classId") Long classId
  ) {
    List<Map<String, Object>> list = service.getClassStudents(classId);
    HashMap<String, Object> data = new HashMap<>();
    data.put("list", list);
    data.put("total", list.size());
    return ResponseEntity.ok(ApiResponse.success("获取成功", data));
  }
}

