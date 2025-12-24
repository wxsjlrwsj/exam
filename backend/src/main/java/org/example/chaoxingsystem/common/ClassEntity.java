package org.example.chaoxingsystem.common;

import java.time.Instant;

/** 班级实体 */
public class ClassEntity {
  private Long id;
  private String className;
  private String classCode;
  private String grade;
  private String major;
  private Long advisorId;
  private Instant createTime;

  public Long getId() { return id; }
  public void setId(Long id) { this.id = id; }
  
  public String getClassName() { return className; }
  public void setClassName(String className) { this.className = className; }
  
  public String getClassCode() { return classCode; }
  public void setClassCode(String classCode) { this.classCode = classCode; }
  
  public String getGrade() { return grade; }
  public void setGrade(String grade) { this.grade = grade; }
  
  public String getMajor() { return major; }
  public void setMajor(String major) { this.major = major; }
  
  public Long getAdvisorId() { return advisorId; }
  public void setAdvisorId(Long advisorId) { this.advisorId = advisorId; }
  
  public Instant getCreateTime() { return createTime; }
  public void setCreateTime(Instant createTime) { this.createTime = createTime; }
}

