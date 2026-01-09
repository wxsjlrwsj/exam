SET NAMES utf8mb4;
USE chaoxing;

SET @exists_year := (
  SELECT COUNT(*)
  FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'biz_teaching_class'
    AND COLUMN_NAME = 'academic_year'
);
SET @exists_semester := (
  SELECT COUNT(*)
  FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'biz_teaching_class'
    AND COLUMN_NAME = 'semester'
);

SET @sql_add_year := IF(@exists_year=0, 'ALTER TABLE biz_teaching_class ADD COLUMN academic_year VARCHAR(10) NULL AFTER assigned_teacher_id', 'SELECT 1');
SET @sql_add_semester := IF(@exists_semester=0, 'ALTER TABLE biz_teaching_class ADD COLUMN semester VARCHAR(20) NULL AFTER academic_year', 'SELECT 1');

PREPARE s1 FROM @sql_add_year; EXECUTE s1; DEALLOCATE PREPARE s1;
PREPARE s2 FROM @sql_add_semester; EXECUTE s2; DEALLOCATE PREPARE s2;

UPDATE biz_teaching_class
SET academic_year = REGEXP_SUBSTR(name, '20[0-9]{2}')
WHERE academic_year IS NULL
  AND name REGEXP '20[0-9]{2}';

UPDATE biz_teaching_class
SET semester = '春'
WHERE semester IS NULL
  AND name LIKE '%春%';

UPDATE biz_teaching_class
SET semester = '秋'
WHERE semester IS NULL
  AND name LIKE '%秋%';
