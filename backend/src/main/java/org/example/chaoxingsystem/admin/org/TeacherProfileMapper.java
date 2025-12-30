package org.example.chaoxingsystem.admin.org;

import org.apache.ibatis.annotations.Param;

public interface TeacherProfileMapper {
  long countByCollegeId(@Param("collegeId") Long collegeId);
  Long countByUserId(@Param("userId") Long userId);
  Long countByUserIdAndCollegeId(@Param("userId") Long userId, @Param("collegeId") Long collegeId);
  Long selectIdByUserId(@Param("userId") Long userId);
  int updateCollegeIdByUserId(@Param("userId") Long userId, @Param("collegeId") Long collegeId);
  int insertTeacherProfile(@Param("userId") Long userId,
                           @Param("teacherNo") String teacherNo,
                           @Param("realName") String realName,
                           @Param("gender") Integer gender,
                           @Param("collegeId") Long collegeId,
                           @Param("title") String title,
                           @Param("enrollmentYear") Integer enrollmentYear);
}
