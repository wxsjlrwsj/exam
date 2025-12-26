package org.example.chaoxingsystem.student.practice;

import org.example.chaoxingsystem.teacher.bank.Question;
import org.example.chaoxingsystem.teacher.bank.QuestionMapper;
import org.example.chaoxingsystem.teacher.bank.QuestionService;
import org.example.chaoxingsystem.user.dto.ApiResponse;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/student/practice")
public class StudentPracticeController {
    private final QuestionService questionService;
    private final QuestionMapper questionMapper;

    public StudentPracticeController(QuestionService questionService, QuestionMapper questionMapper) {
        this.questionService = questionService;
        this.questionMapper = questionMapper;
    }

    @GetMapping("/questions")
    @PreAuthorize("hasRole('STUDENT')")
    public ResponseEntity<ApiResponse<Map<String, Object>>> listQuestions(
        @RequestParam(required = false) String type,
        @RequestParam(required = false) String subject,
        @RequestParam(required = false) String difficulty,
        @RequestParam(required = false) String keyword,
        @RequestParam(defaultValue = "1") int page,
        @RequestParam(defaultValue = "10") int size
    ) {
        // Students can only see published questions
        Integer diff = difficulty != null ? Integer.valueOf(difficulty) : null;
        long total = questionService.count(type, keyword, diff, subject);
        List<Question> list = questionService.page(type, keyword, diff, subject, page, size);
        
        Map<String, Object> result = new HashMap<>();
        result.put("list", list);
        result.put("total", total);
        return ResponseEntity.ok(ApiResponse.success("获取成功", result));
    }

    @GetMapping("/questions/{id}")
    @PreAuthorize("hasRole('STUDENT')")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getQuestion(@PathVariable Long id) {
        Question question = questionMapper.selectById(id);
        if (question == null) {
            return ResponseEntity.badRequest().body(ApiResponse.error(404, "题目不存在"));
        }
        return ResponseEntity.ok(ApiResponse.success("获取成功", Map.of("question", question)));
    }
}


