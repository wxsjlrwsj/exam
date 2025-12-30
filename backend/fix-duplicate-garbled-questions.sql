-- 修复练题题库中的重复乱码题目
-- 问题：某些题目被重复插入，且第二次插入时出现了编码错误导致乱码

-- 1. 查看所有可能的乱码题目（字节长度/字符长度比例异常）
SELECT 
    id, 
    subject,
    LEFT(content, 50) as content_preview,
    CHAR_LENGTH(content) as char_len, 
    LENGTH(content) as byte_len,
    ROUND(LENGTH(content) / CHAR_LENGTH(content), 2) as byte_per_char
FROM biz_question 
WHERE status = 1
  AND LENGTH(content) / CHAR_LENGTH(content) > 2.5  -- 正常中文UTF-8约为3，乱码会更大
ORDER BY id;

-- 2. 删除已知的乱码重复题目
-- 这些题目在数据库中有正常版本（id < 30），乱码版本（id >= 30）应该被删除

-- 删除乱码题目（id 30-41 中的乱码数据）
-- 先备份到临时表
CREATE TABLE IF NOT EXISTS biz_question_backup_garbled AS
SELECT * FROM biz_question 
WHERE id >= 30 
  AND (
    LENGTH(content) / CHAR_LENGTH(content) > 2.5
    OR subject LIKE '%?%'
  );

-- 删除乱码题目
DELETE FROM biz_question 
WHERE id >= 30 
  AND (
    LENGTH(content) / CHAR_LENGTH(content) > 2.5
    OR subject LIKE '%?%'
  );

-- 3. 检查是否还有重复的题目内容（基于相似的 content）
-- 注意：这个查询只是检查，不执行删除
SELECT 
    a.id as id1, 
    b.id as id2,
    a.subject,
    LEFT(a.content, 50) as content_preview
FROM biz_question a
JOIN biz_question b ON a.id < b.id 
    AND SUBSTRING(a.content, 1, 20) = SUBSTRING(b.content, 1, 20)
    AND a.status = 1 
    AND b.status = 1
ORDER BY a.id;

-- 4. 验证修复结果
SELECT 
    COUNT(*) as total_questions,
    COUNT(DISTINCT SUBSTRING(content, 1, 50)) as unique_contents,
    COUNT(*) - COUNT(DISTINCT SUBSTRING(content, 1, 50)) as potential_duplicates
FROM biz_question 
WHERE status = 1;

-- 5. 显示修复后的题目列表
SELECT 
    id, 
    subject,
    LEFT(content, 60) as content_preview,
    difficulty,
    create_time
FROM biz_question 
WHERE status = 1
ORDER BY id DESC
LIMIT 20;

