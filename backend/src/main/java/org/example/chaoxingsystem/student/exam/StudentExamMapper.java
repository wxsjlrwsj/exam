package org.example.chaoxingsystem.student.exam;

import org.apache.ibatis.annotations.Param;

public interface StudentExamMapper {
  int insertRecord(@Param("examId") Long examId, @Param("studentId") Long studentId);
  int markSubmitted(@Param("recordId") Long recordId);
  int deleteAnswersByRecordId(@Param("recordId") Long recordId);
  int insertAnswer(@Param("recordId") Long recordId, @Param("questionId") Long questionId, @Param("studentAnswer") String studentAnswer);
  int insertCameraSnapshot(@Param("examId") Long examId, @Param("studentId") Long studentId, @Param("imageData") byte[] imageData, @Param("contentType") String contentType);
  int createCameraSnapshotTableIfNotExists();
  int insertStartRecord(@Param("examId") Long examId, @Param("studentId") Long studentId);
  int markStarted(@Param("recordId") Long recordId);
  int incrementSwitchCount(@Param("examId") Long examId, @Param("studentId") Long studentId);
  int updateLastActiveTime(@Param("examId") Long examId, @Param("studentId") Long studentId);
  int updateProgress(@Param("examId") Long examId, @Param("studentId") Long studentId, @Param("progress") Integer progress);
  int insertMonitorEvent(@Param("examId") Long examId, @Param("studentId") Long studentId, @Param("eventType") String eventType, @Param("eventData") String eventData, @Param("severity") String severity);
}
