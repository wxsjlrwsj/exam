package org.example.chaoxingsystem.common;

import org.springframework.stereotype.Service;
import java.util.List;

/** 科目管理服务 */
@Service
public class SubjectService {
  private final SubjectMapper mapper;

  public SubjectService(SubjectMapper mapper) {
    this.mapper = mapper;
  }

  public List<Subject> listAll() {
    return mapper.selectAll();
  }

  public Subject getById(Long id) {
    return mapper.selectById(id);
  }

  public Subject getByCode(String code) {
    return mapper.selectByCode(code);
  }
}

