USE chaoxing;

-- 使用确定正确的BCrypt哈希（对应密码: 123456）
-- 这个哈希是经过验证的标准BCrypt输出
UPDATE users 
SET password_hash = '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYzQziBn4g2'
WHERE username IN ('student1', 'student2', 'student3', 'student4', 'teacher1', 'teacher2', 'teacher3', 'admin1', 'test');

-- 验证更新
SELECT username, user_type, LEFT(password_hash, 40) as pwd_hash 
FROM users 
WHERE username IN ('student1', 'teacher1', 'admin1');

