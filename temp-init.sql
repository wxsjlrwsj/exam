USE chaoxing;

INSERT INTO users(username, email, password_hash, user_type, real_name) VALUES
('student1', 'student1@test.com', '$2a$10$zJpIYkPp7OLoOqMZ9o4m3uQV1YVQdGmJ8VxgQf3o3PzF8q6QJk7uS', 'student', 'Test Student 1'),
('student2', 'student2@test.com', '$2a$10$zJpIYkPp7OLoOqMZ9o4m3uQV1YVQdGmJ8VxgQf3o3PzF8q6QJk7uS', 'student', 'Test Student 2'),
('teacher1', 'teacher1@test.com', '$2a$10$zJpIYkPp7OLoOqMZ9o4m3uQV1YVQdGmJ8VxgQf3o3PzF8q6QJk7uS', 'teacher', 'Test Teacher 1'),
('admin', 'admin@test.com', '$2a$10$zJpIYkPp7OLoOqMZ9o4m3uQV1YVQdGmJ8VxgQf3o3PzF8q6QJk7uS', 'admin', 'Admin User');

SELECT username, user_type, real_name FROM users;

