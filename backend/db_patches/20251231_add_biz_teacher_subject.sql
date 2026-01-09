USE chaoxing;

CREATE TABLE IF NOT EXISTS biz_teacher_subject (
  id BIGINT NOT NULL AUTO_INCREMENT,
  teacher_id BIGINT NOT NULL,
  subject_id BIGINT NOT NULL,
  assign_time DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_teacher_subject (teacher_id, subject_id),
  KEY idx_teacher (teacher_id),
  KEY idx_subject (subject_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='教师-科目关联表';

INSERT IGNORE INTO biz_teacher_subject (teacher_id, subject_id)
SELECT t.id AS teacher_id, s.id AS subject_id
FROM biz_teacher t
CROSS JOIN biz_subject s;
