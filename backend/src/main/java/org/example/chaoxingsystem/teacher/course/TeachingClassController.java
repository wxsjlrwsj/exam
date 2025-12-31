package org.example.chaoxingsystem.teacher.course;

import org.example.chaoxingsystem.config.ModuleCheck;
import org.example.chaoxingsystem.user.dto.ApiResponse;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api")
@ModuleCheck(moduleCode = "tch_course")
public class TeachingClassController {
  private final TeachingClassService service;

  public TeachingClassController(TeachingClassService service) {
    this.service = service;
  }

  @GetMapping("/courses/{courseId}/classes")
  @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
  public ResponseEntity<ApiResponse<List<Map<String, Object>>>> listByCourse(@PathVariable("courseId") Long courseId) {
    List<Map<String, Object>> data = service.listByCourse(courseId);
    return ResponseEntity.ok(ApiResponse.success("获取成功", data));
  }

  @GetMapping("/teaching-classes/{id}")
  @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
  public ResponseEntity<ApiResponse<Map<String, Object>>> detail(@PathVariable("id") Long id) {
    Map<String, Object> data = service.getDetail(id);
    return ResponseEntity.ok(ApiResponse.success("获取成功", data));
  }

  @PostMapping("/courses/{courseId}/classes")
  @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
  public ResponseEntity<ApiResponse<Map<String, Object>>> create(@PathVariable("courseId") Long courseId, @RequestBody Map<String, Object> body) {
    String name = (String) body.get("name");
    Long assignedTeacherId = body.get("assignedTeacherId") instanceof Number ? ((Number) body.get("assignedTeacherId")).longValue() : null;
    Long id = service.create(courseId, name, assignedTeacherId);
    HashMap<String, Object> data = new HashMap<>();
    data.put("id", id);
    return ResponseEntity.ok(ApiResponse.success("创建成功", data));
  }

  @PutMapping("/teaching-classes/{id}")
  @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
  public ResponseEntity<ApiResponse<Void>> update(@PathVariable("id") Long id, @RequestBody Map<String, Object> body) {
    String name = (String) body.get("name");
    Long assignedTeacherId = body.get("assignedTeacherId") instanceof Number ? ((Number) body.get("assignedTeacherId")).longValue() : null;
    service.update(id, name, assignedTeacherId);
    return ResponseEntity.ok(ApiResponse.success("更新成功", null));
  }

  @DeleteMapping("/teaching-classes/{id}")
  @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
  public ResponseEntity<ApiResponse<Void>> delete(@PathVariable("id") Long id) {
    service.delete(id);
    return ResponseEntity.ok(ApiResponse.success("删除成功", null));
  }

  @GetMapping("/teaching-classes/{classId}/students")
  @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
  public ResponseEntity<ApiResponse<List<Map<String, Object>>>> listStudents(@PathVariable("classId") Long classId) {
    List<Map<String, Object>> data = service.listClassStudents(classId);
    return ResponseEntity.ok(ApiResponse.success("获取成功", data));
  }

  @PostMapping("/teaching-classes/{classId}/students")
  @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
  public ResponseEntity<ApiResponse<Void>> addStudent(@PathVariable("classId") Long classId, @RequestBody Map<String, Object> body) {
    Long studentId = body.get("studentId") instanceof Number ? ((Number) body.get("studentId")).longValue() : null;
    if (studentId != null) {
      service.addStudent(classId, studentId);
    }
    return ResponseEntity.ok(ApiResponse.success("添加成功", null));
  }

  @DeleteMapping("/teaching-classes/{classId}/students/{studentId}")
  @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
  public ResponseEntity<ApiResponse<Void>> removeStudent(@PathVariable("classId") Long classId, @PathVariable("studentId") Long studentId) {
    service.removeStudent(classId, studentId);
    return ResponseEntity.ok(ApiResponse.success("移除成功", null));
  }

  @PostMapping("/teaching-classes/{classId}/students/batch")
  @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
  public ResponseEntity<ApiResponse<Map<String, Object>>> addStudentsFromAdminClass(@PathVariable("classId") Long classId, @RequestBody Map<String, Object> body) {
    Object idsObj = body.get("adminClassIds");
    java.util.List<Long> adminClassIds = new java.util.ArrayList<>();
    if (idsObj instanceof java.util.Collection<?> col) {
      for (Object o : col) {
        if (o instanceof Number) {
          adminClassIds.add(((Number) o).longValue());
        } else if (o instanceof String s) {
          try { adminClassIds.add(Long.parseLong(s)); } catch (NumberFormatException ignore) {}
        }
      }
    } else if (idsObj instanceof Number n) {
      adminClassIds.add(n.longValue());
    } else if (idsObj instanceof String s) {
      try { adminClassIds.add(Long.parseLong(s)); } catch (NumberFormatException ignore) {}
    }

    int added = service.addStudentsFromAdminClass(classId, adminClassIds);
    HashMap<String, Object> data = new HashMap<>();
    data.put("added", added);
    return ResponseEntity.ok(ApiResponse.success("批量添加成功", data));
  }

  @PutMapping("/teaching-classes/{classId}/teacher")
  @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
  public ResponseEntity<ApiResponse<Void>> assignTeacher(@PathVariable("classId") Long classId, @RequestBody Map<String, Object> body) {
    Long teacherId = body.get("teacherId") instanceof Number ? ((Number) body.get("teacherId")).longValue() : null;
    if (teacherId != null) {
      service.assignTeacher(classId, teacherId);
    }
    return ResponseEntity.ok(ApiResponse.success("分配成功", null));
  }
}
