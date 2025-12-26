USE chaoxing;

-- 创建测试用户（密码都是 123456）
-- BCrypt加密后的密码: $2a$10$zJpIYkPp7OLoOqMZ9o4m3uQV1YVQdGmJ8VxgQf3o3PzF8q6QJk7uS

-- 学生用户
INSERT INTO users(username, email, phone, password_hash, user_type, real_name, avatar) VALUES
('student1', 'student1@test.com', NULL, '$2a$10$zJpIYkPp7OLoOqMZ9o4m3uQV1YVQdGmJ8VxgQf3o3PzF8q6QJk7uS', 'student', '测试学生1', NULL),
('student2', 'student2@test.com', NULL, '$2a$10$zJpIYkPp7OLoOqMZ9o4m3uQV1YVQdGmJ8VxgQf3o3PzF8q6QJk7uS', 'student', '测试学生2', NULL),
('student3', 'student3@test.com', NULL, '$2a$10$zJpIYkPp7OLoOqMZ9o4m3uQV1YVQdGmJ8VxgQf3o3PzF8q6QJk7uS', 'student', '测试学生3', NULL);

-- 教师用户
INSERT INTO users(username, email, phone, password_hash, user_type, real_name, avatar) VALUES
('teacher1', 'teacher1@test.com', NULL, '$2a$10$zJpIYkPp7OLoOqMZ9o4m3uQV1YVQdGmJ8VxgQf3o3PzF8q6QJk7uS', 'teacher', '测试教师1', NULL),
('teacher2', 'teacher2@test.com', NULL, '$2a$10$zJpIYkPp7OLoOqMZ9o4m3uQV1YVQdGmJ8VxgQf3o3PzF8q6QJk7uS', 'teacher', '测试教师2', NULL);

-- 管理员用户
INSERT INTO users(username, email, phone, password_hash, user_type, real_name, avatar) VALUES
('admin', 'admin@test.com', NULL, '$2a$10$zJpIYkPp7OLoOqMZ9o4m3uQV1YVQdGmJ8VxgQf3o3PzF8q6QJk7uS', 'admin', '系统管理员', NULL);

-- 创建角色（如果不存在）
INSERT IGNORE INTO sys_role(role_name, role_key, data_scope, status) VALUES
('学生', 'STUDENT', '5', 1),
('教师', 'TEACHER', '2', 1),
('管理员', 'ADMIN', '1', 1);

-- 分配角色给用户
INSERT IGNORE INTO sys_user_role(user_id, role_id)
SELECT u.id, r.id FROM users u, sys_role r 
WHERE u.username IN ('student1', 'student2', 'student3') AND r.role_key = 'STUDENT';

INSERT IGNORE INTO sys_user_role(user_id, role_id)
SELECT u.id, r.id FROM users u, sys_role r 
WHERE u.username IN ('teacher1', 'teacher2') AND r.role_key = 'TEACHER';

INSERT IGNORE INTO sys_user_role(user_id, role_id)
SELECT u.id, r.id FROM users u, sys_role r 
WHERE u.username = 'admin' AND r.role_key = 'ADMIN';

-- 查看创建的用户
SELECT id, username, user_type, real_name, email FROM users;

