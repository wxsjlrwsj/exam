USE chaoxing;
UPDATE users SET password_hash = '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy' WHERE username = 'student1';
SELECT username, LEFT(password_hash, 30) as pwd FROM users WHERE username = 'student1';
