package org.example.chaoxingsystem.common;

import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

/** 班级管理服务 */
@Service
public class ClassService {
  private final ClassMapper mapper;

  public ClassService(ClassMapper mapper) {
    this.mapper = mapper;
  }

  public long count(String keyword) {
    return mapper.count(keyword);
  }

  public List<Map<String, Object>> page(String keyword, int page, int size) {
    int offset = (Math.max(page, 1) - 1) * Math.max(size, 1);
    return mapper.selectPage(keyword, offset, size);
  }

  public List<Map<String, Object>> listAll() {
    return mapper.selectAll();
  }

  public List<Map<String, Object>> getClassStudents(Long classId) {
    return mapper.selectClassStudents(classId);
  }
}

