SET NAMES utf8mb4;

-- 清理相关考试数据（若存在）
DELETE FROM biz_exam_answer 
WHERE record_id IN (
  SELECT id FROM biz_exam_record 
  WHERE student_id IN (
    SELECT s.id 
    FROM biz_student s 
    JOIN users u ON u.id = s.user_id 
    WHERE u.username IN ('student5','student6','student7','student8','student9')
  )
);

DELETE FROM biz_exam_record 
WHERE student_id IN (
  SELECT s.id 
  FROM biz_student s 
  JOIN users u ON u.id = s.user_id 
  WHERE u.username IN ('student5','student6','student7','student8','student9')
);

DELETE FROM biz_exam_student 
WHERE user_id IN (
  SELECT id FROM users 
  WHERE username IN ('student5','student6','student7','student8','student9')
);

-- 删除学生档案与角色映射、用户
DELETE FROM biz_student 
WHERE user_id IN (
  SELECT id FROM users 
  WHERE username IN ('student5','student6','student7','student8','student9')
);

DELETE FROM sys_user_role 
WHERE user_id IN (
  SELECT id FROM users 
  WHERE username IN ('student5','student6','student7','student8','student9')
);

DELETE FROM users 
WHERE username IN ('student5','student6','student7','student8','student9');

-- 重新插入用户（UTF-8中文）
INSERT INTO users(username,email,phone,password_hash,user_type,real_name,avatar) VALUES
('student5','student5@example.com',NULL,'$2a$10$zJpIYkPp7OLoOqMZ9o4m3uQV1YVQdGmJ8VxgQf3o3PzF8q6QJk7uS','student','学生五',NULL),
('student6','student6@example.com',NULL,'$2a$10$zJpIYkPp7OLoOqMZ9o4m3uQV1YVQdGmJ8VxgQf3o3PzF8q6QJk7uS','student','学生六',NULL),
('student7','student7@example.com',NULL,'$2a$10$zJpIYkPp7OLoOqMZ9o4m3uQV1YVQdGmJ8VxgQf3o3PzF8q6QJk7uS','student','学生七',NULL),
('student8','student8@example.com',NULL,'$2a$10$zJpIYkPp7OLoOqMZ9o4m3uQV1YVQdGmJ8VxgQf3o3PzF8q6QJk7uS','student','学生八',NULL),
('student9','student9@example.com',NULL,'$2a$10$zJpIYkPp7OLoOqMZ9o4m3uQV1YVQdGmJ8VxgQf3o3PzF8q6QJk7uS','student','学生九',NULL);

-- 重新映射角色（学生）
INSERT INTO sys_user_role(user_id,role_id)
SELECT u.id, r.id 
FROM users u 
JOIN sys_role r ON r.role_key='STUDENT'
WHERE u.username IN ('student5','student6','student7','student8','student9');

-- 重新插入学生档案（归属班级与中文姓名）
INSERT INTO biz_student(user_id,student_no,real_name,gender,class_id,major_code,enrollment_year,politics_status) VALUES
((SELECT id FROM users WHERE username='student5'),'S2023005','孙七',1,100,'CS',2023,'群众'),
((SELECT id FROM users WHERE username='student6'),'S2023006','周八',0,100,'CS',2023,'团员'),
((SELECT id FROM users WHERE username='student7'),'S2023007','吴九',1,101,'CS',2023,'群众'),
((SELECT id FROM users WHERE username='student8'),'S2023008','郑十',0,101,'CS',2023,'团员'),
((SELECT id FROM users WHERE username='student9'),'S2023009','冯十一',1,102,'SE',2022,'群众');

