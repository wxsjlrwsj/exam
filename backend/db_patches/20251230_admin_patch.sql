SET NAMES utf8mb4;
USE chaoxing;

SET @exists_oper_name := (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='sys_oper_log' AND COLUMN_NAME='oper_name');
SET @sql_oper_name := IF(@exists_oper_name=0, 'ALTER TABLE sys_oper_log ADD COLUMN oper_name VARCHAR(50) NULL', 'SELECT 1');
PREPARE s1 FROM @sql_oper_name; EXECUTE s1; DEALLOCATE PREPARE s1;
SET @exists_oper_url := (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='sys_oper_log' AND COLUMN_NAME='oper_url');
SET @sql_oper_url := IF(@exists_oper_url=0, 'ALTER TABLE sys_oper_log ADD COLUMN oper_url VARCHAR(500) NULL', 'SELECT 1');
PREPARE s2 FROM @sql_oper_url; EXECUTE s2; DEALLOCATE PREPARE s2;
SET @exists_oper_ip := (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='sys_oper_log' AND COLUMN_NAME='oper_ip');
SET @sql_oper_ip := IF(@exists_oper_ip=0, 'ALTER TABLE sys_oper_log ADD COLUMN oper_ip VARCHAR(50) NULL', 'SELECT 1');
PREPARE s3 FROM @sql_oper_ip; EXECUTE s3; DEALLOCATE PREPARE s3;
SET @exists_oper_location := (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='sys_oper_log' AND COLUMN_NAME='oper_location');
SET @sql_oper_location := IF(@exists_oper_location=0, 'ALTER TABLE sys_oper_log ADD COLUMN oper_location VARCHAR(100) NULL', 'SELECT 1');
PREPARE s4 FROM @sql_oper_location; EXECUTE s4; DEALLOCATE PREPARE s4;
SET @exists_oper_param := (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='sys_oper_log' AND COLUMN_NAME='oper_param');
SET @sql_oper_param := IF(@exists_oper_param=0, 'ALTER TABLE sys_oper_log ADD COLUMN oper_param TEXT NULL', 'SELECT 1');
PREPARE s5 FROM @sql_oper_param; EXECUTE s5; DEALLOCATE PREPARE s5;
SET @exists_json_result := (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='sys_oper_log' AND COLUMN_NAME='json_result');
SET @sql_json_result := IF(@exists_json_result=0, 'ALTER TABLE sys_oper_log ADD COLUMN json_result TEXT NULL', 'SELECT 1');
PREPARE s6 FROM @sql_json_result; EXECUTE s6; DEALLOCATE PREPARE s6;
UPDATE sys_oper_log SET oper_name = operator_name WHERE oper_name IS NULL AND operator_name IS NOT NULL;
UPDATE sys_oper_log SET oper_url = request_url WHERE oper_url IS NULL AND request_url IS NOT NULL;
UPDATE sys_oper_log SET oper_ip = operator_ip WHERE oper_ip IS NULL AND operator_ip IS NOT NULL;
UPDATE sys_oper_log SET oper_location = operator_location WHERE oper_location IS NULL AND operator_location IS NOT NULL;
UPDATE sys_oper_log SET oper_param = request_param WHERE oper_param IS NULL AND request_param IS NOT NULL;
UPDATE sys_oper_log SET json_result = response_result WHERE json_result IS NULL AND response_result IS NOT NULL;

-- 用户已通过seed.sql预置到users表，此处不重复插入

INSERT IGNORE INTO biz_student(user_id,student_no,real_name,gender,class_id,major_code,enrollment_year,politics_status)
SELECT id, 'S2023005','孙七',1,100,'CS',2023,'群众' FROM users WHERE username='student5';
INSERT IGNORE INTO biz_student(user_id,student_no,real_name,gender,class_id,major_code,enrollment_year,politics_status)
SELECT id, 'S2023006','周八',0,100,'CS',2023,'团员' FROM users WHERE username='student6';
INSERT IGNORE INTO biz_student(user_id,student_no,real_name,gender,class_id,major_code,enrollment_year,politics_status)
SELECT id, 'S2023007','吴九',1,101,'CS',2023,'群众' FROM users WHERE username='student7';
INSERT IGNORE INTO biz_student(user_id,student_no,real_name,gender,class_id,major_code,enrollment_year,politics_status)
SELECT id, 'S2023008','郑十',0,101,'CS',2023,'团员' FROM users WHERE username='student8';
INSERT IGNORE INTO biz_student(user_id,student_no,real_name,gender,class_id,major_code,enrollment_year,politics_status)
SELECT id, 'S2023009','冯十一',1,102,'SE',2022,'群众' FROM users WHERE username='student9';
INSERT IGNORE INTO biz_student(user_id,student_no,real_name,gender,class_id,major_code,enrollment_year,politics_status)
SELECT id, 'S2023010','褚十二',0,102,'SE',2022,'团员' FROM users WHERE username='student10';
INSERT IGNORE INTO biz_student(user_id,student_no,real_name,gender,class_id,major_code,enrollment_year,politics_status)
SELECT id, 'S2023011','卫十三',1,100,'CS',2023,'群众' FROM users WHERE username='student11';
INSERT IGNORE INTO biz_student(user_id,student_no,real_name,gender,class_id,major_code,enrollment_year,politics_status)
SELECT id, 'S2023012','蒋十四',0,101,'CS',2023,'团员' FROM users WHERE username='student12';

INSERT IGNORE INTO sys_user_role(user_id,role_id)
SELECT u.id, r.id FROM users u JOIN sys_role r ON (
  (u.user_type='admin' AND r.role_key='ADMIN') OR
  (u.user_type='teacher' AND r.role_key='TEACHER') OR
  (u.user_type='student' AND r.role_key='STUDENT')
);

INSERT INTO sys_oper_log(title,business_type,method,request_method,oper_name,oper_url,oper_ip,oper_location,oper_param,json_result,status,error_msg,cost_time)
SELECT '查看考试列表',1,'StudentExamController.list','GET','student5','/api/student/exams','127.0.0.1','本地','{}','{"code":200}',0,NULL,9
WHERE NOT EXISTS (SELECT 1 FROM sys_oper_log WHERE oper_name='student5' AND method='StudentExamController.list' AND oper_url='/api/student/exams');
INSERT INTO sys_oper_log(title,business_type,method,request_method,oper_name,oper_url,oper_ip,oper_location,oper_param,json_result,status,error_msg,cost_time)
SELECT '查看考试列表',1,'StudentExamController.list','GET','student6','/api/student/exams','127.0.0.1','本地','{}','{"code":200}',0,NULL,10
WHERE NOT EXISTS (SELECT 1 FROM sys_oper_log WHERE oper_name='student6' AND method='StudentExamController.list' AND oper_url='/api/student/exams');
INSERT INTO sys_oper_log(title,business_type,method,request_method,oper_name,oper_url,oper_ip,oper_location,oper_param,json_result,status,error_msg,cost_time)
SELECT '查看考试列表',1,'StudentExamController.list','GET','student7','/api/student/exams','127.0.0.1','本地','{}','{"code":200}',0,NULL,11
WHERE NOT EXISTS (SELECT 1 FROM sys_oper_log WHERE oper_name='student7' AND method='StudentExamController.list' AND oper_url='/api/student/exams');
INSERT INTO sys_oper_log(title,business_type,method,request_method,oper_name,oper_url,oper_ip,oper_location,oper_param,json_result,status,error_msg,cost_time)
SELECT '查看考试列表',1,'StudentExamController.list','GET','student8','/api/student/exams','127.0.0.1','本地','{}','{"code":200}',0,NULL,9
WHERE NOT EXISTS (SELECT 1 FROM sys_oper_log WHERE oper_name='student8' AND method='StudentExamController.list' AND oper_url='/api/student/exams');
INSERT INTO sys_oper_log(title,business_type,method,request_method,oper_name,oper_url,oper_ip,oper_location,oper_param,json_result,status,error_msg,cost_time)
SELECT '查看考试列表',1,'StudentExamController.list','GET','student9','/api/student/exams','127.0.0.1','本地','{}','{"code":200}',0,NULL,12
WHERE NOT EXISTS (SELECT 1 FROM sys_oper_log WHERE oper_name='student9' AND method='StudentExamController.list' AND oper_url='/api/student/exams');
INSERT INTO sys_oper_log(title,business_type,method,request_method,oper_name,oper_url,oper_ip,oper_location,oper_param,json_result,status,error_msg,cost_time)
SELECT '查看考试列表',1,'StudentExamController.list','GET','student10','/api/student/exams','127.0.0.1','本地','{}','{"code":200}',0,NULL,8
WHERE NOT EXISTS (SELECT 1 FROM sys_oper_log WHERE oper_name='student10' AND method='StudentExamController.list' AND oper_url='/api/student/exams');
INSERT INTO sys_oper_log(title,business_type,method,request_method,oper_name,oper_url,oper_ip,oper_location,oper_param,json_result,status,error_msg,cost_time)
SELECT '查看考试列表',1,'StudentExamController.list','GET','student11','/api/student/exams','127.0.0.1','本地','{}','{"code":200}',0,NULL,7
WHERE NOT EXISTS (SELECT 1 FROM sys_oper_log WHERE oper_name='student11' AND method='StudentExamController.list' AND oper_url='/api/student/exams');
INSERT INTO sys_oper_log(title,business_type,method,request_method,oper_name,oper_url,oper_ip,oper_location,oper_param,json_result,status,error_msg,cost_time)
SELECT '查看考试列表',1,'StudentExamController.list','GET','student12','/api/student/exams','127.0.0.1','本地','{}','{"code":200}',0,NULL,10
WHERE NOT EXISTS (SELECT 1 FROM sys_oper_log WHERE oper_name='student12' AND method='StudentExamController.list' AND oper_url='/api/student/exams');
INSERT INTO sys_oper_log(title,business_type,method,request_method,oper_name,oper_url,oper_ip,oper_location,oper_param,json_result,status,error_msg,cost_time)
SELECT '查看成绩',1,'StudentExamController.result','GET','student5','/api/student/exams/1/result','127.0.0.1','本地','{}','{"code":200}',0,NULL,13
WHERE NOT EXISTS (SELECT 1 FROM sys_oper_log WHERE oper_name='student5' AND method='StudentExamController.result' AND oper_url='/api/student/exams/1/result');
INSERT INTO sys_oper_log(title,business_type,method,request_method,oper_name,oper_url,oper_ip,oper_location,oper_param,json_result,status,error_msg,cost_time)
SELECT '回顾试卷',1,'StudentExamController.review','GET','student6','/api/student/exams/1/review','127.0.0.1','本地','{}','{"code":200}',0,NULL,14
WHERE NOT EXISTS (SELECT 1 FROM sys_oper_log WHERE oper_name='student6' AND method='StudentExamController.review' AND oper_url='/api/student/exams/1/review');

-- 修复管理员密码以支持 admin1 使用 123456 登录
UPDATE users 
SET password_hash = '$2a$10$ybYHxhvWIkuftAE9W50GGOK4DpfTc1RaBkr5Cmxj.KY3FJWiQ..36' 
WHERE username='admin1';

-- 修复角色-菜单授权映射，保证管理员与教师角色拥有基础教学菜单
INSERT IGNORE INTO sys_role_menu(role_id, menu_id)
SELECT (SELECT id FROM sys_role WHERE role_key='ADMIN'), m.id
FROM sys_menu m
WHERE m.perms IN ('bank:view','paper:view','exam:view','score:view','audit:view');

INSERT IGNORE INTO sys_role_menu(role_id, menu_id)
SELECT (SELECT id FROM sys_role WHERE role_key='TEACHER'), m.id
FROM sys_menu m
WHERE m.perms IN ('bank:view','paper:view','exam:view','score:view','audit:view');
