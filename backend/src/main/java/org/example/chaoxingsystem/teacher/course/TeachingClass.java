package org.example.chaoxingsystem.teacher.course;

import java.time.Instant;

public class TeachingClass {
  private Long id;
  private Long courseId;
  private String name;
  private Long assignedTeacherId;
  private Instant createTime;
  private String academicYear;
  private String semester;

  public Long getId() { return id; }
  public void setId(Long id) { this.id = id; }
  public Long getCourseId() { return courseId; }
  public void setCourseId(Long courseId) { this.courseId = courseId; }
  public String getName() { return name; }
  public void setName(String name) { this.name = name; }
  public Long getAssignedTeacherId() { return assignedTeacherId; }
  public void setAssignedTeacherId(Long assignedTeacherId) { this.assignedTeacherId = assignedTeacherId; }
  public Instant getCreateTime() { return createTime; }
  public void setCreateTime(Instant createTime) { this.createTime = createTime; }
  public String getAcademicYear() { return academicYear; }
  public void setAcademicYear(String academicYear) { this.academicYear = academicYear; }
  public String getSemester() { return semester; }
  public void setSemester(String semester) { this.semester = semester; }
}
