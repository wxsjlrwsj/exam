
CREATE TABLE IF NOT EXISTS biz_teacher_subject (
  teacher_id BIGINT NOT NULL,
  subject_id BIGINT NOT NULL,
  PRIMARY KEY (teacher_id, subject_id)
);

UPDATE biz_subject SET name='Java程序设计' WHERE code='java';
UPDATE biz_subject SET name='数据结构' WHERE code='ds';
UPDATE biz_subject SET name='计算机网络' WHERE code='network';
UPDATE biz_subject SET name='操作系统' WHERE code='os';
UPDATE biz_subject SET name='数据库原理' WHERE code='database';
UPDATE biz_subject SET name='软件工程' WHERE code='se';
UPDATE biz_subject SET name='计算机组成原理' WHERE code='computer_org';
UPDATE biz_subject SET name='编译原理' WHERE code='compiler';

INSERT IGNORE INTO biz_teacher_subject (teacher_id, subject_id) 
SELECT u.id, s.id FROM users u, biz_subject s 
WHERE u.username='teacher1' AND s.code IN ('ds', 'os', 'java');

INSERT IGNORE INTO biz_teacher_subject (teacher_id, subject_id) 
SELECT u.id, s.id FROM users u, biz_subject s 
WHERE u.username='admin' AND s.code IN ('ds', 'os', 'java', 'network', 'database');
