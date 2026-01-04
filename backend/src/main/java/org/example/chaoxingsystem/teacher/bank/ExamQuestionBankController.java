package org.example.chaoxingsystem.teacher.bank;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.example.chaoxingsystem.config.ModuleCheck;
import org.example.chaoxingsystem.user.UserService;
import org.example.chaoxingsystem.user.dto.ApiResponse;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.ByteArrayOutputStream;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api")
@ModuleCheck(moduleCode = "tch_bank")
public class ExamQuestionBankController {
  private final ExamQuestionService service;
  private final UserService userService;
  private final ObjectMapper objectMapper = new ObjectMapper();

  public ExamQuestionBankController(ExamQuestionService service, UserService userService) {
    this.service = service;
    this.userService = userService;
  }

  @GetMapping("/exam-questions")
  @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
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

  @PostMapping("/exam-questions")
  @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
  public ResponseEntity<ApiResponse<Map<String, Object>>> create(Authentication auth, @RequestBody Map<String, Object> body) {
    var me = userService.getByUsername(auth.getName());
    String typeCode = asString(body.get("typeCode"));
    String content = asString(body.get("content"));
    String options = toJsonString(body.get("options"));
    String answer = toJsonString(body.get("answer"));
    Integer difficulty = asInteger(body.get("difficulty"));
    if (difficulty == null) difficulty = 1;
    String subject = asString(body.get("subject"));
    String knowledgePoints = asString(body.get("knowledgePoints"));
    String fileId = asString(body.get("fileId"));
    Long id = service.create(me.getId(), typeCode, content, options, answer, difficulty, subject, knowledgePoints, fileId);
    return ResponseEntity.ok(ApiResponse.success("创建成功", Map.of("id", id)));
  }

  @PutMapping("/exam-questions/{id}")
  @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
  public ResponseEntity<ApiResponse<Void>> update(@PathVariable("id") Long id, @RequestBody Map<String, Object> body) {
    ExamQuestionService.UpdateCommand cmd = new ExamQuestionService.UpdateCommand();
    cmd.id = id;
    cmd.typeCode = asString(body.get("typeCode"));
    cmd.content = asString(body.get("content"));
    cmd.optionsJson = toJsonString(body.get("options"));
    cmd.answerJson = toJsonString(body.get("answer"));
    cmd.analysis = asString(body.get("analysis"));
    cmd.difficulty = asInteger(body.get("difficulty"));
    cmd.subject = asString(body.get("subject"));
    cmd.knowledgePoints = asString(body.get("knowledgePoints"));
    cmd.fileId = asString(body.get("fileId"));
    cmd.status = asInteger(body.get("status"));
    Object useFileObj = body.get("useFile");
    cmd.useFile = (useFileObj instanceof Boolean) ? (Boolean) useFileObj : null;
    service.update(cmd);
    return ResponseEntity.ok(ApiResponse.success("更新成功", null));
  }

  @DeleteMapping("/exam-questions/{id}")
  @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
  public ResponseEntity<ApiResponse<Void>> delete(@PathVariable("id") Long id) {
    service.delete(id);
    return ResponseEntity.ok(ApiResponse.success("删除成功", null));
  }

  @GetMapping(value = "/exam-questions/import/template")
  @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
  public ResponseEntity<byte[]> downloadTemplate() {
    try (Workbook workbook = new XSSFWorkbook(); ByteArrayOutputStream baos = new ByteArrayOutputStream()) {
      Sheet sheet = workbook.createSheet("模板");
      Row header = sheet.createRow(0);
      String[] headers = new String[] { "题型", "学科", "题目内容", "难度", "选项", "答案", "解析", "知识点", "文件ID" };
      for (int i = 0; i < headers.length; i++) {
        header.createCell(i).setCellValue(headers[i]);
        sheet.autoSizeColumn(i);
      }
      workbook.write(baos);
      HttpHeaders headersObj = new HttpHeaders();
      headersObj.add(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"考题题库导入模板.xlsx\"");
      return ResponseEntity
        .ok()
        .headers(headersObj)
        .contentType(MediaType.parseMediaType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"))
        .body(baos.toByteArray());
    } catch (Exception e) {
      return ResponseEntity
        .badRequest()
        .contentType(MediaType.TEXT_PLAIN)
        .body(("failed to generate template: " + e.getMessage()).getBytes());
    }
  }

  @PostMapping(value = "/exam-questions/import", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
  @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
  public ResponseEntity<ApiResponse<HashMap<String, Object>>> importFile(Authentication auth, @RequestParam("file") MultipartFile file) {
    // 复用后端导入逻辑可在后续迭代中实现；此处先返回基本信息以便前端验证功能
    HashMap<String, Object> data = new HashMap<>();
    data.put("filename", file.getOriginalFilename());
    data.put("size", file.getSize());
    return ResponseEntity.ok(ApiResponse.success("上传成功，后续实现解析与入库", data));
  }

  private String asString(Object v) { return v == null ? null : String.valueOf(v); }
  private Integer asInteger(Object v) {
    if (v == null) return null;
    try { return Integer.parseInt(String.valueOf(v)); } catch (Exception ignored) { return null; }
  }
  private String toJsonString(Object v) {
    if (v == null) return null;
    try { return objectMapper.writeValueAsString(v); } catch (Exception ignored) { return null; }
  }
}
