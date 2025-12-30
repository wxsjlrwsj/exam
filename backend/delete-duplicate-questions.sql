-- 删除重复的题目
-- 根据分析，id 30-41 是重复插入的数据，且部分显示为乱码
-- 保留原始的 id 1-29 的数据，删除 id 30-41 中与 1-29 重复的题目

-- 1. 先备份要删除的数据
CREATE TABLE IF NOT EXISTS biz_question_backup_20251227 AS
SELECT * FROM biz_question WHERE id >= 30 AND id <= 41;

-- 2. 查看 id 1-29 和 30-41 的对应关系
-- 通过内容的前20个字符来匹配
SELECT 
    a.id as original_id,
    b.id as duplicate_id,
    a.subject as original_subject,
    b.subject as duplicate_subject,
    LEFT(a.content, 40) as content_preview
FROM biz_question a
JOIN biz_question b ON b.id >= 30 AND b.id <= 41
WHERE a.id < 30 
  AND a.status = 1 
  AND b.status = 1
  AND (
    -- 尝试匹配内容的开头部分
    SUBSTRING(a.content, 1, 10) = SUBSTRING(b.content, 1, 10)
    OR a.content = b.content
  )
ORDER BY a.id, b.id;

-- 3. 直接删除 id 30-41 的所有题目（因为它们都是重复的）
-- 这些题目在 2025-12-26 18:04:49 批量插入，与之前的数据重复
DELETE FROM biz_question 
WHERE id >= 30 
  AND id <= 41
  AND create_time = '2025-12-26 18:04:49';

-- 4. 验证删除结果
SELECT COUNT(*) as remaining_questions FROM biz_question WHERE status = 1;

-- 5. 显示剩余的题目
SELECT id, subject, LEFT(content, 50) as content_preview, difficulty 
FROM biz_question 
WHERE status = 1 
ORDER BY id;

