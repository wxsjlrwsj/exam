USE chaoxing;
INSERT INTO users (username, email, password_hash, user_type, real_name) 
VALUES ('student1', 'student1@test.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'student', 'Test Student');
SELECT username, LEFT(password_hash, 40) as pwd FROM users WHERE username='student1';

