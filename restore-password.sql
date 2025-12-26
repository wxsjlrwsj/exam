USE chaoxing;
UPDATE users 
SET password_hash = '$2a$10$zJpIYkPp7OLoOqMZ9o4m3uQV1YVQdGmJ8VxgQf3o3PzF8q6QJk7uS' 
WHERE username = 'student1';
SELECT username, LEFT(password_hash, 40) as pwd FROM users WHERE username='student1';

