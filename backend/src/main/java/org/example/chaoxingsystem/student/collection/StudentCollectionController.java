package org.example.chaoxingsystem.student.collection;

import org.example.chaoxingsystem.user.UserService;
import org.example.chaoxingsystem.user.dto.ApiResponse;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/student/collections")
public class StudentCollectionController {
    private final StudentCollectionService collectionService;
    private final UserService userService;

    public StudentCollectionController(StudentCollectionService collectionService, UserService userService) {
        this.collectionService = collectionService;
        this.userService = userService;
    }

    @GetMapping
    @PreAuthorize("hasRole('STUDENT')")
    public ResponseEntity<ApiResponse<List<StudentCollection>>> list(Authentication auth) {
        var me = userService.getByUsername(auth.getName());
        collectionService.ensureDefaultCollection(me.getId());
        List<StudentCollection> list = collectionService.getByStudentId(me.getId());
        return ResponseEntity.ok(ApiResponse.success("获取成功", list));
    }

    @PostMapping
    @PreAuthorize("hasRole('STUDENT')")
    public ResponseEntity<ApiResponse<Long>> create(Authentication auth, @RequestBody Map<String, Object> body) {
        var me = userService.getByUsername(auth.getName());
        String name = (String) body.get("name");
        Long id = collectionService.create(me.getId(), name);
        return ResponseEntity.ok(ApiResponse.success("创建成功", id));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('STUDENT')")
    public ResponseEntity<ApiResponse<Void>> update(@PathVariable Long id, @RequestBody Map<String, Object> body) {
        String name = (String) body.get("name");
        collectionService.update(id, name);
        return ResponseEntity.ok(ApiResponse.success("更新成功", null));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('STUDENT')")
    public ResponseEntity<ApiResponse<Void>> delete(@PathVariable Long id) {
        collectionService.delete(id);
        return ResponseEntity.ok(ApiResponse.success("删除成功", null));
    }

    @GetMapping("/{id}/questions")
    @PreAuthorize("hasRole('STUDENT')")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getQuestions(
        @PathVariable Long id,
        @RequestParam(required = false) String type,
        @RequestParam(required = false) String subject,
        @RequestParam(defaultValue = "1") int page,
        @RequestParam(defaultValue = "10") int size
    ) {
        Map<String, Object> result = collectionService.getQuestions(id, type, subject, page, size);
        return ResponseEntity.ok(ApiResponse.success("获取成功", result));
    }

    @PostMapping("/{id}/questions")
    @PreAuthorize("hasRole('STUDENT')")
    public ResponseEntity<ApiResponse<Void>> addQuestion(@PathVariable Long id, @RequestBody Map<String, Object> body) {
        Long questionId = ((Number) body.get("questionId")).longValue();
        collectionService.addQuestion(id, questionId);
        return ResponseEntity.ok(ApiResponse.success("添加成功", null));
    }

    @DeleteMapping("/{id}/questions/{questionId}")
    @PreAuthorize("hasRole('STUDENT')")
    public ResponseEntity<ApiResponse<Void>> removeQuestion(@PathVariable Long id, @PathVariable Long questionId) {
        collectionService.removeQuestion(id, questionId);
        return ResponseEntity.ok(ApiResponse.success("移除成功", null));
    }
}

