-- 删除空白题目的收藏记录
-- 日期: 2026-01-08
-- 说明: 删除学生个性化题库中的空白题目（question_id 37, 38, 39, 40）

-- 删除收藏题目关联表中的空白题目记录
DELETE FROM biz_collection_question 
WHERE question_id IN (37, 38, 39, 40);

-- 删除错题本中的空白题目记录（如果存在）
DELETE FROM biz_student_error_book 
WHERE question_id IN (37, 38, 39, 40);

-- 删除这些空白题目本身（如果存在）
DELETE FROM biz_question 
WHERE id IN (37, 38, 39, 40) AND (content IS NULL OR content = '');

-- 验证删除结果
SELECT '删除完成，剩余收藏题目数量:' AS message, COUNT(*) AS count 
FROM biz_collection_question;

SELECT '空白题目检查（应该为0）:' AS message, COUNT(*) AS count 
FROM biz_collection_question cq 
LEFT JOIN biz_question q ON cq.question_id = q.id 
WHERE q.content IS NULL OR q.content = '';
