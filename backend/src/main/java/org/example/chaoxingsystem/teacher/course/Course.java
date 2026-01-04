package org.example.chaoxingsystem.teacher.course;

import java.time.Instant;

public class Course {
  private Long id;
  private String name;
  private String description;
  private Long creatorId;
  private Instant createTime;

  public Long getId() { return id; }
  public void setId(Long id) { this.id = id; }
  public String getName() { return name; }
  public void setName(String name) { this.name = name; }
  public String getDescription() { return description; }
  public void setDescription(String description) { this.description = description; }
  public Long getCreatorId() { return creatorId; }
  public void setCreatorId(Long creatorId) { this.creatorId = creatorId; }
  public Instant getCreateTime() { return createTime; }
  public void setCreateTime(Instant createTime) { this.createTime = createTime; }
}
