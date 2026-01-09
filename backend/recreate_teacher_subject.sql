SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

USE chaoxing;

CREATE TABLE IF NOT EXISTS biz_teacher_subject (
  teacher_id BIGINT NOT NULL,
  subject_id BIGINT NOT NULL,
  PRIMARY KEY (teacher_id, subject_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 1. Get teacher1 ID
SET @t1_id = (SELECT id FROM users WHERE username='teacher1');
-- 2. Get Subject IDs
SET @ds_id = (SELECT id FROM biz_subject WHERE code='ds');
SET @os_id = (SELECT id FROM biz_subject WHERE code='os');
SET @java_id = (SELECT id FROM biz_subject WHERE code='java');

-- 3. Insert
INSERT IGNORE INTO biz_teacher_subject (teacher_id, subject_id) VALUES (@t1_id, @ds_id);
INSERT IGNORE INTO biz_teacher_subject (teacher_id, subject_id) VALUES (@t1_id, @os_id);
INSERT IGNORE INTO biz_teacher_subject (teacher_id, subject_id) VALUES (@t1_id, @java_id);
