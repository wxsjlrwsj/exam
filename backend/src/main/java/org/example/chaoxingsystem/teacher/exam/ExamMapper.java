package org.example.chaoxingsystem.teacher.exam;

import org.apache.ibatis.annotations.Param;
import java.util.List;
import java.util.Map;

/** 考试 Mapper */
public interface ExamMapper {
  long count(@Param("status") Integer status);
  List<Exam> selectPage(@Param("status") Integer status, @Param("offset") int offset, @Param("limit") int limit);
  long countByPaperSubject(@Param("subject") String subject);
  List<Exam> selectPageByPaperSubject(@Param("subject") String subject, @Param("offset") int offset, @Param("limit") int limit);
  int insert(Exam e);
  int updateById(Exam e);
  Exam selectById(@Param("id") Long id);
  int deleteById(@Param("id") Long id);
  
  // 考试统计
  long countExamStudents(@Param("examId") Long examId);
  long countSubmittedStudents(@Param("examId") Long examId);
  long countGradedStudents(@Param("examId") Long examId);
  
  // 监考相关
  List<java.util.Map<String, Object>> selectMonitorStudents(@Param("examId") Long examId);
  int insertWarning(@Param("examId") Long examId, @Param("studentId") Long studentId, 
                    @Param("message") String message, @Param("type") String type, 
                    @Param("teacherId") Long teacherId);
  int forceSubmitExamRecord(@Param("examId") Long examId, @Param("studentId") Long studentId);
  int createCameraSnapshotTableIfNotExists();
  
  long countByStudent(@Param("studentId") Long studentId, @Param("status") Integer status);
  java.util.List<Exam> selectPageByStudent(@Param("studentId") Long studentId, @Param("status") Integer status, @Param("offset") int offset, @Param("limit") int limit);
  long existsStudentAssignment(@Param("examId") Long examId, @Param("studentId") Long studentId);
  java.util.List<java.util.Map<String, Object>> selectPageByStudentWithSubject(
    @Param("studentId") Long studentId,
    @Param("status") Integer status,
    @Param("subject") String subject,
    @Param("semester") String semester,
    @Param("offset") int offset,
    @Param("limit") int limit
  );
  long countByStudentWithFilters(
    @Param("studentId") Long studentId,
    @Param("status") Integer status,
    @Param("subject") String subject,
    @Param("semester") String semester
  );
}
