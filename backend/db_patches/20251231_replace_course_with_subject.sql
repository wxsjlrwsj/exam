SET NAMES utf8mb4;
USE chaoxing;

SET @exists_subject_col := (
  SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'biz_teaching_class' AND COLUMN_NAME = 'subject_id'
);
SET @sql_add_subject := IF(@exists_subject_col=0, 'ALTER TABLE biz_teaching_class ADD COLUMN subject_id BIGINT NULL', 'SELECT 1');
PREPARE s_add_subject FROM @sql_add_subject; EXECUTE s_add_subject; DEALLOCATE PREPARE s_add_subject;

SET @exists_course_col2 := (
  SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'biz_teaching_class' AND COLUMN_NAME = 'course_id'
);
SET @sql_fill_subject := IF(@exists_course_col2>0, 
  'UPDATE biz_teaching_class tc JOIN biz_course c ON tc.course_id = c.id JOIN biz_subject s ON s.name COLLATE utf8mb4_0900_ai_ci = c.name SET tc.subject_id = s.id WHERE tc.subject_id IS NULL',
  'UPDATE biz_teaching_class tc JOIN biz_subject s ON s.name COLLATE utf8mb4_0900_ai_ci = SUBSTRING_INDEX(tc.name, \"-\", 1) SET tc.subject_id = s.id WHERE tc.subject_id IS NULL'
);
PREPARE s_fill_subject FROM @sql_fill_subject; EXECUTE s_fill_subject; DEALLOCATE PREPARE s_fill_subject;

SET @exists_idx_course := (
  SELECT COUNT(*) FROM INFORMATION_SCHEMA.STATISTICS 
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'biz_teaching_class' AND INDEX_NAME = 'idx_course'
);
SET @sql_drop_idx_course := IF(@exists_idx_course>0, 'ALTER TABLE biz_teaching_class DROP INDEX idx_course', 'SELECT 1');
PREPARE s_drop_idx_course FROM @sql_drop_idx_course; EXECUTE s_drop_idx_course; DEALLOCATE PREPARE s_drop_idx_course;

SET @exists_idx_subject := (
  SELECT COUNT(*) FROM INFORMATION_SCHEMA.STATISTICS 
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'biz_teaching_class' AND INDEX_NAME = 'idx_subject'
);
SET @sql_add_idx_subject := IF(@exists_idx_subject=0, 'ALTER TABLE biz_teaching_class ADD INDEX idx_subject (subject_id)', 'SELECT 1');
PREPARE s_add_idx_subject FROM @sql_add_idx_subject; EXECUTE s_add_idx_subject; DEALLOCATE PREPARE s_add_idx_subject;

SET @exists_course_col := (
  SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'biz_teaching_class' AND COLUMN_NAME = 'course_id'
);
SET @sql_drop_course_col := IF(@exists_course_col>0, 'ALTER TABLE biz_teaching_class DROP COLUMN course_id', 'SELECT 1');
PREPARE s_drop_course_col FROM @sql_drop_course_col; EXECUTE s_drop_course_col; DEALLOCATE PREPARE s_drop_course_col;

SET @exists_ct_table := (
  SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES 
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'biz_course_teacher'
);
SET @sql_migrate_ct := IF(@exists_ct_table>0, 
  'INSERT IGNORE INTO biz_teacher_subject_map (teacher_id, subject_id) SELECT ct.teacher_id, s.id FROM biz_course_teacher ct JOIN biz_course c ON ct.course_id = c.id JOIN biz_subject s ON s.name COLLATE utf8mb4_0900_ai_ci = c.name',
  'SELECT 1');
PREPARE s_migrate_ct FROM @sql_migrate_ct; EXECUTE s_migrate_ct; DEALLOCATE PREPARE s_migrate_ct;

DROP TABLE IF EXISTS biz_course_teacher;
DROP TABLE IF EXISTS biz_course;
