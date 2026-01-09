package org.example.chaoxingsystem.student.quiz;

import org.apache.ibatis.annotations.Param;
import java.util.List;
import java.util.Map;

public interface StudentQuizMapper {
    int insert(StudentQuiz quiz);
    StudentQuiz selectById(@Param("id") Long id);
    int updateScore(@Param("id") Long id, @Param("score") Integer score, 
                    @Param("totalScore") Integer totalScore, @Param("duration") Integer duration);
    int markCompleted(@Param("id") Long id);
    
    int insertAnswer(@Param("quizId") Long quizId, @Param("questionId") Long questionId,
                    @Param("studentAnswer") String studentAnswer, @Param("isCorrect") Boolean isCorrect,
                    @Param("score") Integer score);
    
    List<Map<String, Object>> selectAnswers(@Param("quizId") Long quizId);
}

