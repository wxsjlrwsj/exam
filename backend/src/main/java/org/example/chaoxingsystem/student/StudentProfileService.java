package org.example.chaoxingsystem.student;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

@Service
public class StudentProfileService {

    private final JdbcTemplate jdbcTemplate;

    public StudentProfileService(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public void updateFacePhoto(String username, String base64Photo) {
        try {
            String checkSql = "SELECT COUNT(*) FROM biz_student WHERE user_id = (SELECT id FROM users WHERE username = ?)";
            Integer count = jdbcTemplate.queryForObject(checkSql, Integer.class, username);
            
            if (count == null || count == 0) {
                String userIdSql = "SELECT id FROM users WHERE username = ?";
                Long userId = jdbcTemplate.queryForObject(userIdSql, Long.class, username);
                
                String insertSql = "INSERT INTO biz_student (user_id, student_no, real_name, gender) VALUES (?, ?, ?, 1)";
                jdbcTemplate.update(insertSql, userId, "S" + userId, username);
            }
            
            String sql = "UPDATE biz_student SET face_photo = ? WHERE user_id = (SELECT id FROM users WHERE username = ?)";
            int updated = jdbcTemplate.update(sql, base64Photo, username);
            
            if (updated == 0) {
                throw new RuntimeException("更新失败，未找到学生记录");
            }
        } catch (Exception e) {
            throw new RuntimeException("更新人脸照片失败: " + e.getMessage(), e);
        }
    }

    public String getFacePhoto(String username) {
        String sql = "SELECT face_photo FROM biz_student WHERE user_id = (SELECT id FROM users WHERE username = ?)";
        try {
            return jdbcTemplate.queryForObject(sql, String.class, username);
        } catch (Exception e) {
            return null;
        }
    }
}
