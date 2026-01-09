package org.example.chaoxingsystem.teacher.paper;

import jakarta.validation.Valid;
import org.example.chaoxingsystem.config.ModuleCheck;
import org.example.chaoxingsystem.common.Subject;
import org.example.chaoxingsystem.common.SubjectMapper;
import org.example.chaoxingsystem.teacher.course.CourseService;
import org.example.chaoxingsystem.teacher.paper.dto.CreatePaperRequest;
import org.example.chaoxingsystem.user.User;
import org.example.chaoxingsystem.user.UserService;
import org.example.chaoxingsystem.user.dto.ApiResponse;
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/** 试卷管理接口：列表、创建、智能组卷 */
@RestController
@RequestMapping("/api")
@ModuleCheck(moduleCode = "tch_paper")
public class PaperController {
  private final PaperService service;
  private final UserService userService;
  private final CourseService courseService;
  private final SubjectMapper subjectMapper;

  public PaperController(PaperService service, UserService userService, CourseService courseService, SubjectMapper subjectMapper) {
    this.service = service;
    this.userService = userService;
    this.courseService = courseService;
    this.subjectMapper = subjectMapper;
  }

  private boolean isTeacherUser(User me) {
    return me != null && me.getUserType() != null && "teacher".equalsIgnoreCase(me.getUserType());
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

  @GetMapping("/papers")
  @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
  public ResponseEntity<ApiResponse<HashMap<String, Object>>> list(
    @RequestParam(value = "page", defaultValue = "1") int page,
    @RequestParam(value = "size", defaultValue = "10") int size,
    @RequestParam(value = "subject", required = false) String subject,
    @RequestParam(value = "courseId", required = false) Long courseId,
    Authentication auth
  ) {
    String finalSubject = subject;
    if ((finalSubject == null || finalSubject.isBlank()) && courseId != null) {
      Subject s = subjectMapper.selectById(courseId);
      if (s != null && s.getName() != null && !s.getName().isBlank()) {
        finalSubject = s.getName();
      }
    }

    long total;
    List<Paper> list;

    var me = userService.getByUsername(auth.getName());
    boolean isTeacher = isTeacherUser(me);

    if (finalSubject != null && !finalSubject.isBlank()) {
      assertCourseCreatorIfTeacher(me, finalSubject);
      total = service.count(finalSubject);
      list = service.page(finalSubject, page, size);
    } else if (isTeacher) {
      List<Map<String, Object>> courses = courseService.listByTeacher(me.getId());
      List<String> subjects = new ArrayList<>();
      for (Map<String, Object> c : courses) {
        Object isCreatorObj = c.get("isCreator");
        boolean isCreator = false;
        if (isCreatorObj instanceof Number n) {
          isCreator = n.intValue() != 0;
        } else if (isCreatorObj instanceof Boolean b) {
          isCreator = b;
        } else if (isCreatorObj != null) {
          isCreator = "1".equals(String.valueOf(isCreatorObj)) || "true".equalsIgnoreCase(String.valueOf(isCreatorObj));
        }
        if (!isCreator) {
          continue;
        }
        Object nameObj = c.get("name");
        String name = nameObj != null ? String.valueOf(nameObj) : null;
        if (name != null && !name.isBlank()) {
          subjects.add(name);
        }
      }
      if (subjects.isEmpty()) {
        total = 0;
        list = List.of();
      } else {
        total = service.countBySubjects(subjects);
        list = service.pageBySubjects(subjects, page, size);
      }
    } else {
      total = service.count(null);
      list = service.page(null, page, size);
    }
    
    // 将 Paper 对象转换为 Map，并将 status 从数字转换为字符串
    List<Map<String, Object>> paperList = list.stream().map(paper -> {
      Map<String, Object> map = new HashMap<>();
      map.put("id", paper.getId());
      map.put("name", paper.getName());
      map.put("subject", paper.getSubject());
      map.put("totalScore", paper.getTotalScore());
      map.put("passScore", paper.getPassScore());
      map.put("questionCount", paper.getQuestionCount());
      // 将 status 从数字转换为字符串：1 = used, 0 = unused
      map.put("status", paper.getStatus() != null && paper.getStatus() == 1 ? "used" : "unused");
      map.put("creatorId", paper.getCreatorId());
      map.put("createTime", paper.getCreateTime());
      return map;
    }).toList();
    
    HashMap<String, Object> data = new HashMap<>();
    data.put("list", paperList);
    data.put("total", total);
    return ResponseEntity.ok(ApiResponse.success("获取成功", data));
  }

  @PostMapping("/papers")
  @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
  public ResponseEntity<ApiResponse<HashMap<String, Object>>> create(Authentication auth, @Valid @RequestBody CreatePaperRequest req) {
    var me = userService.getByUsername(auth.getName());
    assertCourseCreatorIfTeacher(me, req.getSubject());
    List<PaperService.QuestionItem> items = req.getQuestions().stream().map(q -> new PaperService.QuestionItem(q.getId(), q.getScore())).toList();
    Long id = service.create(me.getId(), req.getName(), req.getSubject(), items, req.getPassScore());
    HashMap<String, Object> data = new HashMap<>();
    data.put("id", id);
    return ResponseEntity.ok(ApiResponse.success("创建成功", data));
  }

  @PostMapping("/papers/auto-generate")
  @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
  public ResponseEntity<ApiResponse<HashMap<String, Object>>> autoGenerate(Authentication auth, @RequestBody Map<String, Object> body) {
    var me = userService.getByUsername(auth.getName());
    String subject = (String) body.get("subject");
    assertCourseCreatorIfTeacher(me, subject);
    Integer difficulty = body.get("difficulty") instanceof Number ? ((Number) body.get("difficulty")).intValue() : null;
    Integer totalScore = body.get("totalScore") instanceof Number ? ((Number) body.get("totalScore")).intValue() : null;
    @SuppressWarnings("unchecked")
    Map<String, Integer> typeDistribution = (Map<String, Integer>) body.get("typeDistribution");
    @SuppressWarnings("unchecked")
    Map<String, Map<String, Integer>> difficultyDistribution =
      (Map<String, Map<String, Integer>>) body.get("difficultyDistribution");
    Long id = service.autoGenerate(me.getId(), subject, difficulty, totalScore, typeDistribution, difficultyDistribution);
    HashMap<String, Object> data = new HashMap<>();
    data.put("id", id);
    return ResponseEntity.ok(ApiResponse.success("智能组卷成功", data));
  }

  @GetMapping("/papers/{id}")
  @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
  public ResponseEntity<ApiResponse<Map<String, Object>>> detail(@PathVariable("id") Long id, Authentication auth) {
    var me = userService.getByUsername(auth.getName());
    Paper p = service.getById(id);
    if (p != null) {
      assertCourseCreatorIfTeacher(me, p.getSubject());
    }
    Map<String, Object> data = service.getDetail(id);
    return ResponseEntity.ok(ApiResponse.success("获取成功", data));
  }

  @DeleteMapping("/papers/{id}")
  @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
  public ResponseEntity<ApiResponse<Void>> delete(@PathVariable("id") Long id, Authentication auth) {
    var me = userService.getByUsername(auth.getName());
    Paper p = service.getById(id);
    if (p != null) {
      assertCourseCreatorIfTeacher(me, p.getSubject());
    }
    service.delete(id);
    return ResponseEntity.ok(ApiResponse.success("删除成功", null));
  }

  @PutMapping("/papers/{id}")
  @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
  public ResponseEntity<ApiResponse<Void>> update(@PathVariable("id") Long id, @Valid @RequestBody CreatePaperRequest req, Authentication auth) {
    var me = userService.getByUsername(auth.getName());
    Paper p = service.getById(id);
    if (p != null) {
      assertCourseCreatorIfTeacher(me, p.getSubject());
    }
    assertCourseCreatorIfTeacher(me, req.getSubject());
    List<PaperService.QuestionItem> items = req.getQuestions().stream()
      .map(q -> new PaperService.QuestionItem(q.getId(), q.getScore())).toList();
    service.update(id, req.getName(), req.getSubject(), items, req.getPassScore());
    return ResponseEntity.ok(ApiResponse.success("更新成功", null));
  }

  @PutMapping("/papers/{id}/publish")
  @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
  public ResponseEntity<ApiResponse<Map<String, Object>>> publish(@PathVariable("id") Long id, Authentication auth) {
    var me = userService.getByUsername(auth.getName());
    Paper p = service.getById(id);
    if (p != null) {
      assertCourseCreatorIfTeacher(me, p.getSubject());
    }
    service.publish(id);
    Map<String, Object> data = new HashMap<>();
    data.put("id", id);
    data.put("status", "published");
    return ResponseEntity.ok(ApiResponse.success("试卷发布成功", data));
  }

  @PutMapping("/papers/{id}/unpublish")
  @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
  public ResponseEntity<ApiResponse<Map<String, Object>>> unpublish(@PathVariable("id") Long id, Authentication auth) {
    var me = userService.getByUsername(auth.getName());
    Paper p = service.getById(id);
    if (p != null) {
      assertCourseCreatorIfTeacher(me, p.getSubject());
    }
    service.unpublish(id);
    Map<String, Object> data = new HashMap<>();
    data.put("id", id);
    data.put("status", "draft");
    return ResponseEntity.ok(ApiResponse.success("已取消发布", data));
  }
}
