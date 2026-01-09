package org.example.chaoxingsystem.student.collection;

import org.apache.ibatis.annotations.Param;
import java.util.List;
import java.util.Map;

public interface CollectionQuestionMapper {
    long countByCollection(@Param("collectionId") Long collectionId, 
                           @Param("type") String type, 
                           @Param("subject") String subject);
    
    List<Map<String, Object>> selectQuestionsByCollection(@Param("collectionId") Long collectionId,
                                                          @Param("type") String type,
                                                          @Param("subject") String subject,
                                                          @Param("offset") int offset,
                                                          @Param("limit") int limit);
    
    int insert(@Param("collectionId") Long collectionId, @Param("questionId") Long questionId);
    
    int delete(@Param("collectionId") Long collectionId, @Param("questionId") Long questionId);
    
    int deleteByCollection(@Param("collectionId") Long collectionId);
    
    int exists(@Param("collectionId") Long collectionId, @Param("questionId") Long questionId);
}

