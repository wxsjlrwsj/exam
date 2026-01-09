-- 教师归属从系(dept_id)调整为学院(college_id)
USE chaoxing;
ALTER TABLE biz_teacher 
  ADD COLUMN college_id BIGINT NULL AFTER dept_id;

UPDATE biz_teacher t
LEFT JOIN sys_organization d ON d.id = t.dept_id
LEFT JOIN sys_organization c ON c.id = d.parent_id AND LOWER(c.type) = 'college'
SET t.college_id = c.id;

UPDATE biz_teacher SET dept_id = NULL WHERE dept_id IS NOT NULL;

-- 索引可选（根据查询频率）
ALTER TABLE biz_teacher ADD INDEX idx_college_id (college_id);
