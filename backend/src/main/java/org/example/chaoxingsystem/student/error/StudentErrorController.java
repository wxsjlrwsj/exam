package org.example.chaoxingsystem.student.error;

import org.example.chaoxingsystem.user.UserService;
import org.example.chaoxingsystem.user.dto.ApiResponse;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/student/errors")
public class StudentErrorController {
    private final StudentErrorService errorService;
    private final UserService userService;

    public StudentErrorController(StudentErrorService errorService, UserService userService) {
        this.errorService = errorService;
        this.userService = userService;
    }

    @GetMapping
    @PreAuthorize("hasRole('STUDENT')")
    public ResponseEntity<ApiResponse<Map<String, Object>>> list(
        Authentication auth,
        @RequestParam(required = false) String type,
        @RequestParam(required = false) String keyword,
        @RequestParam(defaultValue = "1") int page,
        @RequestParam(defaultValue = "10") int size
    ) {
        var me = userService.getByUsername(auth.getName());
        Map<String, Object> result = errorService.getErrors(me.getId(), type, keyword, page, size);
        return ResponseEntity.ok(ApiResponse.success("获取成功", result));
    }

    @GetMapping("/stats")
    @PreAuthorize("hasRole('STUDENT')")
    public ResponseEntity<ApiResponse<Map<String, Object>>> stats(Authentication auth) {
        var me = userService.getByUsername(auth.getName());
        Map<String, Object> stats = errorService.getStats(me.getId());
        return ResponseEntity.ok(ApiResponse.success("获取成功", stats));
    }

    @PostMapping
    @PreAuthorize("hasRole('STUDENT')")
    public ResponseEntity<ApiResponse<Void>> add(Authentication auth, @RequestBody Map<String, Object> body) {
        var me = userService.getByUsername(auth.getName());
        Long questionId = ((Number) body.get("questionId")).longValue();
        Long examId = body.get("examId") != null ? ((Number) body.get("examId")).longValue() : null;
        String studentAnswer = (String) body.get("studentAnswer");
        String correctAnswer = (String) body.get("correctAnswer");
        errorService.addError(me.getId(), questionId, examId, studentAnswer, correctAnswer);
        return ResponseEntity.ok(ApiResponse.success("添加成功", null));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('STUDENT')")
    public ResponseEntity<ApiResponse<Void>> remove(@PathVariable Long id) {
        errorService.removeError(id);
        return ResponseEntity.ok(ApiResponse.success("删除成功", null));
    }

    @PutMapping("/{id}/solve")
    @PreAuthorize("hasRole('STUDENT')")
    public ResponseEntity<ApiResponse<Void>> markSolved(@PathVariable Long id) {
        errorService.markSolved(id);
        return ResponseEntity.ok(ApiResponse.success("标记成功", null));
    }
}

