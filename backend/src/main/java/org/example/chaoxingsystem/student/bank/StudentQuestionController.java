package org.example.chaoxingsystem.student.bank;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.example.chaoxingsystem.teacher.audit.QuestionAudit;
import org.example.chaoxingsystem.teacher.audit.QuestionAuditMapper;
import org.example.chaoxingsystem.teacher.bank.QuestionType;
import org.example.chaoxingsystem.teacher.bank.QuestionTypeMapper;
import org.example.chaoxingsystem.common.Subject;
import org.example.chaoxingsystem.common.SubjectService;
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
@RequestMapping("/api/student/questions")
public class StudentQuestionController {
  private final QuestionAuditMapper auditMapper;
  private final QuestionTypeMapper typeMapper;
  private final SubjectService subjectService;
  private final UserService userService;
  private final ObjectMapper objectMapper = new ObjectMapper();

  public StudentQuestionController(QuestionAuditMapper auditMapper, QuestionTypeMapper typeMapper, SubjectService subjectService, UserService userService) {
    this.auditMapper = auditMapper;
    this.typeMapper = typeMapper;
    this.subjectService = subjectService;
    this.userService = userService;
  }

  @PostMapping("/submit")
  @PreAuthorize("hasRole('STUDENT')")
  public ResponseEntity<ApiResponse<HashMap<String, Object>>> submit(Authentication auth, @RequestBody Map<String, Object> body) throws Exception {
    String typeCode = body.get("type") != null ? String.valueOf(body.get("type")) : null;
    String subject = body.get("subject") != null ? String.valueOf(body.get("subject")) : null;
    Integer difficulty = null;
    if (body.get("difficulty") != null) {
      try { difficulty = Integer.valueOf(String.valueOf(body.get("difficulty"))); } catch (Exception ignored) {}
    }
    String content = body.get("content") != null ? String.valueOf(body.get("content")) : null;
    Object optionsObj = body.get("options");
    Object answerObj = body.get("answer");
    String analysis = body.get("analysis") != null ? String.valueOf(body.get("analysis")) : null;

    if (typeCode == null || typeCode.isEmpty() || content == null || content.isEmpty() || answerObj == null) {
      return ResponseEntity.badRequest().body(ApiResponse.error(400, "参数不完整"));
    }

    QuestionType type = typeMapper.selectByCode(toServerTypeCode(typeCode));
    if (type == null || type.getIsActive() == null || type.getIsActive() == 0) {
      return ResponseEntity.badRequest().body(ApiResponse.error(400, "题型无效或未启用"));
    }

    Map<String, Object> contentJson = new HashMap<>();
    contentJson.put("stem", content);
    if (optionsObj instanceof List<?>) {
      contentJson.put("options", optionsObj);
    }
    if (analysis != null && !analysis.isEmpty()) {
      contentJson.put("analysis", analysis);
    }
    String contentText = objectMapper.writeValueAsString(contentJson);
    String answerText = String.valueOf(answerObj);

    Long subjectId = null;
    if (subject != null && !subject.trim().isEmpty()) {
      Subject s = null;
      String code = subject.trim().toLowerCase().replaceAll("\\s+", "");
      try { s = subjectService.getByCode(code); } catch (Exception ignored) {}
      if (s == null) {
        try {
          List<Subject> all = subjectService.listAll();
          for (Subject item : all) {
            String name = item.getName();
            String c = item.getCode();
            if (name != null && name.equalsIgnoreCase(subject.trim())) { s = item; break; }
            if (c != null && c.equalsIgnoreCase(subject.trim())) { s = item; break; }
          }
        } catch (Exception ignored) {}
      }
      if (s != null) subjectId = s.getId();
    }

    var me = userService.getByUsername(auth.getName());
    QuestionAudit qa = new QuestionAudit();
    qa.setSubmitterId(me.getId());
    qa.setTypeId(type.getTypeId());
    qa.setContent(contentText);
    qa.setAnswer(answerText);
    qa.setDifficulty(difficulty);
    qa.setSubjectId(subjectId);
    qa.setStatus(0);
    auditMapper.insert(qa);

    HashMap<String, Object> data = new HashMap<>();
    data.put("ok", true);
    return ResponseEntity.ok(ApiResponse.success("提交成功，等待审核", data));
  }

  private String toServerTypeCode(String ui) {
    if (ui == null) return "";
    return switch (ui) {
      case "single_choice" -> "SINGLE";
      case "multiple_choice" -> "MULTI";
      case "true_false" -> "TRUE_FALSE";
      case "fill_blank" -> "FILL";
      case "short_answer" -> "SHORT";
      case "programming" -> "PROGRAM";
      default -> ui;
    };
  }
}
