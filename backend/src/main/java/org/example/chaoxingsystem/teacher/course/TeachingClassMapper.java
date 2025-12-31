package org.example.chaoxingsystem.teacher.course;

import org.apache.ibatis.annotations.Param;
import java.util.List;
import java.util.Map;

public interface TeachingClassMapper {
  List<Map<String, Object>> selectByCourse(@Param("courseId") Long courseId);
  TeachingClass selectById(@Param("id") Long id);
  int insert(TeachingClass tc);
  int updateById(TeachingClass tc);
  int deleteById(@Param("id") Long id);
  int deleteByCourseId(@Param("courseId") Long courseId);
  List<Map<String, Object>> selectClassStudents(@Param("classId") Long classId);
  int insertClassStudent(@Param("classId") Long classId, @Param("userId") Long userId);
  int deleteClassStudent(@Param("classId") Long classId, @Param("userId") Long userId);
}
