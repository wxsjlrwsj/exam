package org.example.chaoxingsystem.student.quiz;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class StudentQuizService {
    private final StudentQuizMapper quizMapper;
    private final ObjectMapper objectMapper = new ObjectMapper();

    public StudentQuizService(StudentQuizMapper quizMapper) {
        this.quizMapper = quizMapper;
    }

    @Transactional
    public Long startQuiz(Long studentId, Long collectionId, String name, List<Map<String, Object>> questions) {
        StudentQuiz quiz = new StudentQuiz();
        quiz.setStudentId(studentId);
        quiz.setCollectionId(collectionId);
        quiz.setName(name);
        quiz.setQuestionCount(questions.size());
        quiz.setStatus(0);
        quizMapper.insert(quiz);
        return quiz.getId();
    }

    @Transactional
    public Map<String, Object> submitQuiz(Long quizId, Map<String, Object> answers, Integer duration) {
        List<Map<String, Object>> questionAnswers = quizMapper.selectAnswers(quizId);
        
        int totalScore = 0;
        int earnedScore = 0;
        int correctCount = 0;

        for (Map<String, Object> qa : questionAnswers) {
            Long qid = ((Number) qa.get("questionId")).longValue();
            String correctAnswer = (String) qa.get("answer");
            String type = (String) qa.get("type");
            
            Object studentAns = answers.get(String.valueOf(qid));
            String studentAnswerStr = null;
            try {
                studentAnswerStr = studentAns != null ? objectMapper.writeValueAsString(studentAns) : null;
            } catch (Exception e) {
                studentAnswerStr = studentAns != null ? studentAns.toString() : null;
            }

            int questionScore = 10; // Default score
            boolean isCorrect = checkAnswer(type, studentAns, correctAnswer);
            int score = isCorrect ? questionScore : 0;

            totalScore += questionScore;
            earnedScore += score;
            if (isCorrect) correctCount++;

            quizMapper.insertAnswer(quizId, qid, studentAnswerStr, isCorrect, score);
        }

        quizMapper.updateScore(quizId, earnedScore, totalScore, duration);
        quizMapper.markCompleted(quizId);

        Map<String, Object> result = new HashMap<>();
        result.put("score", earnedScore);
        result.put("totalScore", totalScore);
        result.put("accuracy", totalScore > 0 ? (correctCount * 100.0 / questionAnswers.size()) : 0);
        return result;
    }

    public Map<String, Object> getQuizResult(Long quizId) {
        StudentQuiz quiz = quizMapper.selectById(quizId);
        List<Map<String, Object>> answers = quizMapper.selectAnswers(quizId);
        
        Map<String, Object> result = new HashMap<>();
        result.put("quiz", quiz);
        result.put("answers", answers);
        return result;
    }

    private boolean checkAnswer(String type, Object studentAnswer, String correctAnswer) {
        if (studentAnswer == null || correctAnswer == null) return false;
        
        String studentStr = studentAnswer.toString().trim();
        String correctStr = correctAnswer.trim();

        if ("single_choice".equals(type) || "true_false".equals(type)) {
            return studentStr.equalsIgnoreCase(correctStr);
        } else if ("multiple_choice".equals(type)) {
            // Handle array or comma-separated string
            return studentStr.equals(correctStr);
        }
        
        return studentStr.equalsIgnoreCase(correctStr);
    }
}

