package org.example.chaoxingsystem.teacher.bank;

import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.validation.Valid;
import org.example.chaoxingsystem.config.ModuleCheck;
import org.example.chaoxingsystem.teacher.bank.dto.CreateQuestionRequest;
import org.example.chaoxingsystem.teacher.bank.dto.OptionItem;
import org.example.chaoxingsystem.teacher.bank.dto.UpdateQuestionRequest;
import org.example.chaoxingsystem.user.UserService;
import org.example.chaoxingsystem.user.dto.ApiResponse;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.HashMap;
import java.util.List;

/** 题库管理接口：分页查询、创建/更新/删除、批量导入 */
@RestController
@RequestMapping("/api")
@ModuleCheck(moduleCode = "tch_bank")
public class QuestionBankController {
  private final QuestionService service;
  private final QuestionImportService importService;
  private final UserService userService;
  private final ObjectMapper objectMapper = new ObjectMapper();

  public QuestionBankController(QuestionService service, QuestionImportService importService, UserService userService) {
    this.service = service;
    this.importService = importService;
    this.userService = userService;
  }

  @GetMapping("/questions")
  @PreAuthorize("hasAnyRole('TEACHER','ADMIN','STUDENT')")
  public ResponseEntity<ApiResponse<HashMap<String, Object>>> list(
    @RequestParam(value = "page", defaultValue = "1") int page,
    @RequestParam(value = "size", defaultValue = "10") int size,
    @RequestParam(value = "typeCode", required = false) String typeCode,
    @RequestParam(value = "keyword", required = false) String keyword,
    @RequestParam(value = "difficulty", required = false) Integer difficulty,
    @RequestParam(value = "subject", required = false) String subject
  ) {
    long total = service.count(typeCode, keyword, difficulty, subject);
    List<Question> list = service.page(typeCode, keyword, difficulty, subject, page, size);
    HashMap<String, Object> data = new HashMap<>();
    data.put("list", list);
    data.put("total", total);
    return ResponseEntity.ok(ApiResponse.success("获取成功", data));
  }

  @PostMapping("/questions")
  @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
  public ResponseEntity<ApiResponse<HashMap<String, Object>>> create(Authentication auth, @Valid @RequestBody CreateQuestionRequest req) throws Exception {
    var me = userService.getByUsername(auth.getName());
    String optionsJson = req.getOptions() != null ? objectMapper.writeValueAsString(req.getOptions()) : null;
    String answerJson = objectMapper.writeValueAsString(req.getAnswer());
    String fileId = (req.getUseFile() != null && !req.getUseFile()) ? null : req.getFileId();
    Long id = service.create(me.getId(), req.getTypeCode(), req.getContent(), optionsJson, answerJson, req.getDifficulty(), req.getSubject(), req.getKnowledgePoints(), fileId);
    HashMap<String, Object> data = new HashMap<>();
    data.put("id", id);
    return ResponseEntity.ok(ApiResponse.success("创建成功", data));
  }

  @PutMapping("/questions/{id}")
  @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
  public ResponseEntity<ApiResponse<Void>> update(@PathVariable("id") Long id, @Valid @RequestBody UpdateQuestionRequest req) throws Exception {
    QuestionService.UpdateCommand cmd = new QuestionService.UpdateCommand();
    cmd.id = id;
    cmd.typeCode = req.getTypeCode();
    cmd.content = req.getContent();
    cmd.optionsJson = req.getOptions() != null ? objectMapper.writeValueAsString(req.getOptions()) : null;
    cmd.answerJson = req.getAnswer() != null ? objectMapper.writeValueAsString(req.getAnswer()) : null;
    cmd.analysis = req.getAnalysis();
    cmd.difficulty = req.getDifficulty();
    cmd.subject = req.getSubject();
    cmd.knowledgePoints = req.getKnowledgePoints();
    cmd.fileId = req.getFileId();
    cmd.status = req.getStatus();
    cmd.useFile = req.getUseFile();
    service.update(cmd);
    return ResponseEntity.ok(ApiResponse.success("更新成功", null));
  }

  @DeleteMapping("/questions/{id}")
  @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
  public ResponseEntity<ApiResponse<Void>> delete(@PathVariable("id") Long id) {
    service.delete(id);
    return ResponseEntity.ok(ApiResponse.success("删除成功", null));
  }

  @PostMapping(value = "/questions/import", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
  @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
  public ResponseEntity<ApiResponse<HashMap<String, Object>>> importFile(Authentication auth, @RequestParam("file") MultipartFile file) {
    var me = userService.getByUsername(auth.getName());
    QuestionImportService.ImportResult result = importService.importExcel(file, me.getId());
    HashMap<String, Object> data = new HashMap<>();
    data.put("total", result.total);
    data.put("imported", result.imported);
    data.put("failed", result.failed);
    data.put("errors", result.errors);
    data.put("filename", file.getOriginalFilename());
    return ResponseEntity.ok(ApiResponse.success("import finished", data));
  }
}
