package org.example.chaoxingsystem.common;

import org.apache.ibatis.annotations.Param;
import java.util.List;
import java.util.Map;

/** 班级 Mapper */
public interface ClassMapper {
  long count(@Param("keyword") String keyword);
  
  List<Map<String, Object>> selectPage(
    @Param("keyword") String keyword,
    @Param("offset") int offset, 
    @Param("limit") int limit
  );
  
  List<Map<String, Object>> selectAll();
  
  ClassEntity selectById(@Param("id") Long id);
  
  List<Map<String, Object>> selectClassStudents(@Param("classId") Long classId);
  
  int insert(ClassEntity c);
  
  int updateById(ClassEntity c);
  
  int deleteById(@Param("id") Long id);
}

