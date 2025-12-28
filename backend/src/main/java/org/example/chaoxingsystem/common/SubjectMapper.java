package org.example.chaoxingsystem.common;

import org.apache.ibatis.annotations.Param;
import java.util.List;

/** 科目 Mapper */
public interface SubjectMapper {
  List<Subject> selectAll();
  List<Subject> selectByTeacherId(@Param("teacherId") Long teacherId);
  Subject selectById(@Param("id") Long id);
  Subject selectByCode(@Param("code") String code);
  int insert(Subject s);
  int updateById(Subject s);
  int deleteById(@Param("id") Long id);
}

