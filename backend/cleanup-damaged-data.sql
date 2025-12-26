-- 清理损坏的中文数据
USE chaoxing;

-- 1. 删除损坏的考试数据（ID 5-8）
DELETE FROM biz_exam_student WHERE exam_id IN (5,6,7,8);
DELETE FROM biz_exam WHERE id IN (5,6,7,8);

-- 2. 删除损坏的题目数据（ID 45-54）
DELETE FROM biz_paper_question WHERE question_id >= 45;
DELETE FROM biz_question WHERE id >= 45;

-- 3. 验证清理结果
SELECT '=== 剩余考试数据 ===' as info;
SELECT id, name FROM biz_exam;

SELECT '=== 剩余题目数量 ===' as info;
SELECT COUNT(*) as total_questions FROM biz_question WHERE status = 1;

SELECT '=== 按科目统计题目 ===' as info;
SELECT subject, COUNT(*) as count FROM biz_question WHERE status = 1 GROUP BY subject;
