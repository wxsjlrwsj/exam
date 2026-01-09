SET NAMES utf8mb4;
USE chaoxing;

CREATE TABLE IF NOT EXISTS biz_class_teacher (
  id BIGINT NOT NULL AUTO_INCREMENT,
  class_id BIGINT NOT NULL,
  teacher_id BIGINT NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_class_teacher (class_id, teacher_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET @exists_idx_class := (SELECT COUNT(*) FROM INFORMATION_SCHEMA.STATISTICS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='biz_class_teacher' AND INDEX_NAME='idx_class');
SET @sql_idx_class := IF(@exists_idx_class=0, 'CREATE INDEX idx_class ON biz_class_teacher(class_id)', 'SELECT 1');
PREPARE s1 FROM @sql_idx_class; EXECUTE s1; DEALLOCATE PREPARE s1;
SET @exists_idx_teacher := (SELECT COUNT(*) FROM INFORMATION_SCHEMA.STATISTICS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='biz_class_teacher' AND INDEX_NAME='idx_teacher');
SET @sql_idx_teacher := IF(@exists_idx_teacher=0, 'CREATE INDEX idx_teacher ON biz_class_teacher(teacher_id)', 'SELECT 1');
PREPARE s2 FROM @sql_idx_teacher; EXECUTE s2; DEALLOCATE PREPARE s2;
