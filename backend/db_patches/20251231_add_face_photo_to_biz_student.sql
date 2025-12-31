SET @col_exists := (
  SELECT COUNT(*) 
  FROM INFORMATION_SCHEMA.COLUMNS 
  WHERE TABLE_SCHEMA = DATABASE() 
    AND TABLE_NAME = 'biz_student' 
    AND COLUMN_NAME = 'face_photo'
);
SET @sql := IF(
  @col_exists = 0, 
  'ALTER TABLE `biz_student` ADD COLUMN `face_photo` MEDIUMTEXT COLLATE utf8mb4_unicode_ci NULL;', 
  'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
