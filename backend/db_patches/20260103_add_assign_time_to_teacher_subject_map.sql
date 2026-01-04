SET NAMES utf8mb4;
USE chaoxing;

SET @exists_assign := (
  SELECT COUNT(*)
  FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'biz_teacher_subject_map'
    AND COLUMN_NAME = 'assign_time'
);

SET @sql_add_assign := IF(
  @exists_assign = 0,
  'ALTER TABLE biz_teacher_subject_map ADD COLUMN assign_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP',
  'SELECT 1'
);
PREPARE s_add_assign FROM @sql_add_assign; EXECUTE s_add_assign; DEALLOCATE PREPARE s_add_assign;

UPDATE biz_teacher_subject_map SET assign_time = COALESCE(assign_time, NOW());

