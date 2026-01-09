SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

USE chaoxing;

-- 1. 获取 teacher1 的 ID
SET @teacher_id = (SELECT id FROM users WHERE username='teacher1');

-- 2. 将部分题目分配给 teacher1 (确保 submitter_id 指向 teacher1)
--    这里假设 id < 50 的题目分配给 teacher1
UPDATE biz_question SET creator_id = @teacher_id WHERE id < 50;

-- 3. 确保这些题目的学科是 teacher1 教授的 (ds, os, java)
--    随机或按规则分配
UPDATE biz_question SET subject = '数据结构' WHERE id % 3 = 0 AND creator_id = @teacher_id;
UPDATE biz_question SET subject = '操作系统' WHERE id % 3 = 1 AND creator_id = @teacher_id;
UPDATE biz_question SET subject = 'Java程序设计' WHERE id % 3 = 2 AND creator_id = @teacher_id;

-- 4. 确保状态是 1 (已发布/可用)
UPDATE biz_question SET status = 1 WHERE creator_id = @teacher_id;

-- 5. 如果有审核记录表 biz_question_audit，也更新一下 submitter_id 以保持一致 (可选)
-- UPDATE biz_question_audit SET submitter_id = @teacher_id WHERE id < 50;
