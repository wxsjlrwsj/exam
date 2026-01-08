package org.example.chaoxingsystem.teacher.score;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/** 成绩服务：列表、详情与阅卷提交 */
@Service
public class ScoreService {
  private final ScoreMapper mapper;
  private final org.example.chaoxingsystem.teacher.exam.ExamMapper examMapper;
  private final org.example.chaoxingsystem.teacher.paper.PaperMapper paperMapper;
  private final com.fasterxml.jackson.databind.ObjectMapper objectMapper = new com.fasterxml.jackson.databind.ObjectMapper();

  public ScoreService(ScoreMapper mapper,
                      org.example.chaoxingsystem.teacher.exam.ExamMapper examMapper,
                      org.example.chaoxingsystem.teacher.paper.PaperMapper paperMapper) {
    this.mapper = mapper;
    this.examMapper = examMapper;
    this.paperMapper = paperMapper;
  }

  public long count(Long examId, Long classId, String keyword) { return mapper.count(examId, classId, keyword); }

  public List<Map<String, Object>> page(Long examId, Long classId, String keyword, int page, int size) {
    int offset = (Math.max(page, 1) - 1) * Math.max(size, 1);
    List<Map<String, Object>> rows = mapper.selectPage(examId, classId, keyword, offset, size);
    for (int i = 0; i < rows.size(); i++) {
      Map<String, Object> row = rows.get(i);
      String anonymousName = buildAnonymousName(offset + i + 1, row.get("studentId"), row.get("studentNo"));
      row.put("anonymousName", anonymousName);
      row.put("name", anonymousName);
      if (row.containsKey("studentNo")) {
        row.put("studentNo", "******");
      }
    }
    return rows;
  }

  public Map<String, Object> detail(Long examId, Long studentId) {
    ExamRecord r = mapper.selectRecord(examId, studentId);
    if (r == null) return Map.of();
    List<ExamAnswer> answers = mapper.selectAnswersByRecordId(r.getId());
    java.util.Map<Long, ExamAnswer> ansMap = new java.util.HashMap<>();
    for (var a : answers) { ansMap.put(a.getQuestionId(), a); }
    var exam = examMapper.selectById(examId);
    if (exam == null) return Map.of();
    List<java.util.Map<String, Object>> qs = paperMapper.selectPaperQuestionViews(exam.getPaperId());
    List<Map<String, Object>> outQs = new java.util.ArrayList<>();
    for (Map<String, Object> m : qs) {
      Long qid = null;
      try { qid = m.get("id") != null ? Long.valueOf(String.valueOf(m.get("id"))) : null; } catch (Exception ignored) {}
      String typeCode = m.get("type_code") != null ? String.valueOf(m.get("type_code")) : null;
      String type = normalizeType(typeCode);
      String content = m.get("content") != null ? String.valueOf(m.get("content")) : null;
      Integer qScore = null;
      Object sObj = m.get("score");
      if (sObj instanceof Number) qScore = ((Number) sObj).intValue();
      Object correctObj = null;
      try { if (m.get("answer") != null) correctObj = objectMapper.readValue(String.valueOf(m.get("answer")), Object.class); } catch (Exception ignored) {}
      Object optionsObj = null;
      try { if (m.get("options") != null) optionsObj = objectMapper.readValue(String.valueOf(m.get("options")), Object.class); } catch (Exception ignored) {}
      Object studentAns = null;
      Integer givenScore = null;
      String comment = null;
      var a = qid != null ? ansMap.get(qid) : null;
      if (a != null) {
        try { studentAns = a.getStudentAnswer() != null ? objectMapper.readValue(a.getStudentAnswer(), Object.class) : null; } catch (Exception ignored) {}
        givenScore = a.getScore();
        comment = a.getComment();
      }
      boolean autoGraded = "single_choice".equals(type) || "multiple_choice".equals(type) || "true_false".equals(type);
      if (autoGraded) {
        Integer autoScore = calcAutoScore(type, correctObj, studentAns, qScore);
        if (autoScore != null) {
          givenScore = autoScore;
        }
      } else if (givenScore == null) {
        givenScore = 0;
      }
      Map<String, Object> row = new HashMap<>();
      row.put("id", qid);
      row.put("type", type);
      row.put("content", content);
      row.put("options", optionsObj);
      row.put("score", qScore);
      row.put("correctAnswer", correctObj);
      row.put("studentAnswer", studentAns);
      row.put("givenScore", givenScore);
      row.put("comment", comment);
      row.put("autoGraded", autoGraded);
      outQs.add(row);
    }
    Map<String, Object> data = new HashMap<>();
    data.put("record", r);
    data.put("questions", outQs);
    return data;
  }

  @Transactional
  public void grade(Long examId, Long studentId, Integer totalScore, List<Map<String, Object>> questions) {
    ExamRecord r = mapper.selectRecord(examId, studentId);
    if (r == null) return;
    int calcTotal = 0;
    if (questions != null) {
      for (Map<String, Object> q : questions) {
        Integer s = q.get("givenScore") instanceof Number ? ((Number) q.get("givenScore")).intValue() : null;
        if (s != null) calcTotal += s;
      }
    }
    Integer finalTotal = totalScore != null ? totalScore : calcTotal;
    mapper.updateRecordScore(r.getId(), finalTotal, 2);
    for (Map<String, Object> q : questions) {
      Long qid = q.get("id") instanceof Number ? ((Number) q.get("id")).longValue() : null;
      Integer score = q.get("givenScore") instanceof Number ? ((Number) q.get("givenScore")).intValue() : null;
      String comment = (String) q.get("comment");
      mapper.updateAnswerScore(r.getId(), qid, score, comment);
    }
  }

  public Map<String, Object> stats(Long examId) {
    Map<String, Object> m = mapper.selectStats(examId);
    if (m == null) m = new HashMap<>();
    Number total = (Number) m.getOrDefault("total", 0);
    Number passCount = (Number) m.getOrDefault("passCount", 0);
    double rate = 0.0;
    if (total != null && total.intValue() > 0 && passCount != null) {
      rate = ((double) passCount.intValue()) / ((double) total.intValue()) * 100.0;
    }
    List<Double> scores = mapper.selectScoreValuesByExamId(examId);
    int[] distCount = new int[]{0, 0, 0, 0, 0}; // 0-59, 60-69, 70-79, 80-89, 90-100
    for (Double s : scores) {
      double val = s != null ? s : 0.0;
      if (val >= 90.0) distCount[4]++; else if (val >= 80.0) distCount[3]++; else if (val >= 70.0) distCount[2]++; else if (val >= 60.0) distCount[1]++; else distCount[0]++;
    }
    int totalScored = scores.size();
    double[] distPercent = new double[]{0, 0, 0, 0, 0};
    if (totalScored > 0) {
      for (int i = 0; i < 5; i++) distPercent[i] = Math.round((distCount[i] * 100.0 / totalScored) * 100.0) / 100.0;
    }
    Map<String, Object> data = new HashMap<>(m);
    data.put("totalCount", total != null ? total.intValue() : 0);
    data.put("passRate", rate);
    data.put("dist", distPercent);
    data.put("distCount", distCount);
    data.putIfAbsent("avgScore", m.get("avgScore"));
    data.putIfAbsent("maxScore", m.get("maxScore"));
    data.putIfAbsent("minScore", m.get("minScore"));
    data.put("classStats", java.util.Collections.emptyList());
    data.put("knowledgePoints", java.util.Collections.emptyList());
    return data;
  }

  @Transactional
  public Map<String, Object> adjustScore(Long scoreId, Integer newScore, String reason) {
    ExamRecord record = mapper.selectRecordById(scoreId);
    if (record == null) {
      throw new org.springframework.web.server.ResponseStatusException(
        org.springframework.http.HttpStatus.NOT_FOUND, "成绩记录不存在"
      );
    }
    
    Integer originalScore = record.getScore();
    
    // 插入调整记录
    mapper.insertScoreAdjustment(scoreId, originalScore, newScore, reason);
    
    // 更新成绩
    mapper.updateRecordScore(scoreId, newScore, record.getStatus());
    
    Map<String, Object> data = new HashMap<>();
    data.put("scoreId", scoreId);
    data.put("originalScore", originalScore);
    data.put("newScore", newScore);
    data.put("adjustTime", java.time.LocalDateTime.now().format(
      java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")
    ));
    
    return data;
  }

  @Transactional
  public int batchPublish(List<Long> scoreIds, boolean published) {
    int status = published ? 2 : 1; // 2=已发布, 1=未发布
    return mapper.batchUpdateStatus(scoreIds, status);
  }

  public byte[] exportScores(Long examId, String format) {
    // 简化实现：生成空的Excel文件
    // 实际应用中应使用Apache POI或其他Excel库生成真实的Excel文件
    String content = "学号,姓名,班级,成绩\n";
    List<Map<String, Object>> scores = mapper.selectPage(examId, null, null, 0, 1000);

    for (Map<String, Object> score : scores) {
      content += String.format("%s,%s,%s,%s\n",
        score.get("studentId"),
        score.get("name"),
        score.get("className"),
        score.get("score")
      );
    }

    return content.getBytes(java.nio.charset.StandardCharsets.UTF_8);
  }

  private String normalizeType(String code) {
    if (code == null) return null;
    return switch (code) {
      case "SINGLE", "single_choice" -> "single_choice";
      case "MULTI", "multiple_choice" -> "multiple_choice";
      case "TRUE_FALSE", "true_false" -> "true_false";
      case "FILL", "fill_blank" -> "fill_blank";
      case "SHORT", "short_answer" -> "short_answer";
      case "PROGRAM", "programming" -> "programming";
      default -> code;
    };
  }

  private Integer calcAutoScore(String type, Object correctObj, Object studentAns, Integer fullScore) {
    int full = fullScore != null ? fullScore : 0;
    if (full <= 0) return 0;
    if (studentAns == null) return 0;
    if ("single_choice".equals(type)) {
      return String.valueOf(studentAns).equals(String.valueOf(correctObj)) ? full : 0;
    }
    if ("true_false".equals(type)) {
      boolean correct = false;
      if (correctObj instanceof Boolean b) correct = b;
      else if (correctObj != null) correct = "true".equalsIgnoreCase(String.valueOf(correctObj)) || "T".equalsIgnoreCase(String.valueOf(correctObj));
      boolean student = false;
      if (studentAns instanceof Boolean b) student = b;
      else if (studentAns != null) student = "true".equalsIgnoreCase(String.valueOf(studentAns)) || "T".equalsIgnoreCase(String.valueOf(studentAns));
      return correct == student ? full : 0;
    }
    if ("multiple_choice".equals(type)) {
      java.util.List<String> correctList = null;
      if (correctObj instanceof java.util.List<?> l) {
        correctList = l.stream().map(String::valueOf).toList();
      } else if (correctObj != null) {
        correctList = java.util.Arrays.stream(String.valueOf(correctObj).split(",")).map(String::trim).filter(s -> !s.isEmpty()).toList();
      }
      java.util.List<String> studentList = null;
      if (studentAns instanceof java.util.List<?> l2) {
        studentList = l2.stream().map(String::valueOf).toList();
      } else if (studentAns != null) {
        studentList = java.util.Arrays.stream(String.valueOf(studentAns).split(",")).map(String::trim).filter(s -> !s.isEmpty()).toList();
      }
      if (correctList == null || studentList == null || studentList.isEmpty()) return 0;
      java.util.Set<String> correctSet = new java.util.HashSet<>(correctList);
      java.util.Set<String> studentSet = new java.util.HashSet<>(studentList);
      for (String opt : studentSet) {
        if (!correctSet.contains(opt)) return 0;
      }
      if (correctSet.equals(studentSet)) return full;
      return (int) Math.round(full / 2.0);
    }
    return 0;
  }

  private String buildAnonymousName(int index, Object studentId, Object studentNo) {
    if (studentId != null) return "匿名" + index;
    if (studentNo != null) {
      String s = String.valueOf(studentNo);
      if (s.length() >= 2) return "匿名" + s.substring(s.length() - 2);
    }
    return "匿名";
  }

  @Transactional
  public Map<String, Object> adjustScoreByExamStudent(Long examId, Long studentId, Integer newScore, String reason) {
    ExamRecord r = mapper.selectRecord(examId, studentId);
    if (r == null) {
      throw new org.springframework.web.server.ResponseStatusException(
        org.springframework.http.HttpStatus.NOT_FOUND, "成绩记录不存在"
      );
    }
    Integer originalScore = r.getScore();
    mapper.insertScoreAdjustment(r.getId(), originalScore, newScore, reason);
    mapper.updateRecordScore(r.getId(), newScore, r.getStatus());
    Map<String, Object> data = new HashMap<>();
    data.put("scoreId", r.getId());
    data.put("originalScore", originalScore);
    data.put("newScore", newScore);
    data.put("adjustTime", java.time.LocalDateTime.now().format(
      java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")
    ));
    return data;
  }
}
