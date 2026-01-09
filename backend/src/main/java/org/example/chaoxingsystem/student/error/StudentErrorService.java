package org.example.chaoxingsystem.student.error;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class StudentErrorService {
    private final StudentErrorMapper errorMapper;

    public StudentErrorService(StudentErrorMapper errorMapper) {
        this.errorMapper = errorMapper;
    }

    public Map<String, Object> getErrors(Long studentId, String type, String keyword, int page, int size) {
        int offset = (page - 1) * size;
        long total = errorMapper.count(studentId, type, keyword);
        List<Map<String, Object>> list = errorMapper.selectPage(studentId, type, keyword, offset, size);
        
        Map<String, Object> result = new HashMap<>();
        result.put("list", list);
        result.put("total", total);
        return result;
    }

    public StudentError getById(Long id) {
        return errorMapper.selectById(id);
    }

    @Transactional
    public void addError(Long studentId, Long questionId, Long examId, String studentAnswer, String correctAnswer) {
        if (errorMapper.exists(studentId, questionId) > 0) {
            errorMapper.incrementErrorCount(studentId, questionId);
        } else {
            StudentError error = new StudentError();
            error.setStudentId(studentId);
            error.setQuestionId(questionId);
            error.setExamId(examId);
            error.setErrorCount(1);
            error.setIsSolved(false);
            error.setStudentAnswer(studentAnswer);
            error.setCorrectAnswer(correctAnswer);
            errorMapper.insert(error);
        }
    }

    public void removeError(Long id) {
        errorMapper.deleteById(id);
    }

    public void markSolved(Long id) {
        errorMapper.markSolved(id);
    }

    public Map<String, Object> getStats(Long studentId) {
        Map<String, Object> stats = errorMapper.selectStats(studentId);
        if (stats == null) {
            stats = new HashMap<>();
            stats.put("total", 0L);
            stats.put("solved", 0L);
            stats.put("unsolved", 0L);
        }
        return stats;
    }
}

