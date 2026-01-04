package org.example.chaoxingsystem.admin.org;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface ClassTeacherMapper {
  Long countByClassAndTeacher(@Param("classId") Long classId, @Param("teacherId") Long teacherId);
  int insertMapping(@Param("classId") Long classId, @Param("teacherId") Long teacherId);
  int deleteMapping(@Param("classId") Long classId, @Param("teacherId") Long teacherId);
  int deleteByClassIdAndTeacherIds(@Param("classId") Long classId, @Param("teacherIds") java.util.List<Long> teacherIds);
}
