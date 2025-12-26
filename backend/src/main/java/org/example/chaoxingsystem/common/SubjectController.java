package org.example.chaoxingsystem.common;

import org.example.chaoxingsystem.user.dto.ApiResponse;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/** 科目管理接口 */
@RestController
@RequestMapping("/api")
public class SubjectController {
  private final SubjectService service;

  public SubjectController(SubjectService service) {
    this.service = service;
  }

  @GetMapping("/subjects")
  @PreAuthorize("hasAnyRole('TEACHER','ADMIN','STUDENT')")
  public ResponseEntity<ApiResponse<List<Subject>>> list() {
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

