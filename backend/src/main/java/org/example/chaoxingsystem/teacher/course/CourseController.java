package org.example.chaoxingsystem.teacher.course;

import org.example.chaoxingsystem.config.ModuleCheck;
import org.example.chaoxingsystem.user.UserService;
import org.example.chaoxingsystem.user.dto.ApiResponse;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api")
@ModuleCheck(moduleCode = "tch_course")
public class CourseController {
  private final CourseService service;
  private final UserService userService;

  public CourseController(CourseService service, UserService userService) {
    this.service = service;
    this.userService = userService;
  }

  @GetMapping("/courses")
  @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
  public ResponseEntity<ApiResponse<List<Map<String, Object>>>> list(Authentication auth) {
    var me = userService.getByUsername(auth.getName());
    List<Map<String, Object>> data = service.listByTeacher(me.getId());
    return ResponseEntity.ok(ApiResponse.success("获取成功", data));
  }

  @GetMapping("/courses/{id}")
  @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
  public ResponseEntity<ApiResponse<Map<String, Object>>> detail(@PathVariable("id") Long id) {
    Map<String, Object> data = service.getDetail(id);
    return ResponseEntity.ok(ApiResponse.success("获取成功", data));
  }

  @PostMapping("/courses")
  @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
  public ResponseEntity<ApiResponse<Map<String, Object>>> create(Authentication auth, @RequestBody Map<String, Object> body) {
    var me = userService.getByUsername(auth.getName());
    String name = (String) body.get("name");
    String description = (String) body.get("description");
    Long id = service.create(me.getId(), name, description);
    Object teacherIdsObj = body.get("teacherIds");
    if (teacherIdsObj instanceof java.util.Collection<?> col) {
      for (Object o : col) {
        if (o instanceof Number) {
          service.addCourseTeacher(id, ((Number) o).longValue());
        } else if (o instanceof String s) {
          try { service.addCourseTeacher(id, Long.parseLong(s)); } catch (NumberFormatException ignore) {}
        }
      }
    } else if (teacherIdsObj instanceof Number n) {
      service.addCourseTeacher(id, n.longValue());
    } else if (teacherIdsObj instanceof String s) {
      try { service.addCourseTeacher(id, Long.parseLong(s)); } catch (NumberFormatException ignore) {}
    }
    HashMap<String, Object> data = new HashMap<>();
    data.put("id", id);
    return ResponseEntity.ok(ApiResponse.success("创建成功", data));
  }

  @PutMapping("/courses/{id}")
  @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
  public ResponseEntity<ApiResponse<Void>> update(@PathVariable("id") Long id, @RequestBody Map<String, Object> body) {
    String name = (String) body.get("name");
    String description = (String) body.get("description");
    service.update(id, name, description);
    return ResponseEntity.ok(ApiResponse.success("更新成功", null));
  }

  @DeleteMapping("/courses/{id}")
  @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
  public ResponseEntity<ApiResponse<Void>> delete(@PathVariable("id") Long id) {
    service.delete(id);
    return ResponseEntity.ok(ApiResponse.success("删除成功", null));
  }

  @GetMapping("/courses/{courseId}/teachers")
  @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
  public ResponseEntity<ApiResponse<List<Map<String, Object>>>> listCourseTeachers(@PathVariable("courseId") Long courseId) {
    List<Map<String, Object>> data = service.getCourseTeachers(courseId);
    return ResponseEntity.ok(ApiResponse.success("获取成功", data));
  }

  @PostMapping("/courses/{courseId}/teachers")
  @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
  public ResponseEntity<ApiResponse<Void>> addCourseTeacher(@PathVariable("courseId") Long courseId, @RequestBody Map<String, Object> body) {
    Long teacherId = body.get("teacherId") instanceof Number ? ((Number) body.get("teacherId")).longValue() : null;
    if (teacherId != null) {
      service.addCourseTeacher(courseId, teacherId);
    }
    return ResponseEntity.ok(ApiResponse.success("添加成功", null));
  }

  @DeleteMapping("/courses/{courseId}/teachers/{teacherId}")
  @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
  public ResponseEntity<ApiResponse<Void>> removeCourseTeacher(@PathVariable("courseId") Long courseId, @PathVariable("teacherId") Long teacherId) {
    service.removeCourseTeacher(courseId, teacherId);
    return ResponseEntity.ok(ApiResponse.success("移除成功", null));
  }
}
