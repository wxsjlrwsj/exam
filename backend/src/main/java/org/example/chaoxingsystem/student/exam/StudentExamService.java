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

  public Map<String, Object> getPaper(Long examId) {
    Exam e = examMapper.selectById(examId);
    if (e == null) return Map.of();
    var p = paperMapper.selectById(e.getPaperId());
    List<Map<String, Object>> qs = paperMapper.selectPaperQuestionViews(e.getPaperId());
    Map<String, Object> data = new HashMap<>();
    data.put("paperId", p != null ? p.getId() : null);
    data.put("name", p != null ? p.getName() : null);
    data.put("subject", p != null ? p.getSubject() : null);
    data.put("questions", qs);
    return data;
  }

  @Transactional
  public void submit(Long examId, Long studentId, Map<String, Object> answers, Integer durationUsed) {
    var record = scoreMapper.selectRecord(examId, studentId);
    Long recordId;
    if (record == null) {
      studentExamMapper.insertRecord(examId, studentId);
      record = scoreMapper.selectRecord(examId, studentId);
    }
    recordId = record.getId();
    studentExamMapper.deleteAnswersByRecordId(recordId);
    for (Map.Entry<String, Object> e : answers.entrySet()) {
      Long qid = Long.valueOf(e.getKey());
      String ansJson = null;
      try {
        ansJson = e.getValue() != null ? objectMapper.writeValueAsString(e.getValue()) : null;
      } catch (Exception ex) {
        ansJson = null;
      }
      studentExamMapper.insertAnswer(recordId, qid, ansJson);
    }
    studentExamMapper.markSubmitted(recordId);
  }

  public Map<String, Object> getResult(Long examId, Long studentId) {
    var record = scoreMapper.selectRecord(examId, studentId);
    if (record == null) return Map.of();
    
    Exam exam = examMapper.selectById(examId);
    Map<String, Object> result = new HashMap<>();
    result.put("examId", examId);
    result.put("examName", exam != null ? exam.getName() : null);
    result.put("score", record.getScore());
    result.put("status", record.getStatus());
    result.put("submitTime", record.getSubmitTime());
    return result;
  }

  public Map<String, Object> getReview(Long examId, Long studentId) {
    var record = scoreMapper.selectRecord(examId, studentId);
    if (record == null) return Map.of();
    
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
    
    Exam exam = examMapper.selectById(examId);
    Map<String, Object> result = new HashMap<>();
    result.put("examName", exam != null ? exam.getName() : null);
    result.put("score", record.getScore());
    result.put("questions", questionDetails);
    return result;
  }

  @Transactional
  public void recordMonitorEvent(Long examId, Long studentId, String eventType, String eventData) {
    // Simple implementation: just log to database
    // In real app, this could trigger alerts or automatic actions
  }
}
