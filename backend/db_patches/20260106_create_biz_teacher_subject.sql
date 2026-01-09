SET NAMES utf8mb4;
USE chaoxing;

-- 创建教师-科目映射表（若不存在）
CREATE TABLE IF NOT EXISTS biz_teacher_subject (
  teacher_id BIGINT NOT NULL,
  subject_id BIGINT NOT NULL,
  PRIMARY KEY (teacher_id, subject_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 从旧映射表迁移数据（若旧表存在）
INSERT IGNORE INTO biz_teacher_subject (teacher_id, subject_id)
SELECT ts.teacher_id, ts.subject_id
FROM information_schema.tables t
JOIN biz_teacher_subject_map ts
WHERE t.table_schema = DATABASE()
  AND t.table_name = 'biz_teacher_subject_map';

