package org.example.chaoxingsystem.student.error;

import org.apache.ibatis.annotations.Param;
import java.util.List;
import java.util.Map;

public interface StudentErrorMapper {
    long count(@Param("studentId") Long studentId, @Param("type") String type, @Param("keyword") String keyword);
    
    List<Map<String, Object>> selectPage(@Param("studentId") Long studentId,
                                         @Param("type") String type,
                                         @Param("keyword") String keyword,
                                         @Param("offset") int offset,
                                         @Param("limit") int limit);
    
    StudentError selectById(@Param("id") Long id);
    
    int insert(StudentError error);
    
    int incrementErrorCount(@Param("studentId") Long studentId, @Param("questionId") Long questionId);
    
    int deleteById(@Param("id") Long id);
    
    int markSolved(@Param("id") Long id);
    
    Map<String, Object> selectStats(@Param("studentId") Long studentId);
    
    int exists(@Param("studentId") Long studentId, @Param("questionId") Long questionId);
}

