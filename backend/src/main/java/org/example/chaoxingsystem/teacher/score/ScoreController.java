package org.example.chaoxingsystem.teacher.score;

import org.example.chaoxingsystem.config.ModuleCheck;
import org.example.chaoxingsystem.user.dto.ApiResponse;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/** 成绩管理接口：列表、详情、阅卷提交 */
@RestController
@RequestMapping("/api")
@ModuleCheck(moduleCode = "tch_score")
public class ScoreController {
  private final ScoreService service;

  public ScoreController(ScoreService service) { this.service = service; }

  @GetMapping("/scores")
  @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
  public ResponseEntity<ApiResponse<HashMap<String, Object>>> list(
    @RequestParam(value = "examId", required = false) Long examId,
    @RequestParam(value = "classId", required = false) Long classId,
    @RequestParam(value = "keyword", required = false) String keyword,
    @RequestParam(value = "page", defaultValue = "1") int page,
    @RequestParam(value = "size", defaultValue = "10") int size
  ) {
    long total = service.count(examId, classId, keyword);
    List<Map<String, Object>> list = service.page(examId, classId, keyword, page, size);
    HashMap<String, Object> data = new HashMap<>();
    data.put("list", list);
    data.put("total", total);
    return ResponseEntity.ok(ApiResponse.success("获取成功", data));
  }

  @GetMapping("/scores/{examId}/student/{studentId}")
  @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
  public ResponseEntity<ApiResponse<Map<String, Object>>> detail(@PathVariable("examId") Long examId, @PathVariable("studentId") Long studentId) {
    Map<String, Object> data = service.detail(examId, studentId);
    return ResponseEntity.ok(ApiResponse.success("获取成功", data));
  }

  @PostMapping("/scores/{examId}/student/{studentId}")
  @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
  public ResponseEntity<ApiResponse<Void>> grade(@PathVariable("examId") Long examId, @PathVariable("studentId") Long studentId, @RequestBody Map<String, Object> body) {
    Integer totalScore = body.get("totalScore") instanceof Number ? ((Number) body.get("totalScore")).intValue() : null;
    @SuppressWarnings("unchecked")
    List<Map<String, Object>> questions = (List<Map<String, Object>>) body.get("questions");
    service.grade(examId, studentId, totalScore, questions);
    return ResponseEntity.ok(ApiResponse.success("提交成功", null));
  }

  @GetMapping("/scores/stats")
  @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
  public ResponseEntity<ApiResponse<Map<String, Object>>> stats(@RequestParam("examId") Long examId) {
    Map<String, Object> data = service.stats(examId);
    return ResponseEntity.ok(ApiResponse.success("获取成功", data));
  }

  @PutMapping("/scores/{scoreId}")
  @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
  public ResponseEntity<ApiResponse<Map<String, Object>>> adjustScore(
    @PathVariable("scoreId") Long scoreId,
    @RequestBody Map<String, Object> body
  ) {
    Integer newScore = body.get("newScore") instanceof Number ? ((Number) body.get("newScore")).intValue() : null;
    String reason = (String) body.get("reason");
    Map<String, Object> data = service.adjustScore(scoreId, newScore, reason);
    return ResponseEntity.ok(ApiResponse.success("调整成功", data));
  }

  @PostMapping("/scores/batch-publish")
  @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
  public ResponseEntity<ApiResponse<Map<String, Object>>> batchPublish(@RequestBody Map<String, Object> body) {
    @SuppressWarnings("unchecked")
    List<Number> scoreIds = (List<Number>) body.get("scoreIds");
    Boolean published = (Boolean) body.get("published");
    
    List<Long> ids = scoreIds.stream().map(Number::longValue).toList();
    int affected = service.batchPublish(ids, published != null && published);
    
    Map<String, Object> data = new HashMap<>();
    data.put("affected", affected);
    return ResponseEntity.ok(ApiResponse.success("操作成功", data));
  }

  @PostMapping("/scores/import")
  @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
  public ResponseEntity<ApiResponse<Map<String, Object>>> importScores(
    @RequestParam("examId") Long examId,
    @RequestParam("file") org.springframework.web.multipart.MultipartFile file
  ) {
    // 简化实现：返回导入结果占位
    Map<String, Object> data = new HashMap<>();
    data.put("imported", 0);
    data.put("filename", file.getOriginalFilename());
    return ResponseEntity.ok(ApiResponse.success("导入成功", data));
  }

  @GetMapping("/scores/export")
  @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
  public ResponseEntity<byte[]> exportScores(
    @RequestParam("examId") Long examId,
    @RequestParam(value = "format", defaultValue = "excel") String format
  ) {
    byte[] data = service.exportScores(examId, format);
    
    org.springframework.http.HttpHeaders headers = new org.springframework.http.HttpHeaders();
    headers.setContentType(org.springframework.http.MediaType.APPLICATION_OCTET_STREAM);
    headers.setContentDispositionFormData("attachment", "scores_" + examId + ".xlsx");
    
    return ResponseEntity.ok().headers(headers).body(data);
  }
}
