package org.example.chaoxingsystem.student.quiz;

import org.example.chaoxingsystem.user.UserService;
import org.example.chaoxingsystem.user.dto.ApiResponse;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/student/quiz")
public class StudentQuizController {
    private final StudentQuizService quizService;
    private final UserService userService;

    public StudentQuizController(StudentQuizService quizService, UserService userService) {
        this.quizService = quizService;
        this.userService = userService;
    }

    @PostMapping("/start")
    @PreAuthorize("hasRole('STUDENT')")
    @SuppressWarnings("unchecked")
    public ResponseEntity<ApiResponse<Long>> start(Authentication auth, @RequestBody Map<String, Object> body) {
        var me = userService.getByUsername(auth.getName());
        Long collectionId = body.get("collectionId") != null ? ((Number) body.get("collectionId")).longValue() : null;
        String name = (String) body.get("name");
        List<Map<String, Object>> questions = (List<Map<String, Object>>) body.get("questions");
        Long quizId = quizService.startQuiz(me.getId(), collectionId, name, questions);
        return ResponseEntity.ok(ApiResponse.success("开始成功", quizId));
    }

    @PostMapping("/{quizId}/submit")
    @PreAuthorize("hasRole('STUDENT')")
    @SuppressWarnings("unchecked")
    public ResponseEntity<ApiResponse<Map<String, Object>>> submit(@PathVariable Long quizId, @RequestBody Map<String, Object> body) {
        Map<String, Object> answers = (Map<String, Object>) body.get("answers");
        Integer duration = body.get("duration") != null ? ((Number) body.get("duration")).intValue() : null;
        Map<String, Object> result = quizService.submitQuiz(quizId, answers, duration);
        return ResponseEntity.ok(ApiResponse.success("提交成功", result));
    }

    @GetMapping("/{quizId}/result")
    @PreAuthorize("hasRole('STUDENT')")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getResult(@PathVariable Long quizId) {
        Map<String, Object> result = quizService.getQuizResult(quizId);
        return ResponseEntity.ok(ApiResponse.success("获取成功", result));
    }
}

