SET @db := DATABASE();

SET @sql := (
  SELECT IF(
    EXISTS(
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = @db AND table_name = 'biz_question_audit' AND column_name = 'type_id'
    ),
    'SELECT 1',
    'ALTER TABLE biz_question_audit ADD COLUMN type_id TINYINT NULL'
  )
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := (
  SELECT IF(
    EXISTS(
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = @db AND table_name = 'biz_question_audit' AND column_name = 'content'
    ),
    'SELECT 1',
    'ALTER TABLE biz_question_audit ADD COLUMN content TEXT NULL'
  )
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := (
  SELECT IF(
    EXISTS(
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = @db AND table_name = 'biz_question_audit' AND column_name = 'answer'
    ),
    'SELECT 1',
    'ALTER TABLE biz_question_audit ADD COLUMN answer TEXT NULL'
  )
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := (
  SELECT IF(
    EXISTS(
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = @db AND table_name = 'biz_question_audit' AND column_name = 'difficulty'
    ),
    'SELECT 1',
    'ALTER TABLE biz_question_audit ADD COLUMN difficulty TINYINT NULL'
  )
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := (
  SELECT IF(
    EXISTS(
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = @db AND table_name = 'biz_question_audit' AND column_name = 'subject_id'
    ),
    'SELECT 1',
    'ALTER TABLE biz_question_audit ADD COLUMN subject_id BIGINT NULL'
  )
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := (
  SELECT IF(
    EXISTS(
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = @db AND table_name = 'biz_question_audit' AND column_name = 'audit_comment'
    ),
    'SELECT 1',
    'ALTER TABLE biz_question_audit ADD COLUMN audit_comment TEXT NULL'
  )
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := (
  SELECT IF(
    EXISTS(
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = @db AND table_name = 'biz_question_audit' AND column_name = 'submit_time'
    ),
    'ALTER TABLE biz_question_audit MODIFY COLUMN submit_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP',
    'ALTER TABLE biz_question_audit ADD COLUMN submit_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP'
  )
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

ALTER TABLE biz_question_audit MODIFY COLUMN question_id BIGINT NULL;

UPDATE biz_question_audit SET status = audit_status WHERE status = 0;
UPDATE biz_question_audit SET audit_comment = audit_opinion WHERE audit_comment IS NULL;

UPDATE biz_question_audit SET content = '' WHERE content IS NULL;
UPDATE biz_question_audit SET answer = '\"\"' WHERE answer IS NULL;
ALTER TABLE biz_question_audit MODIFY COLUMN content TEXT NOT NULL;
ALTER TABLE biz_question_audit MODIFY COLUMN answer TEXT NOT NULL;

