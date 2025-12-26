package org.example.chaoxingsystem.student.profile;

import org.example.chaoxingsystem.user.UserService;
import org.example.chaoxingsystem.user.dto.ApiResponse;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;
import org.example.chaoxingsystem.admin.org.StudentProfileMapper;
import org.example.chaoxingsystem.admin.org.OrganizationMapper;

@RestController
@RequestMapping("/api/student/profile")
public class StudentProfileController {
    private final UserService userService;
    private final StudentProfileMapper studentProfileMapper;
    private final OrganizationMapper organizationMapper;

    public StudentProfileController(UserService userService, StudentProfileMapper studentProfileMapper, OrganizationMapper organizationMapper) {
        this.userService = userService;
        this.studentProfileMapper = studentProfileMapper;
        this.organizationMapper = organizationMapper;
    }

    @GetMapping
    @PreAuthorize("hasRole('STUDENT')")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getProfile(Authentication auth) {
        var me = userService.getByUsername(auth.getName());
        Map<String, Object> profile = new HashMap<>();
        profile.put("id", me.getId());
        profile.put("username", me.getUsername());
        profile.put("name", me.getRealName());
        profile.put("email", me.getEmail());
        profile.put("phone", me.getPhone());
        profile.put("avatar", me.getAvatar());
        profile.put("bio", me.getBio());
        profile.put("registerTime", me.getCreatedAt());
        var stu = studentProfileMapper.selectByUserId(me.getId());
        if (stu != null) {
            profile.put("studentNo", stu.get("student_no"));
            Object classIdObj = stu.get("class_id");
            if (classIdObj instanceof Number) {
                Long classId = ((Number) classIdObj).longValue();
                var org = organizationMapper.selectById(classId);
                if (org != null) {
                    profile.put("className", org.getName());
                }
            }
        }
        return ResponseEntity.ok(ApiResponse.success("获取成功", profile));
    }

    @PutMapping
    @PreAuthorize("hasRole('STUDENT')")
    public ResponseEntity<ApiResponse<Void>> updateProfile(Authentication auth, @RequestBody Map<String, Object> body) {
        String email = body.containsKey("email") ? (String) body.get("email") : null;
        String phone = body.containsKey("phone") ? (String) body.get("phone") : null;
        String bio = body.containsKey("bio") ? (String) body.get("bio") : null;
        
        if (email != null || phone != null || bio != null) {
            userService.updateProfile(auth.getName(), 
                email != null ? email : userService.getByUsername(auth.getName()).getEmail(),
                phone,
                bio);
        }
        return ResponseEntity.ok(ApiResponse.success("更新成功", null));
    }

    @PutMapping("/password")
    @PreAuthorize("hasRole('STUDENT')")
    public ResponseEntity<ApiResponse<Void>> changePassword(Authentication auth, @RequestBody Map<String, Object> body) {
        String oldPassword = (String) body.get("oldPassword");
        String newPassword = (String) body.get("newPassword");
        
        boolean success = userService.changePassword(auth.getName(), oldPassword, newPassword);
        if (!success) {
            return ResponseEntity.badRequest().body(ApiResponse.error(400, "密码修改失败"));
        }
        
        return ResponseEntity.ok(ApiResponse.success("修改成功", null));
    }

    @GetMapping("/stats")
    @PreAuthorize("hasRole('STUDENT')")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getStats(Authentication auth) {
        // Basic stats - can be expanded
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalExams", 0);
        stats.put("totalPractice", 0);
        stats.put("totalErrors", 0);
        stats.put("avgScore", 0.0);
        
        return ResponseEntity.ok(ApiResponse.success("获取成功", stats));
    }
}

