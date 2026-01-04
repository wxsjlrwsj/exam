SET NAMES utf8mb4;
USE chaoxing;

INSERT IGNORE INTO users(username,email,phone,password_hash,user_type,real_name,avatar)
VALUES 
  ('teacher4','teacher4@example.com',NULL,'$2a$10$zJpIYkPp7OLoOqMZ9o4m3uQV1YVQdGmJ8VxgQf3o3PzF8q6QJk7uS','teacher','教师四',NULL),
  ('teacher5','teacher5@example.com',NULL,'$2a$10$zJpIYkPp7OLoOqMZ9o4m3uQV1YVQdGmJ8VxgQf3o3PzF8q6QJk7uS','teacher','教师五',NULL);

INSERT IGNORE INTO sys_user_role(user_id,role_id)
SELECT u.id, (SELECT id FROM sys_role WHERE role_key='TEACHER' LIMIT 1)
FROM users u
WHERE u.username IN ('teacher4','teacher5');

INSERT IGNORE INTO biz_teacher(user_id,employee_no,real_name,gender,dept_id,title,enrollment_year)
VALUES
  ((SELECT id FROM users WHERE username='teacher4'),'T2023004','教师四',1,NULL,'教授',2019),
  ((SELECT id FROM users WHERE username='teacher5'),'T2023005','教师五',1,NULL,'讲师',2020);
