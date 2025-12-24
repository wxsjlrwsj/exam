package org.example.chaoxingsystem.teacher.exam;

import org.apache.ibatis.annotations.Param;
import java.util.List;
import java.util.Map;

/** 考试 Mapper */
public interface ExamMapper {
  long count(@Param("status") Integer status);
  List<Exam> selectPage(@Param("status") Integer status, @Param("offset") int offset, @Param("limit") int limit);
  int insert(Exam e);
  int updateById(Exam e);
  Exam selectById(@Param("id") Long id);
  int deleteById(@Param("id") Long id);
  
  // 考试统计
  long countExamStudents(@Param("examId") Long examId);
  long countSubmittedStudents(@Param("examId") Long examId);
  long countGradedStudents(@Param("examId") Long examId);
  
  // 监考相关
  List<Map<String, Object>> selectMonitorStudents(@Param("examId") Long examId);
  int insertWarning(@Param("examId") Long examId, @Param("studentId") Long studentId, 
                    @Param("message") String message, @Param("type") String type, 
                    @Param("teacherId") Long teacherId);
  int forceSubmitExamRecord(@Param("examId") Long examId, @Param("studentId") Long studentId);
}

