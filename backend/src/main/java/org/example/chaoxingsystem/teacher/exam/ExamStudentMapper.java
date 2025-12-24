package org.example.chaoxingsystem.teacher.exam;

import org.apache.ibatis.annotations.Param;
import java.util.List;
import java.util.Map;

/** 考试学生 Mapper */
public interface ExamStudentMapper {
  long count(@Param("examId") Long examId, @Param("keyword") String keyword);
  
  List<Map<String, Object>> selectPage(
    @Param("examId") Long examId, 
    @Param("keyword") String keyword,
    @Param("offset") int offset, 
    @Param("limit") int limit
  );
  
  int insert(ExamStudent es);
  
  int insertBatch(@Param("examId") Long examId, @Param("userIds") List<Long> userIds);
  
  int insertByClass(@Param("examId") Long examId, @Param("classIds") List<Long> classIds);
  
  int deleteByExamAndUser(@Param("examId") Long examId, @Param("userId") Long userId);
  
  int deleteBatch(@Param("examId") Long examId, @Param("userIds") List<Long> userIds);
  
  ExamStudent selectByExamAndUser(@Param("examId") Long examId, @Param("userId") Long userId);
}

