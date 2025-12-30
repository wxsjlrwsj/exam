SET NAMES utf8mb4;
USE chaoxing;

SET @exists_college := (
  SELECT COUNT(*) 
  FROM INFORMATION_SCHEMA.COLUMNS 
  WHERE TABLE_SCHEMA = DATABASE() 
    AND TABLE_NAME = 'biz_teacher' 
    AND COLUMN_NAME = 'college_id'
);
SET @sql_college := IF(@exists_college=0, 'ALTER TABLE biz_teacher ADD COLUMN college_id BIGINT NULL', 'SELECT 1');
PREPARE s1 FROM @sql_college; EXECUTE s1; DEALLOCATE PREPARE s1;

