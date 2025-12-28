SET NAMES utf8mb4;
USE chaoxing;

-- Create teacher_subject table
CREATE TABLE IF NOT EXISTS biz_teacher_subject (
  teacher_id BIGINT NOT NULL,
  subject_id BIGINT NOT NULL,
  PRIMARY KEY (teacher_id, subject_id)
);

-- Fix subject names (in case of garbled text)
UPDATE biz_subject SET name='Java程序设计' WHERE code='java';
UPDATE biz_subject SET name='数据结构' WHERE code='ds';
UPDATE biz_subject SET name='计算机网络' WHERE code='network';
UPDATE biz_subject SET name='操作系统' WHERE code='os';
UPDATE biz_subject SET name='数据库原理' WHERE code='database';
UPDATE biz_subject SET name='软件工程' WHERE code='se';
UPDATE biz_subject SET name='计算机组成原理' WHERE code='computer_org';
UPDATE biz_subject SET name='编译原理' WHERE code='compiler';

-- Assign teacher1 to DS and OS
-- Get IDs first (using variables)
SET @t1_id = (SELECT id FROM users WHERE username='teacher1');
SET @ds_id = (SELECT id FROM biz_subject WHERE code='ds');
SET @os_id = (SELECT id FROM biz_subject WHERE code='os');

INSERT IGNORE INTO biz_teacher_subject (teacher_id, subject_id) VALUES (@t1_id, @ds_id);
INSERT IGNORE INTO biz_teacher_subject (teacher_id, subject_id) VALUES (@t1_id, @os_id);
