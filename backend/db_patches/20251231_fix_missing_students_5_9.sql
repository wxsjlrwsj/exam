SET NAMES utf8mb4;

-- 1) 确保用户存在（INSERT IGNORE 保证幂等）
INSERT IGNORE INTO users(username,email,phone,password_hash,user_type,real_name,avatar) VALUES
('student5','student5@example.com',NULL,'$2a$10$zJpIYkPp7OLoOqMZ9o4m3uQV1YVQdGmJ8VxgQf3o3PzF8q6QJk7uS','student','学生五',NULL),
('student6','student6@example.com',NULL,'$2a$10$zJpIYkPp7OLoOqMZ9o4m3uQV1YVQdGmJ8VxgQf3o3PzF8q6QJk7uS','student','学生六',NULL),
('student7','student7@example.com',NULL,'$2a$10$zJpIYkPp7OLoOqMZ9o4m3uQV1YVQdGmJ8VxgQf3o3PzF8q6QJk7uS','student','学生七',NULL),
('student8','student8@example.com',NULL,'$2a$10$zJpIYkPp7OLoOqMZ9o4m3uQV1YVQdGmJ8VxgQf3o3PzF8q6QJk7uS','student','学生八',NULL),
('student9','student9@example.com',NULL,'$2a$10$zJpIYkPp7OLoOqMZ9o4m3uQV1YVQdGmJ8VxgQf3o3PzF8q6QJk7uS','student','学生九',NULL);

-- 2) 补充学生档案与班级归属（仅当该 user_id 不存在于 biz_student 时插入）
INSERT INTO biz_student (user_id, student_no, real_name, gender, class_id, major_code, enrollment_year, politics_status)
SELECT u.id, 'S2023005', u.real_name, 1, 100, 'CS', 2023, '群众'
FROM users u
WHERE u.username = 'student5'
  AND NOT EXISTS (SELECT 1 FROM biz_student s WHERE s.user_id = u.id);

INSERT INTO biz_student (user_id, student_no, real_name, gender, class_id, major_code, enrollment_year, politics_status)
SELECT u.id, 'S2023006', u.real_name, 0, 100, 'CS', 2023, '团员'
FROM users u
WHERE u.username = 'student6'
  AND NOT EXISTS (SELECT 1 FROM biz_student s WHERE s.user_id = u.id);

INSERT INTO biz_student (user_id, student_no, real_name, gender, class_id, major_code, enrollment_year, politics_status)
SELECT u.id, 'S2023007', u.real_name, 1, 101, 'CS', 2023, '群众'
FROM users u
WHERE u.username = 'student7'
  AND NOT EXISTS (SELECT 1 FROM biz_student s WHERE s.user_id = u.id);

INSERT INTO biz_student (user_id, student_no, real_name, gender, class_id, major_code, enrollment_year, politics_status)
SELECT u.id, 'S2023008', u.real_name, 0, 101, 'CS', 2023, '团员'
FROM users u
WHERE u.username = 'student8'
  AND NOT EXISTS (SELECT 1 FROM biz_student s WHERE s.user_id = u.id);

INSERT INTO biz_student (user_id, student_no, real_name, gender, class_id, major_code, enrollment_year, politics_status)
SELECT u.id, 'S2023009', u.real_name, 1, 102, 'SE', 2022, '群众'
FROM users u
WHERE u.username = 'student9'
  AND NOT EXISTS (SELECT 1 FROM biz_student s WHERE s.user_id = u.id);
