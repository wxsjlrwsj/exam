package org.example.chaoxingsystem.student.errorbook;

import org.example.chaoxingsystem.user.UserService;
import org.example.chaoxingsystem.user.dto.ApiResponse;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 错题本控制器
 */
@RestController
@RequestMapping("/api/student/error-book")
public class ErrorBookController {
    
    private final ErrorBookService errorBookService;
    private final UserService userService;
    
    public ErrorBookController(ErrorBookService errorBookService, UserService userService) {
        this.errorBookService = errorBookService;
        this.userService = userService;
    }
    
    /**
     * 获取错题列表（分页）
     */
    @GetMapping
    @PreAuthorize("hasRole('STUDENT')")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getErrorList(
        Authentication auth,
        @RequestParam(value = "typeId", required = false) Integer typeId,
        @RequestParam(value = "keyword", required = false) String keyword,
        @RequestParam(value = "mastered", required = false) Integer mastered,
        @RequestParam(value = "page", defaultValue = "1") int page,
        @RequestParam(value = "size", defaultValue = "10") int size
    ) {
        var user = userService.getByUsername(auth.getName());
        Map<String, Object> data = errorBookService.getErrorList(
            user.getId(), typeId, keyword, mastered, page, size
        );
        return ResponseEntity.ok(ApiResponse.success("获取成功", data));
    }
    
    /**
     * 添加错题到错题本
     */
    @PostMapping
    @PreAuthorize("hasRole('STUDENT')")
    public ResponseEntity<ApiResponse<Void>> addError(
        Authentication auth,
        @RequestBody Map<String, Object> body
    ) {
        var user = userService.getByUsername(auth.getName());
        
        Long questionId = body.get("questionId") instanceof Number 
            ? ((Number) body.get("questionId")).longValue() 
            : null;
        
        Long examId = body.get("examId") instanceof Number 
            ? ((Number) body.get("examId")).longValue() 
            : null;
        
        String wrongAnswer = body.get("wrongAnswer") != null 
            ? body.get("wrongAnswer").toString() 
            : null;
        
        if (questionId == null) {
            return ResponseEntity.badRequest()
                .body(ApiResponse.error(400, "题目ID不能为空"));
        }
        
        errorBookService.addErrorQuestion(user.getId(), questionId, examId, wrongAnswer);
        return ResponseEntity.ok(ApiResponse.success("添加成功", null));
    }
    
    /**
     * 标记为已掌握/未掌握
     */
    @PutMapping("/{id}/mastered")
    @PreAuthorize("hasRole('STUDENT')")
    public ResponseEntity<ApiResponse<Void>> toggleMastered(
        @PathVariable Long id,
        @RequestBody Map<String, Object> body
    ) {
        Boolean mastered = body.get("mastered") instanceof Boolean 
            ? (Boolean) body.get("mastered") 
            : false;
        
        errorBookService.toggleMastered(id, mastered);
        return ResponseEntity.ok(ApiResponse.success("更新成功", null));
    }
    
    /**
     * 移除错题
     */
    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('STUDENT')")
    public ResponseEntity<ApiResponse<Void>> removeError(@PathVariable Long id) {
        errorBookService.removeError(id);
        return ResponseEntity.ok(ApiResponse.success("移除成功", null));
    }
    
    /**
     * 批量移除错题
     */
    @PostMapping("/batch-delete")
    @PreAuthorize("hasRole('STUDENT')")
    public ResponseEntity<ApiResponse<Void>> batchRemove(
        @RequestBody Map<String, Object> body
    ) {
        @SuppressWarnings("unchecked")
        List<Number> ids = (List<Number>) body.get("ids");
        
        if (ids == null || ids.isEmpty()) {
            return ResponseEntity.badRequest()
                .body(ApiResponse.error(400, "请选择要删除的错题"));
        }
        
        List<Long> idList = ids.stream()
            .map(Number::longValue)
            .toList();
        
        errorBookService.batchRemove(idList);
        return ResponseEntity.ok(ApiResponse.success("批量删除成功", null));
    }
}

