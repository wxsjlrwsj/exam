package org.example.chaoxingsystem.teacher.exam;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.Map;

/** 考生管理服务 */
@Service
public class ExamStudentService {
  private final ExamStudentMapper mapper;
  private final ExamMapper examMapper;

  public ExamStudentService(ExamStudentMapper mapper, ExamMapper examMapper) {
    this.mapper = mapper;
    this.examMapper = examMapper;
  }

  public long count(Long examId, String keyword) {
    return mapper.count(examId, keyword);
  }

  public List<Map<String, Object>> page(Long examId, String keyword, int page, int size) {
    int offset = (Math.max(page, 1) - 1) * Math.max(size, 1);
    return mapper.selectPage(examId, keyword, offset, size);
  }

  @Transactional
  public void addStudents(Long examId, List<Long> studentIds, List<Long> classIds) {
    // 检查考试是否存在
    Exam exam = examMapper.selectById(examId);
    if (exam == null) {
      throw new ResponseStatusException(HttpStatus.NOT_FOUND, "考试不存在");
    }

    // 添加指定学生
    if (studentIds != null && !studentIds.isEmpty()) {
      mapper.insertBatch(examId, studentIds);
    }

    // 添加班级学生
    if (classIds != null && !classIds.isEmpty()) {
      mapper.insertByClass(examId, classIds);
    }
  }

  @Transactional
  public void removeStudent(Long examId, Long userId) {
    int affected = mapper.deleteByExamAndUser(examId, userId);
    if (affected == 0) {
      throw new ResponseStatusException(HttpStatus.NOT_FOUND, "考生不存在");
    }
  }

  @Transactional
  public void batchRemove(Long examId, List<Long> userIds) {
    if (userIds == null || userIds.isEmpty()) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "学生ID列表不能为空");
    }
    mapper.deleteBatch(examId, userIds);
  }
}

