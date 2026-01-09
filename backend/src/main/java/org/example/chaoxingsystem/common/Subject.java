package org.example.chaoxingsystem.common;

import java.time.Instant;

/** 科目实体 */
public class Subject {
  private Long id;
  private String name;
  private String code;
  private String description;
  private Instant createTime;

  public Long getId() { return id; }
  public void setId(Long id) { this.id = id; }
  
  public String getName() { return name; }
  public void setName(String name) { this.name = name; }
  
  public String getCode() { return code; }
  public void setCode(String code) { this.code = code; }
  
  public String getDescription() { return description; }
  public void setDescription(String description) { this.description = description; }
  
  public Instant getCreateTime() { return createTime; }
  public void setCreateTime(Instant createTime) { this.createTime = createTime; }
}

