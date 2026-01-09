package org.example.chaoxingsystem.user;

import org.example.chaoxingsystem.user.dto.ApiResponse;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/users")
public class UserQueryController {
  private final UserMapper userMapper;
  private final org.example.chaoxingsystem.admin.org.StudentProfileMapper studentProfileMapper;

  public UserQueryController(UserMapper userMapper, org.example.chaoxingsystem.admin.org.StudentProfileMapper studentProfileMapper) {
    this.userMapper = userMapper;
    this.studentProfileMapper = studentProfileMapper;
  }

  @GetMapping("/teachers")
  @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
  public ResponseEntity<ApiResponse<List<Map<String, Object>>>> searchTeachers(@RequestParam(value = "keyword", required = false) String keyword,
                                                                               @RequestParam(value = "pageNum", defaultValue = "1") int pageNum,
                                                                               @RequestParam(value = "pageSize", defaultValue = "10") int pageSize) {
    int offset = (Math.max(pageNum, 1) - 1) * Math.max(pageSize, 1);
    List<User> list = userMapper.searchByUserType("teacher", keyword, offset, pageSize);
    List<Map<String, Object>> result = new ArrayList<>();
    for (User u : list) {
      Map<String, Object> row = new HashMap<>();
      row.put("id", u.getId());
      row.put("name", u.getRealName());
      row.put("department", null);
      result.add(row);
    }
    return ResponseEntity.ok(ApiResponse.success("获取成功", result));
  }

  @GetMapping("/students")
  @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
  public ResponseEntity<ApiResponse<List<Map<String, Object>>>> searchStudents(@RequestParam(value = "keyword", required = false) String keyword,
                                                                               @RequestParam(value = "pageNum", defaultValue = "1") int pageNum,
                                                                               @RequestParam(value = "pageSize", defaultValue = "10") int pageSize) {
    int offset = (Math.max(pageNum, 1) - 1) * Math.max(pageSize, 1);
    List<Map<String, Object>> result = userMapper.searchStudents(keyword, offset, pageSize);
    return ResponseEntity.ok(ApiResponse.success("获取成功", result));
  }
}
