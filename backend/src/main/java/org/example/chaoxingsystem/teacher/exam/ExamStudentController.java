package org.example.chaoxingsystem.teacher.exam;

import org.example.chaoxingsystem.config.ModuleCheck;
import org.example.chaoxingsystem.user.dto.ApiResponse;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/** 考生管理接口 */
@RestController
@RequestMapping("/api")
@ModuleCheck(moduleCode = "tch_exam")
public class ExamStudentController {
  private final ExamStudentService service;

  public ExamStudentController(ExamStudentService service) {
    this.service = service;
  }

  @GetMapping("/exams/{examId}/students")
  @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
  public ResponseEntity<ApiResponse<HashMap<String, Object>>> list(
    @PathVariable("examId") Long examId,
    @RequestParam(value = "page", defaultValue = "1") int page,
    @RequestParam(value = "size", defaultValue = "10") int size,
    @RequestParam(value = "keyword", required = false) String keyword
  ) {
    long total = service.count(examId, keyword);
    List<Map<String, Object>> list = service.page(examId, keyword, page, size);
    HashMap<String, Object> data = new HashMap<>();
    data.put("list", list);
    data.put("total", total);
    return ResponseEntity.ok(ApiResponse.success("获取成功", data));
  }

  @PostMapping("/exams/{examId}/students")
  @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
  public ResponseEntity<ApiResponse<Void>> add(
    @PathVariable("examId") Long examId,
    @RequestBody Map<String, Object> body
  ) {
    @SuppressWarnings("unchecked")
    List<Number> studentIds = (List<Number>) body.get("studentIds");
    @SuppressWarnings("unchecked")
    List<Number> classIds = (List<Number>) body.get("classIds");
    
    List<Long> sids = studentIds != null ? studentIds.stream().map(Number::longValue).toList() : null;
    List<Long> cids = classIds != null ? classIds.stream().map(Number::longValue).toList() : null;
    
    service.addStudents(examId, sids, cids);
    return ResponseEntity.ok(ApiResponse.success("添加成功", null));
  }

  @DeleteMapping("/exams/{examId}/students/{studentId}")
  @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
  public ResponseEntity<ApiResponse<Void>> remove(
    @PathVariable("examId") Long examId,
    @PathVariable("studentId") Long studentId
  ) {
    service.removeStudent(examId, studentId);
    return ResponseEntity.ok(ApiResponse.success("移除成功", null));
  }

  @PostMapping("/exams/{examId}/students/batch-delete")
  @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
  public ResponseEntity<ApiResponse<Void>> batchRemove(
    @PathVariable("examId") Long examId,
    @RequestBody Map<String, Object> body
  ) {
    @SuppressWarnings("unchecked")
    List<Number> studentIds = (List<Number>) body.get("studentIds");
    List<Long> sids = studentIds.stream().map(Number::longValue).toList();
    
    service.batchRemove(examId, sids);
    return ResponseEntity.ok(ApiResponse.success("批量移除成功", null));
  }
}

