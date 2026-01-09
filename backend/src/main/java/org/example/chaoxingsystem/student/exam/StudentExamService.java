package org.example.chaoxingsystem.student.exam;

import org.example.chaoxingsystem.teacher.exam.ExamMapper;
import org.example.chaoxingsystem.teacher.exam.Exam;
import org.example.chaoxingsystem.teacher.paper.PaperMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import com.fasterxml.jackson.databind.ObjectMapper;

@Service
public class StudentExamService {
  private final ExamMapper examMapper;
  private final PaperMapper paperMapper;
  private final StudentExamMapper studentExamMapper;
  private final org.example.chaoxingsystem.teacher.score.ScoreMapper scoreMapper;
  private final ObjectMapper objectMapper = new ObjectMapper();

  public StudentExamService(ExamMapper examMapper, PaperMapper paperMapper, StudentExamMapper studentExamMapper, org.example.chaoxingsystem.teacher.score.ScoreMapper scoreMapper) {
    this.examMapper = examMapper;
    this.paperMapper = paperMapper;
    this.studentExamMapper = studentExamMapper;
    this.scoreMapper = scoreMapper;
  }

  private String normalizeType(String code) {
    if (code == null) return null;
    return switch (code) {
      case "SINGLE", "single_choice" -> "single_choice";
      case "MULTI", "multiple_choice" -> "multiple_choice";
      case "TRUE_FALSE", "true_false" -> "true_false";
      case "FILL", "fill_blank" -> "fill_blank";
      case "SHORT", "short_answer" -> "short_answer";
      default -> code;
    };
  }

  public Map<String, Object> getPaper(Long examId, Long studentId) {
    Exam e = examMapper.selectById(examId);
    if (e == null) throw new org.springframework.web.server.ResponseStatusException(org.springframework.http.HttpStatus.NOT_FOUND, "考试不存在");
    long assigned = examMapper.existsStudentAssignment(examId, studentId);
    if (assigned <= 0L) throw new org.springframework.web.server.ResponseStatusException(org.springframework.http.HttpStatus.FORBIDDEN, "无权限");
    java.time.format.DateTimeFormatter fmt = java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
    java.time.ZoneId zone = java.time.ZoneId.of("Asia/Shanghai");
    java.time.LocalDateTime now = java.time.LocalDateTime.now(zone);
    java.time.LocalDateTime st = java.time.LocalDateTime.parse(e.getStartTime(), fmt);
    java.time.LocalDateTime et = java.time.LocalDateTime.parse(e.getEndTime(), fmt);
    if (now.isBefore(st) || now.isAfter(et)) throw new org.springframework.web.server.ResponseStatusException(org.springframework.http.HttpStatus.BAD_REQUEST, "不在考试时间范围内");
    var p = paperMapper.selectById(e.getPaperId());
    List<Map<String, Object>> qs = paperMapper.selectPaperQuestionViews(e.getPaperId());
    var record = scoreMapper.selectRecord(examId, studentId);
    if (record == null) {
      studentExamMapper.insertStartRecord(examId, studentId);
    } else if (record.getStatus() == null || record.getStatus() == 0) {
      studentExamMapper.markStarted(record.getId());
    }
    List<Map<String, Object>> outQs = new java.util.ArrayList<>();
    for (Map<String, Object> m : qs) {
      Long qid = null;
      try { qid = m.get("id") != null ? Long.valueOf(String.valueOf(m.get("id"))) : null; } catch (Exception ignored) {}
      String type = normalizeType(m.get("type_code") != null ? String.valueOf(m.get("type_code")) : null);
      String content = m.get("content") != null ? String.valueOf(m.get("content")) : null;
      String options = m.get("options") != null ? String.valueOf(m.get("options")) : null;
      Integer score = null;
      Object sObj = m.get("score");
      if (sObj instanceof Number) score = ((Number) sObj).intValue();
      Map<String, Object> row = new HashMap<>();
      row.put("id", qid);
      row.put("type", type);
      row.put("content", content);
      row.put("options", options);
      row.put("score", score);
      outQs.add(row);
    }
    Map<String, Object> data = new HashMap<>();
    data.put("paperId", p != null ? p.getId() : null);
    data.put("name", p != null ? p.getName() : null);
    data.put("subject", p != null ? p.getSubject() : null);
    data.put("questions", outQs);
    return data;
  }

  @Transactional
  public void submit(Long examId, Long studentId, Map<String, Object> answers, Integer durationUsed) {
    Exam e = examMapper.selectById(examId);
    if (e == null) throw new org.springframework.web.server.ResponseStatusException(org.springframework.http.HttpStatus.NOT_FOUND, "考试不存在");
    long assigned = examMapper.existsStudentAssignment(examId, studentId);
    if (assigned <= 0L) throw new org.springframework.web.server.ResponseStatusException(org.springframework.http.HttpStatus.FORBIDDEN, "无权限");
    java.time.format.DateTimeFormatter fmt = java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
    java.time.ZoneId zone = java.time.ZoneId.of("Asia/Shanghai");
    java.time.LocalDateTime now = java.time.LocalDateTime.now(zone);
    java.time.LocalDateTime st = java.time.LocalDateTime.parse(e.getStartTime(), fmt);
    java.time.LocalDateTime et = java.time.LocalDateTime.parse(e.getEndTime(), fmt);
    if (now.isBefore(st) || now.isAfter(et)) throw new org.springframework.web.server.ResponseStatusException(org.springframework.http.HttpStatus.BAD_REQUEST, "不在考试时间范围内");
    List<Map<String, Object>> qs = paperMapper.selectPaperQuestionViews(e.getPaperId());
    java.util.Set<Long> validQids = new java.util.HashSet<>();
    for (Map<String, Object> m : qs) {
      Object idObj = m.get("id");
      if (idObj != null) {
        try { validQids.add(Long.valueOf(String.valueOf(idObj))); } catch (Exception ignored) {}
      }
    }
    if (answers != null) {
      for (Map.Entry<String, Object> en : answers.entrySet()) {
        Long qid = null;
        try { qid = Long.valueOf(en.getKey()); } catch (Exception ex) {}
        if (qid == null || !validQids.contains(qid)) throw new org.springframework.web.server.ResponseStatusException(org.springframework.http.HttpStatus.BAD_REQUEST, "非法题目");
      }
    }
    var record = scoreMapper.selectRecord(examId, studentId);
    Long recordId;
    if (record == null) {
      studentExamMapper.insertRecord(examId, studentId);
      record = scoreMapper.selectRecord(examId, studentId);
    }
    recordId = record.getId();
    studentExamMapper.deleteAnswersByRecordId(recordId);
    for (Map.Entry<String, Object> entry2 : answers.entrySet()) {
      Long qid = Long.valueOf(entry2.getKey());
      String ansJson = null;
      try {
        ansJson = entry2.getValue() != null ? objectMapper.writeValueAsString(entry2.getValue()) : null;
      } catch (Exception ex) {
        ansJson = null;
      }
      studentExamMapper.insertAnswer(recordId, qid, ansJson);
    }
    int totalScore = 0;
    for (Map<String, Object> m : qs) {
      Object idObj = m.get("id");
      Long qid = null;
      try { qid = idObj != null ? Long.valueOf(String.valueOf(idObj)) : null; } catch (Exception ignored) {}
      if (qid == null) continue;
      String type = normalizeType(m.get("type_code") != null ? String.valueOf(m.get("type_code")) : null);
      Integer qScore = null;
      Object sObj = m.get("score");
      if (sObj instanceof Number) qScore = ((Number) sObj).intValue();
      Object correctObj = null;
      Object ansJsonObj = m.get("answer");
      try { if (ansJsonObj != null) correctObj = objectMapper.readValue(String.valueOf(ansJsonObj), Object.class); } catch (Exception ignored) {}
      Object stuAns = answers != null ? answers.get(String.valueOf(qid)) : null;
      boolean isCorrect = false;
      if ("single_choice".equals(type)) {
        isCorrect = stuAns != null && String.valueOf(stuAns).equals(String.valueOf(correctObj));
      } else if ("multiple_choice".equals(type)) {
        java.util.List<String> correctList = null;
        if (correctObj instanceof java.util.List<?> l) {
          correctList = l.stream().map(String::valueOf).toList();
        } else if (correctObj != null) {
          correctList = java.util.Arrays.stream(String.valueOf(correctObj).split(",")).map(String::trim).filter(s -> !s.isEmpty()).toList();
        }
        java.util.List<String> stuList = null;
        if (stuAns instanceof java.util.List<?> l2) {
          stuList = l2.stream().map(String::valueOf).toList();
        } else if (stuAns != null) {
          stuList = java.util.Arrays.stream(String.valueOf(stuAns).split(",")).map(String::trim).filter(s -> !s.isEmpty()).toList();
        }
        if (correctList != null && stuList != null) {
          java.util.Set<String> a = new java.util.HashSet<>(correctList);
          java.util.Set<String> b = new java.util.HashSet<>(stuList);
          isCorrect = a.equals(b);
        }
      } else if ("true_false".equals(type)) {
        boolean corr = false;
        if (correctObj instanceof Boolean) corr = (Boolean) correctObj;
        else if (correctObj != null) corr = "true".equalsIgnoreCase(String.valueOf(correctObj)) || "T".equalsIgnoreCase(String.valueOf(correctObj));
        boolean stu = false;
        if (stuAns instanceof Boolean) stu = (Boolean) stuAns;
        else if (stuAns != null) stu = "true".equalsIgnoreCase(String.valueOf(stuAns)) || "T".equalsIgnoreCase(String.valueOf(stuAns));
        isCorrect = stu == corr;
      }
      if (isCorrect && qScore != null) {
        totalScore += qScore;
        scoreMapper.updateAnswerScore(recordId, qid, qScore, null);
      }
    }
    scoreMapper.updateRecordScore(recordId, totalScore, 1);
    studentExamMapper.markSubmitted(recordId);
  }


  public Map<String, Object> getReview(Long examId, Long studentId) {
    Exam exam = examMapper.selectById(examId);
    if (exam == null) throw new org.springframework.web.server.ResponseStatusException(org.springframework.http.HttpStatus.NOT_FOUND, "考试不存在");
    long assigned = examMapper.existsStudentAssignment(examId, studentId);
    if (assigned <= 0L) throw new org.springframework.web.server.ResponseStatusException(org.springframework.http.HttpStatus.FORBIDDEN, "无权限");

    var record = scoreMapper.selectRecord(examId, studentId);
    if (record == null || record.getStatus() == null || record.getStatus() < 2) {
      throw new org.springframework.web.server.ResponseStatusException(org.springframework.http.HttpStatus.FORBIDDEN, "暂不可查看试卷");
    }
    if (exam.getAllowReview() == null || exam.getAllowReview() == 0) {
      throw new org.springframework.web.server.ResponseStatusException(org.springframework.http.HttpStatus.FORBIDDEN, "暂不可查看试卷");
    }
    
    List<org.example.chaoxingsystem.teacher.score.ExamAnswer> answers = scoreMapper.selectAnswersByRecordId(record.getId());
    List<Map<String, Object>> questionDetails = new java.util.ArrayList<>();
    
    for (var ans : answers) {
      Map<String, Object> detail = new HashMap<>();
      detail.put("questionId", ans.getQuestionId());
      detail.put("studentAnswer", ans.getStudentAnswer());
      detail.put("score", ans.getScore());
      detail.put("comment", ans.getComment());
      questionDetails.add(detail);
    }
    
    Map<String, Object> result = new HashMap<>();
    result.put("examName", exam != null ? exam.getName() : null);
    result.put("score", record.getScore());
    result.put("questions", questionDetails);
    return result;
  }

  public java.util.List<java.util.Map<String, Object>> getWarnings(Long examId, Long studentId, String since) {
    Exam e = examMapper.selectById(examId);
    if (e == null) throw new org.springframework.web.server.ResponseStatusException(org.springframework.http.HttpStatus.NOT_FOUND, "考试不存在");
    long assigned = examMapper.existsStudentAssignment(examId, studentId);
    if (assigned <= 0L) throw new org.springframework.web.server.ResponseStatusException(org.springframework.http.HttpStatus.FORBIDDEN, "无权限");
    return examMapper.selectWarnings(examId, studentId, since);
  }

  @Transactional
  public void recordMonitorEvent(Long examId, Long studentId, String eventType, String eventData) {
    Exam e = examMapper.selectById(examId);
    if (e == null) throw new org.springframework.web.server.ResponseStatusException(org.springframework.http.HttpStatus.NOT_FOUND, "考试不存在");
    long assigned = examMapper.existsStudentAssignment(examId, studentId);
    if (assigned <= 0L) throw new org.springframework.web.server.ResponseStatusException(org.springframework.http.HttpStatus.FORBIDDEN, "无权限");
    String et = eventType != null ? eventType : "";
    if ("switch_tab".equalsIgnoreCase(et) || "blur".equalsIgnoreCase(et) || "visibility_hidden".equalsIgnoreCase(et)) {
      studentExamMapper.incrementSwitchCount(examId, studentId);
      studentExamMapper.insertMonitorEvent(examId, studentId, et, eventData, "medium");
      return;
    }
    if ("active".equalsIgnoreCase(et) || "heartbeat".equalsIgnoreCase(et)) {
      studentExamMapper.updateLastActiveTime(examId, studentId);
      studentExamMapper.insertMonitorEvent(examId, studentId, et, eventData, "low");
      return;
    }
    if ("progress".equalsIgnoreCase(et)) {
      Integer progress = null;
      try { progress = eventData != null ? Integer.valueOf(eventData) : null; } catch (Exception ignored) {}
      if (progress != null) {
        if (progress < 0) progress = 0;
        if (progress > 100) progress = 100;
        studentExamMapper.updateProgress(examId, studentId, progress);
      } else {
        studentExamMapper.updateLastActiveTime(examId, studentId);
      }
      studentExamMapper.insertMonitorEvent(examId, studentId, et, eventData, "low");
      return;
    }
    studentExamMapper.updateLastActiveTime(examId, studentId);
    studentExamMapper.insertMonitorEvent(examId, studentId, et, eventData, "low");
  }

  @Transactional
  public Map<String, Object> saveCameraSnapshot(Long examId, Long studentId, String base64Image, String contentType) {
    Exam e = examMapper.selectById(examId);
    if (e == null) throw new org.springframework.web.server.ResponseStatusException(org.springframework.http.HttpStatus.NOT_FOUND, "考试不存在");
    long assigned = examMapper.existsStudentAssignment(examId, studentId);
    if (assigned <= 0L) throw new org.springframework.web.server.ResponseStatusException(org.springframework.http.HttpStatus.FORBIDDEN, "无权限");
    if (base64Image == null || base64Image.isBlank()) {
      throw new org.springframework.web.server.ResponseStatusException(org.springframework.http.HttpStatus.BAD_REQUEST, "图片为空");
    }
    String payload = base64Image;
    int comma = payload.indexOf(',');
    if (payload.startsWith("data:") && comma > 0) {
      payload = payload.substring(comma + 1);
    }
    byte[] bytes;
    try {
      bytes = java.util.Base64.getDecoder().decode(payload);
    } catch (Exception ex) {
      throw new org.springframework.web.server.ResponseStatusException(org.springframework.http.HttpStatus.BAD_REQUEST, "图片格式错误");
    }
    if (contentType == null || contentType.isBlank()) contentType = "image/jpeg";
    try {
      studentExamMapper.createCameraSnapshotTableIfNotExists();
    } catch (Exception ignore) {}
    studentExamMapper.insertCameraSnapshot(examId, studentId, bytes, contentType);
    try {
      studentExamMapper.updateLastActiveTime(examId, studentId);
    } catch (Exception ignore) {}
    Map<String, Object> data = new java.util.HashMap<>();
    data.put("captureTime", java.time.LocalDateTime.now().format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
    return data;
  }

  public Map<String, Object> getResult(Long examId, Long studentId) {
    Exam e = examMapper.selectById(examId);
    if (e == null) throw new org.springframework.web.server.ResponseStatusException(org.springframework.http.HttpStatus.NOT_FOUND, "考试不存在");
    long assigned = examMapper.existsStudentAssignment(examId, studentId);
    if (assigned <= 0L) throw new org.springframework.web.server.ResponseStatusException(org.springframework.http.HttpStatus.FORBIDDEN, "无权限");
    var recordCheck = scoreMapper.selectRecord(examId, studentId);
    if (recordCheck == null || recordCheck.getStatus() == null || recordCheck.getStatus() < 2) {
      throw new org.springframework.web.server.ResponseStatusException(org.springframework.http.HttpStatus.FORBIDDEN, "暂不可查看试卷");
    }
    if (e.getAllowReview() == null || e.getAllowReview() == 0) {
      throw new org.springframework.web.server.ResponseStatusException(org.springframework.http.HttpStatus.FORBIDDEN, "暂不可查看试卷");
    }
    var p = paperMapper.selectById(e.getPaperId());
    List<Map<String, Object>> qs = paperMapper.selectPaperQuestionViews(e.getPaperId());
    var record = scoreMapper.selectRecord(examId, studentId);
    List<org.example.chaoxingsystem.teacher.score.ExamAnswer> ansList = record != null ? scoreMapper.selectAnswersByRecordId(record.getId()) : java.util.Collections.emptyList();
    Map<Long, org.example.chaoxingsystem.teacher.score.ExamAnswer> ansMap = new java.util.HashMap<>();
    for (var a : ansList) { ansMap.put(a.getQuestionId(), a); }
    Map<String, Object> answers = new HashMap<>();
    List<Map<String, Object>> outQs = new java.util.ArrayList<>();
    for (Map<String, Object> m : qs) {
      Long qid = null;
      try { qid = Long.valueOf(String.valueOf(m.get("id"))); } catch (Exception ignored) {}
      String type = normalizeType(String.valueOf(m.get("type_code")));
      String content = m.get("content") != null ? String.valueOf(m.get("content")) : null;
      String options = m.get("options") != null ? String.valueOf(m.get("options")) : null;
      Integer score = null;
      Object sObj = m.get("score");
      if (sObj instanceof Number) score = ((Number) sObj).intValue();
      Object ansJson = m.get("answer");
      Object correct = null;
      try {
        if (ansJson != null) correct = objectMapper.readValue(String.valueOf(ansJson), Object.class);
      } catch (Exception ignored) {}
      Object normalizedCorrect;
      if ("multiple_choice".equals(type)) {
        if (correct instanceof java.util.List) {
          java.util.List<String> c = ((java.util.List<?>) correct).stream().map(String::valueOf).toList();
          java.util.List<String> sorted = new java.util.ArrayList<>(c);
          java.util.Collections.sort(sorted);
          normalizedCorrect = String.join(",", sorted);
        } else {
          normalizedCorrect = "";
        }
      } else if ("true_false".equals(type)) {
        boolean tf = false;
        if (correct instanceof Boolean) tf = (Boolean) correct;
        else if (correct != null) tf = "true".equalsIgnoreCase(String.valueOf(correct)) || "T".equalsIgnoreCase(String.valueOf(correct));
        normalizedCorrect = tf ? "T" : "F";
      } else {
        normalizedCorrect = correct != null ? String.valueOf(correct) : null;
      }
      Object studentAns = null;
      Integer givenScore = null;
      String comment = null;
      var a = qid != null ? ansMap.get(qid) : null;
      if (a != null) {
        try { studentAns = a.getStudentAnswer() != null ? objectMapper.readValue(a.getStudentAnswer(), Object.class) : null; } catch (Exception ignored) {}
        if ("multiple_choice".equals(type)) {
          if (studentAns instanceof java.util.List) {
            java.util.List<String> s = ((java.util.List<?>) studentAns).stream().map(String::valueOf).toList();
            java.util.List<String> sortedS = new java.util.ArrayList<>(s);
            java.util.Collections.sort(sortedS);
            studentAns = String.join(",", sortedS);
          }
          else studentAns = "";
        } else if ("true_false".equals(type)) {
          boolean tf2 = false;
          if (studentAns instanceof Boolean) tf2 = (Boolean) studentAns;
          else if (studentAns != null) tf2 = "true".equalsIgnoreCase(String.valueOf(studentAns)) || "T".equalsIgnoreCase(String.valueOf(studentAns));
          studentAns = tf2 ? "T" : "F";
        } else {
          studentAns = studentAns != null ? String.valueOf(studentAns) : null;
        }
        givenScore = a.getScore();
        comment = a.getComment();
      }
      if (qid != null) answers.put(String.valueOf(qid), studentAns);
      Map<String, Object> row = new HashMap<>();
      row.put("id", qid);
      row.put("type", type);
      row.put("content", content);
      row.put("options", options);
      row.put("score", score);
      row.put("answer", normalizedCorrect);
      row.put("analysis", m.get("analysis"));
      row.put("studentAnswer", studentAns);
      row.put("givenScore", givenScore);
      row.put("comment", comment);
      outQs.add(row);
    }
    Map<String, Object> data = new HashMap<>();
    data.put("paperId", p != null ? p.getId() : null);
    data.put("name", p != null ? p.getName() : null);
    data.put("subject", p != null ? p.getSubject() : null);
    data.put("questions", outQs);
    data.put("answers", answers);
    if (record != null) {
      Map<String, Object> rec = new HashMap<>();
      rec.put("score", record.getScore());
      rec.put("status", record.getStatus());
      rec.put("submitTime", record.getSubmitTime());
      data.put("record", rec);
    }
    return data;
  }
}
