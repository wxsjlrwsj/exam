-- 目的：将旧表 biz_class_student 中的班级归属迁移到新表 biz_student 的 class_id 字段
-- 影响：仅更新已有学生档案对应的班级ID，不会删除旧映射表数据
-- 注意：此脚本幂等，多次执行不会造成重复影响

UPDATE biz_student s
JOIN biz_class_student cs ON cs.user_id = s.user_id
SET s.class_id = cs.class_id
WHERE s.class_id IS NULL OR s.class_id <> cs.class_id;

-- 可选校验：统计迁移后每个班级学生数量（用于人工核对）
-- SELECT c.id AS classId, c.class_name AS className, COUNT(*) AS studentCount
-- FROM biz_student s
-- JOIN biz_class c ON c.id = s.class_id
-- GROUP BY c.id, c.class_name
-- ORDER BY c.id;

