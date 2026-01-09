package org.example.chaoxingsystem.student.errorbook;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * 错题本服务类
 */
@Service
public class ErrorBookService {
    
    private final ErrorBookMapper errorBookMapper;
    
    public ErrorBookService(ErrorBookMapper errorBookMapper) {
        this.errorBookMapper = errorBookMapper;
    }
    
    /**
     * 获取错题列表（分页）
     */
    public Map<String, Object> getErrorList(
        Long studentId,
        Integer typeId,
        String keyword,
        Integer mastered,
        int page,
        int size
    ) {
        int offset = (page - 1) * size;
        List<Map<String, Object>> list = errorBookMapper.selectErrorList(
            studentId, typeId, keyword, mastered, offset, size
        );
        long total = errorBookMapper.countErrors(studentId, typeId, keyword, mastered);
        
        return Map.of(
            "list", list,
            "total", total,
            "page", page,
            "size", size
        );
    }
    
    /**
     * 添加错题到错题本
     * 如果已存在，则增加错误次数
     */
    @Transactional
    public void addErrorQuestion(Long studentId, Long questionId, Long examId, String wrongAnswer) {
        ErrorBook existing = errorBookMapper.selectByStudentAndQuestion(studentId, questionId);
        
        if (existing != null) {
            // 如果已存在，增加错误次数并更新时间
            errorBookMapper.incrementWrongCount(studentId, questionId);
            // 可选：更新错误答案
            if (wrongAnswer != null) {
                existing.setWrongAnswer(wrongAnswer);
                existing.setLastWrongTime(LocalDateTime.now());
                errorBookMapper.update(existing);
            }
        } else {
            // 新增错题记录
            ErrorBook errorBook = new ErrorBook();
            errorBook.setStudentId(studentId);
            errorBook.setQuestionId(questionId);
            errorBook.setExamId(examId);
            errorBook.setWrongAnswer(wrongAnswer);
            errorBook.setWrongCount(1);
            errorBook.setMastered(0);
            errorBook.setLastWrongTime(LocalDateTime.now());
            errorBookMapper.insert(errorBook);
        }
    }
    
    /**
     * 标记题目为已掌握/未掌握
     */
    @Transactional
    public void toggleMastered(Long id, boolean mastered) {
        errorBookMapper.markAsMastered(id, mastered ? 1 : 0);
    }
    
    /**
     * 移除错题
     */
    @Transactional
    public void removeError(Long id) {
        errorBookMapper.deleteById(id);
    }
    
    /**
     * 批量移除错题
     */
    @Transactional
    public void batchRemove(List<Long> ids) {
        if (ids != null && !ids.isEmpty()) {
            errorBookMapper.batchDelete(ids);
        }
    }
    
    /**
     * 获取错题详情
     */
    public Map<String, Object> getErrorDetail(Long studentId, Long errorId) {
        // 可以扩展实现详细信息查询
        List<Map<String, Object>> list = errorBookMapper.selectErrorList(
            studentId, null, null, null, 0, 1
        );
        return list.isEmpty() ? null : list.get(0);
    }
}

