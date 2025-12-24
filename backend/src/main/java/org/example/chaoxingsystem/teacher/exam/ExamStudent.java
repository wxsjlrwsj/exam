package org.example.chaoxingsystem.teacher.exam;

import java.time.Instant;

/** 考试-学生关联实体 */
public class ExamStudent {
  private Long id;
  private Long examId;
  private Long userId;
  private String status;
  private Instant addTime;

  public Long getId() { return id; }
  public void setId(Long id) { this.id = id; }
  
  public Long getExamId() { return examId; }
  public void setExamId(Long examId) { this.examId = examId; }
  
  public Long getUserId() { return userId; }
  public void setUserId(Long userId) { this.userId = userId; }
  
  public String getStatus() { return status; }
  public void setStatus(String status) { this.status = status; }
  
  public Instant getAddTime() { return addTime; }
  public void setAddTime(Instant addTime) { this.addTime = addTime; }
}

