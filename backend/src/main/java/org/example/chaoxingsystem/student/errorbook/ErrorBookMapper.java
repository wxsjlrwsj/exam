package org.example.chaoxingsystem.student.errorbook;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

/**
 * 错题本Mapper接口
 */
@Mapper
public interface ErrorBookMapper {
    
    /**
     * 查询学生错题列表
     */
    List<Map<String, Object>> selectErrorList(
        @Param("studentId") Long studentId,
        @Param("typeId") Integer typeId,
        @Param("keyword") String keyword,
        @Param("mastered") Integer mastered,
        @Param("offset") int offset,
        @Param("limit") int limit
    );
    
    /**
     * 统计学生错题总数
     */
    long countErrors(
        @Param("studentId") Long studentId,
        @Param("typeId") Integer typeId,
        @Param("keyword") String keyword,
        @Param("mastered") Integer mastered
    );
    
    /**
     * 根据学生ID和题目ID查询错题记录
     */
    ErrorBook selectByStudentAndQuestion(
        @Param("studentId") Long studentId,
        @Param("questionId") Long questionId
    );
    
    /**
     * 插入错题记录
     */
    int insert(ErrorBook errorBook);
    
    /**
     * 更新错题记录
     */
    int update(ErrorBook errorBook);
    
    /**
     * 增加错误次数
     */
    int incrementWrongCount(
        @Param("studentId") Long studentId,
        @Param("questionId") Long questionId
    );
    
    /**
     * 标记为已掌握
     */
    int markAsMastered(
        @Param("id") Long id,
        @Param("mastered") Integer mastered
    );
    
    /**
     * 删除错题记录
     */
    int deleteById(@Param("id") Long id);
    
    /**
     * 批量删除错题记录
     */
    int batchDelete(@Param("ids") List<Long> ids);
}

