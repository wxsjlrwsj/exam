ALTER TABLE biz_question_audit
  ADD COLUMN status TINYINT NOT NULL DEFAULT 0 COMMENT '????';

UPDATE biz_question_audit
SET status = 0
WHERE status IS NULL;
