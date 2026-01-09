package org.example.chaoxingsystem.teacher.course;

import org.apache.ibatis.annotations.Param;
import java.util.List;
import java.util.Map;

public interface CourseMapper {
  List<Map<String, Object>> selectByTeacher(@Param("teacherId") Long teacherId);
  Course selectById(@Param("id") Long id);
  Course selectByName(@Param("name") String name);
  int insert(Course c);
  int updateById(Course c);
  int deleteById(@Param("id") Long id);
  List<Map<String, Object>> selectCourseTeachers(@Param("courseId") Long courseId);
  int insertCourseTeacher(@Param("courseId") Long courseId, @Param("teacherId") Long teacherId);
  int deleteCourseTeacher(@Param("courseId") Long courseId, @Param("teacherId") Long teacherId);
  int deleteCourseTeachersByCourse(@Param("courseId") Long courseId);
}
