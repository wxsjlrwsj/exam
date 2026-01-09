package org.example.chaoxingsystem.teacher.exam;

import org.example.chaoxingsystem.config.ModuleCheck;
import org.example.chaoxingsystem.common.Subject;
import org.example.chaoxingsystem.common.SubjectMapper;
import org.example.chaoxingsystem.teacher.course.CourseService;
import org.example.chaoxingsystem.teacher.paper.Paper;
import org.example.chaoxingsystem.teacher.paper.PaperMapper;
import org.example.chaoxingsystem.user.User;
import org.example.chaoxingsystem.user.UserService;
import org.example.chaoxingsystem.user.dto.ApiResponse;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/** Exam management endpoints. */
@RestController
@RequestMapping("/api")
@ModuleCheck(moduleCode = "tch_exam")
public class ExamController {
  private final ExamService service;
  private final UserService userService;
  private final SubjectMapper subjectMapper;
  private final PaperMapper paperMapper;
  private final CourseService courseService;

  public ExamController(ExamService service, UserService userService, SubjectMapper subjectMapper, PaperMapper paperMapper, CourseService courseService) {
    this.service = service;
    this.userService = userService;
    this.subjectMapper = subjectMapper;
    this.paperMapper = paperMapper;
    this.courseService = courseService;
  }

  private boolean isTeacherUser(User me) {
    return me != null && me.getUserType() != null && "teacher".equalsIgnoreCase(me.getUserType());
  }

  private void assertCourseMemberIfTeacher(User me, String subject) {
    if (!isTeacherUser(me)) return;
    if (subject == null || subject.isBlank()) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "课程参数错误");
    }
    int cnt = subjectMapper.countByNameAndTeacherId(subject, me.getId());
    if (cnt <= 0) {
      throw new ResponseStatusException(HttpStatus.FORBIDDEN, "仅任课教师可查看");
    }
  }

  private void assertCourseCreatorIfTeacher(User me, String subject) {
    if (!isTeacherUser(me)) return;
    if (subject == null || subject.isBlank()) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "课程参数错误");
    }
    int cnt = subjectMapper.countByNameAndCreatorId(subject, me.getId());
    if (cnt <= 0) {
      throw new ResponseStatusException(HttpStatus.FORBIDDEN, "仅课程创建者可操作");
    }
  }

  @GetMapping("/exams")
  @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
  public ResponseEntity<ApiResponse<HashMap<String, Object>>> list(
    @RequestParam(value = "status", required = false) String status,
    @RequestParam(value = "subject", required = false) String subject,
    @RequestParam(value = "courseId", required = false) Long courseId,
    @RequestParam(value = "page", defaultValue = "1") int page,
    @RequestParam(value = "size", defaultValue = "10") int size,
    Authentication auth
  ) {
    String finalSubject = subject;
    if ((finalSubject == null || finalSubject.isBlank()) && courseId != null) {
      Subject s = subjectMapper.selectById(courseId);
      if (s != null && s.getName() != null && !s.getName().isBlank()) {
        finalSubject = s.getName();
      }
    }

    boolean needInMemoryPagination = status != null && !status.isBlank();

    List<Exam> exams;
    long total;
    var me = userService.getByUsername(auth.getName());
    boolean isTeacher = isTeacherUser(me);

    if (finalSubject != null && !finalSubject.isBlank()) {
      assertCourseMemberIfTeacher(me, finalSubject);
      if (needInMemoryPagination) {
        exams = service.pageByPaperSubject(finalSubject, 1, 10000);
        total = exams.size();
      } else {
        exams = service.pageByPaperSubject(finalSubject, page, size);
        total = service.countByPaperSubject(finalSubject);
      }
    } else if (isTeacher) {
      List<Map<String, Object>> courses = courseService.listByTeacher(me.getId());
      java.util.List<String> subjects = new java.util.ArrayList<>();
      for (Map<String, Object> c : courses) {
        Object nameObj = c.get("name");
        String name = nameObj != null ? String.valueOf(nameObj) : null;
        if (name != null && !name.isBlank()) {
          subjects.add(name);
        }
      }
      if (subjects.isEmpty()) {
        exams = List.of();
        total = 0;
      } else if (needInMemoryPagination) {
        exams = service.pageByPaperSubjects(subjects, 1, 10000);
        total = exams.size();
      } else {
        exams = service.pageByPaperSubjects(subjects, page, size);
        total = service.countByPaperSubjects(subjects);
      }
    } else {
      if (needInMemoryPagination) {
        exams = service.page(null, 1, 10000);
        total = exams.size();
      } else {
        exams = service.page(null, page, size);
        total = service.count(null);
      }
    }

    Map<Long, Paper> paperCache = new HashMap<>();
    for (Exam e : exams) {
      Long pid = e.getPaperId();
      if (pid == null || paperCache.containsKey(pid)) continue;
      paperCache.put(pid, paperMapper.selectById(pid));
    }

    List<Map<String, Object>> examList = exams.stream().map(exam -> {
      Map<String, Object> map = new HashMap<>();
      map.put("id", exam.getId());
      map.put("name", exam.getName());
      map.put("paperId", exam.getPaperId());
      map.put("startTime", exam.getStartTime());
      map.put("endTime", exam.getEndTime());
      map.put("duration", exam.getDuration());
      String calculatedStatus = service.calculateStatus(exam);
      map.put("status", calculatedStatus);
      Paper p = exam.getPaperId() != null ? paperCache.get(exam.getPaperId()) : null;
      if (p != null) {
        map.put("paperName", p.getName());
        map.put("subject", p.getSubject());
      }
      map.put("creatorId", exam.getCreatorId());
      map.put("createTime", exam.getCreateTime());
      return map;
    }).toList();

    List<Map<String, Object>> filteredList = examList;
    if (status != null && !status.isEmpty()) {
      String targetStatus = status.toLowerCase();
      filteredList = examList.stream()
        .filter(exam -> targetStatus.equals(exam.get("status")))
        .toList();
    }

    if (needInMemoryPagination) {
      total = filteredList.size();
      int offset = (Math.max(page, 1) - 1) * Math.max(size, 1);
      int limit = Math.max(size, 1);
      filteredList = filteredList.stream().skip(offset).limit(limit).toList();
    }

    HashMap<String, Object> data = new HashMap<>();
    data.put("list", filteredList);
    data.put("total", total);
    return ResponseEntity.ok(ApiResponse.success("获取成功", data));
  }

  @PostMapping("/exams")
  @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
  public ResponseEntity<ApiResponse<HashMap<String, Object>>> create(Authentication auth, @RequestBody Map<String, Object> body) {
    var me = userService.getByUsername(auth.getName());
    String name = (String) body.get("name");
    Long paperId = body.get("paperId") instanceof Number ? ((Number) body.get("paperId")).longValue() : null;
    if (paperId != null) {
      Paper p = paperMapper.selectById(paperId);
      if (p != null) {
        assertCourseCreatorIfTeacher(me, p.getSubject());
      }
    }
    String startTime = (String) body.get("startTime");
    Integer duration = body.get("duration") instanceof Number ? ((Number) body.get("duration")).intValue() : null;
    List<Long> classIds = toLongList(body.get("classIds"));
    if (classIds.isEmpty()) {
      classIds = toLongList(body.get("classes"));
    }
    List<Long> studentIds = toLongList(body.get("studentIds"));
    Long id = service.create(me.getId(), name, paperId, startTime, duration, classIds, studentIds);
    HashMap<String, Object> data = new HashMap<>();
    data.put("id", id);
    return ResponseEntity.ok(ApiResponse.success("Created successfully", data));
  }

  private List<Long> toLongList(Object value) {
    if (!(value instanceof List<?> list)) {
      return List.of();
    }
    List<Long> result = new java.util.ArrayList<>();
    for (Object item : list) {
      if (item instanceof Number n) {
        result.add(n.longValue());
      } else if (item instanceof String s && !s.isBlank()) {
        try {
          result.add(Long.parseLong(s));
        } catch (NumberFormatException ignored) {
          // Ignore non-numeric values.
        }
      }
    }
    return result;
  }

  @GetMapping("/exams/{id}")
  @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
  public ResponseEntity<ApiResponse<Map<String, Object>>> detail(@PathVariable("id") Long id, Authentication auth) {
    var me = userService.getByUsername(auth.getName());
    Exam e = service.getById(id);
    if (e != null && e.getPaperId() != null) {
      Paper p = paperMapper.selectById(e.getPaperId());
      if (p != null) {
        assertCourseMemberIfTeacher(me, p.getSubject());
      }
    }
    Map<String, Object> data = service.getDetail(id);
    return ResponseEntity.ok(ApiResponse.success("Fetched successfully", data));
  }

  @DeleteMapping("/exams/{id}")
  @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
  public ResponseEntity<ApiResponse<Void>> delete(@PathVariable("id") Long id, Authentication auth) {
    var me = userService.getByUsername(auth.getName());
    Exam e = service.getById(id);
    if (e != null && e.getPaperId() != null) {
      Paper p = paperMapper.selectById(e.getPaperId());
      if (p != null) {
        assertCourseCreatorIfTeacher(me, p.getSubject());
      }
    }
    service.delete(id);
    return ResponseEntity.ok(ApiResponse.success("Deleted successfully", null));
  }

  @PutMapping("/exams/{id}")
  @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
  public ResponseEntity<ApiResponse<Void>> update(@PathVariable("id") Long id, @RequestBody Map<String, Object> body, Authentication auth) {
    var me = userService.getByUsername(auth.getName());
    Exam e = service.getById(id);
    if (e != null && e.getPaperId() != null) {
      Paper p = paperMapper.selectById(e.getPaperId());
      if (p != null) {
        assertCourseCreatorIfTeacher(me, p.getSubject());
      }
    }
    String name = (String) body.get("name");
    String startTime = (String) body.get("startTime");
    Integer duration = body.get("duration") instanceof Number ? ((Number) body.get("duration")).intValue() : null;
    String description = (String) body.get("description");
    service.update(id, name, startTime, duration, description);
    return ResponseEntity.ok(ApiResponse.success("Updated successfully", null));
  }

  @PutMapping("/exams/{id}/allow-review")
  @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
  public ResponseEntity<ApiResponse<Void>> setAllowReview(@PathVariable("id") Long id, @RequestBody Map<String, Object> body, Authentication auth) {
    var me = userService.getByUsername(auth.getName());
    Exam e = service.getById(id);
    if (e != null && e.getPaperId() != null) {
      Paper p = paperMapper.selectById(e.getPaperId());
      if (p != null) {
        assertCourseCreatorIfTeacher(me, p.getSubject());
      }
    }
    Integer allowReview = null;
    Object v = body != null ? body.get("allowReview") : null;
    if (v instanceof Boolean b) {
      allowReview = b ? 1 : 0;
    } else if (v instanceof Number n) {
      allowReview = n.intValue();
    } else if (v instanceof String s && !s.isBlank()) {
      if ("true".equalsIgnoreCase(s) || "1".equals(s)) allowReview = 1;
      else if ("false".equalsIgnoreCase(s) || "0".equals(s)) allowReview = 0;
    }
    service.setAllowReview(id, allowReview);
    return ResponseEntity.ok(ApiResponse.success("Updated successfully", null));
  }

  @GetMapping("/monitor/{examId}")
  @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
  public ResponseEntity<ApiResponse<Map<String, Object>>> monitor(@PathVariable("examId") Long examId, Authentication auth) {
    var me = userService.getByUsername(auth.getName());
    Exam e = service.getById(examId);
    if (e != null && e.getPaperId() != null) {
      Paper p = paperMapper.selectById(e.getPaperId());
      if (p != null) {
        assertCourseCreatorIfTeacher(me, p.getSubject());
      }
    }
    Map<String, Object> data = service.getMonitorData(examId);
    return ResponseEntity.ok(ApiResponse.success("Fetched successfully", data));
  }

  @PostMapping("/monitor/{examId}/warning")
  @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
  public ResponseEntity<ApiResponse<Map<String, Object>>> sendWarning(
    Authentication auth,
    @PathVariable("examId") Long examId,
    @RequestBody Map<String, Object> body
  ) {
    var me = userService.getByUsername(auth.getName());
    Exam e = service.getById(examId);
    if (e != null && e.getPaperId() != null) {
      Paper p = paperMapper.selectById(e.getPaperId());
      if (p != null) {
        assertCourseCreatorIfTeacher(me, p.getSubject());
      }
    }
    Long studentId = body.get("studentId") instanceof Number ? ((Number) body.get("studentId")).longValue() : null;
    String message = (String) body.get("message");
    String type = (String) body.get("type");
    Map<String, Object> data = service.sendWarning(examId, studentId, message, type, me.getId());
    return ResponseEntity.ok(ApiResponse.success("Warning sent", data));
  }

  @PostMapping("/monitor/{examId}/broadcast")
  @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
  public ResponseEntity<ApiResponse<Map<String, Object>>> broadcast(
    Authentication auth,
    @PathVariable("examId") Long examId,
    @RequestBody Map<String, Object> body
  ) {
    var me = userService.getByUsername(auth.getName());
    Exam e = service.getById(examId);
    if (e != null && e.getPaperId() != null) {
      Paper p = paperMapper.selectById(e.getPaperId());
      if (p != null) {
        assertCourseCreatorIfTeacher(me, p.getSubject());
      }
    }
    String message = (String) body.get("message");
    String type = (String) body.get("type");
    Map<String, Object> data = service.broadcast(examId, me.getId(), message, type);
    return ResponseEntity.ok(ApiResponse.success("Broadcast sent", data));
  }

  @PostMapping("/monitor/{examId}/force-submit")
  @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
  public ResponseEntity<ApiResponse<Map<String, Object>>> forceSubmit(
    @PathVariable("examId") Long examId,
    @RequestBody Map<String, Object> body,
    Authentication auth
  ) {
    var me = userService.getByUsername(auth.getName());
    Exam e = service.getById(examId);
    if (e != null && e.getPaperId() != null) {
      Paper p = paperMapper.selectById(e.getPaperId());
      if (p != null) {
        assertCourseCreatorIfTeacher(me, p.getSubject());
      }
    }
    @SuppressWarnings("unchecked")
    List<Number> studentIds = (List<Number>) body.get("studentIds");
    String reason = (String) body.get("reason");
    Map<String, Object> data = service.forceSubmit(examId, studentIds, reason);
    return ResponseEntity.ok(ApiResponse.success("Force submit success", data));
  }
}
