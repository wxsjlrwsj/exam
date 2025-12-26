package org.example.chaoxingsystem.student.collection;

import org.apache.ibatis.annotations.Param;
import java.util.List;

public interface StudentCollectionMapper {
    List<StudentCollection> selectByStudentId(@Param("studentId") Long studentId);
    StudentCollection selectById(@Param("id") Long id);
    int insert(StudentCollection collection);
    int updateById(StudentCollection collection);
    int deleteById(@Param("id") Long id);
    int incrementQuestionCount(@Param("id") Long id);
    int decrementQuestionCount(@Param("id") Long id);
}

