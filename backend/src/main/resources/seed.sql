SET NAMES utf8mb4;
USE chaoxing;

-- 题型字典 5 条
INSERT IGNORE INTO biz_question_type(type_id,type_name,type_code,answer_json,config_json,is_active,create_time,update_time) VALUES
 (1,'单选题','SINGLE',CAST('[\"B\"]' AS JSON),CAST('{\"leak_score\":0.0,\"max_option\":5,\"is_objective\":true,\"requires_file_id\":false}' AS JSON),1,NOW(),NOW()),
 (2,'多选题','MULTI',CAST('[\"A\",\"C\"]' AS JSON),CAST('{\"leak_score\":0.5,\"max_option\":6,\"is_objective\":true,\"requires_file_id\":false}' AS JSON),1,NOW(),NOW()),
 (3,'判断题','TRUE_FALSE',CAST('true' AS JSON),CAST('{\"is_objective\":true,\"requires_file_id\":false}' AS JSON),1,NOW(),NOW()),
 (4,'填空题','FILL',CAST('[\"空1\",\"空2\"]' AS JSON),CAST('{\"is_objective\":false,\"requires_file_id\":false}' AS JSON),1,NOW(),NOW()),
 (5,'简答题','SHORT',CAST('"文本"' AS JSON),CAST('{\"is_objective\":false,\"requires_file_id\":false}' AS JSON),1,NOW(),NOW());

-- 系统模块 5 条
INSERT IGNORE INTO system_modules(name,code,category,version,enabled,show_in_menu,route_path,allowed_roles,dependencies,description) VALUES
 ('题目审核','tch_audit','teacher','1.0',1,1,'/audit','TEACHER,ADMIN','', '审核老师或学生试题'),
 ('题库管理','tch_bank','teacher','1.0',1,1,'/bank','TEACHER,ADMIN','', '维护系统题库'),
 ('试卷管理','tch_paper','teacher','1.0',1,1,'/papers','TEACHER,ADMIN','', '组卷与维护'),
 ('考试管理','tch_exam','teacher','1.0',1,1,'/exams','TEACHER,ADMIN','', '发布考试与监考'),
 ('成绩管理','tch_score','teacher','1.0',1,1,'/scores','TEACHER,ADMIN','', '阅卷与统计');

-- 科目字典 8 条
INSERT IGNORE INTO biz_subject (name, code, description) VALUES
('Java程序设计', 'java', 'Java编程语言基础与应用'),
('数据结构', 'ds', '数据结构与算法'),
('计算机网络', 'network', '计算机网络原理'),
('操作系统', 'os', '操作系统原理与设计'),
('数据库原理', 'database', '数据库系统原理'),
('软件工程', 'se', '软件工程方法与实践'),
('计算机组成原理', 'computer_org', '计算机硬件系统'),
('编译原理', 'compiler', '编译原理与技术');

-- 组织 5 条
INSERT IGNORE INTO sys_organization(parent_id,name,code,type,sort_order,path,status,leader,phone,description) VALUES
(NULL,'信息学院','ORG-INFO','dept',1,'/信息学院',1,'张主任','0571-0000001','学院'),
(NULL,'计算机系','ORG-CS','dept',1,'/信息学院/计算机系',1,'李老师','0571-0000002','系'),
(NULL,'软件工程系','ORG-SE','dept',2,'/信息学院/软件工程系',1,'王老师','0571-0000003','系'),
(NULL,'机电学院','ORG-MECH','dept',2,'/机电学院',1,'赵主任','0571-0000004','学院'),
(NULL,'自动化系','ORG-AUTO','dept',1,'/机电学院/自动化系',1,'钱老师','0571-0000005','系');

-- 班级补齐，确保学生档案 class_id 有对应机构
SET @org_cs_id = (SELECT id FROM sys_organization WHERE code='ORG-CS');
SET @org_se_id = (SELECT id FROM sys_organization WHERE code='ORG-SE');
INSERT IGNORE INTO sys_organization(id,parent_id,name,code,type,sort_order,path,status,leader,phone,description) VALUES
 (100,@org_cs_id,'计科一班','CLS-CS-101','class',1,'/信息学院/计算机系/计科一班',1,'班主任甲','0571-1000001','班级'),
 (101,@org_cs_id,'计科二班','CLS-CS-102','class',2,'/信息学院/计算机系/计科二班',1,'班主任乙','0571-1000002','班级'),
 (102,@org_se_id,'软工一班','CLS-SE-101','class',1,'/信息学院/软件工程系/软工一班',1,'班主任丙','0571-1000003','班级');

-- 班级表 5 条（用于教师端班级选择）
INSERT IGNORE INTO biz_class (class_name, class_code, grade, major) VALUES
('计算机科学与技术1班', 'cs1', '2021', '计算机科学与技术'),
('计算机科学与技术2班', 'cs2', '2021', '计算机科学与技术'),
('软件工程1班', 'se1', '2021', '软件工程'),
('软件工程2班', 'se2', '2021', '软件工程'),
('网络工程1班', 'ne1', '2021', '网络工程');

-- 初始化基础用户（仅当不存在时插入），供档案引用
INSERT IGNORE INTO users(username,email,phone,password_hash,user_type,real_name,avatar) VALUES
 ('admin1','admin1@example.com',NULL,'$2a$10$zJpIYkPp7OLoOqMZ9o4m3uQV1YVQdGmJ8VxgQf3o3PzF8q6QJk7uS','admin','管理员一',NULL),
 ('teacher1','teacher1@example.com',NULL,'$2a$10$zJpIYkPp7OLoOqMZ9o4m3uQV1YVQdGmJ8VxgQf3o3PzF8q6QJk7uS','teacher','教师一',NULL),
 ('teacher2','teacher2@example.com',NULL,'$2a$10$zJpIYkPp7OLoOqMZ9o4m3uQV1YVQdGmJ8VxgQf3o3PzF8q6QJk7uS','teacher','教师二',NULL),
 ('teacher3','teacher3@example.com',NULL,'$2a$10$zJpIYkPp7OLoOqMZ9o4m3uQV1YVQdGmJ8VxgQf3o3PzF8q6QJk7uS','teacher','教师三',NULL),
 ('teacher4','teacher4@example.com',NULL,'$2a$10$zJpIYkPp7OLoOqMZ9o4m3uQV1YVQdGmJ8VxgQf3o3PzF8q6QJk7uS','teacher','教师四',NULL),
 ('teacher5','teacher5@example.com',NULL,'$2a$10$zJpIYkPp7OLoOqMZ9o4m3uQV1YVQdGmJ8VxgQf3o3PzF8q6QJk7uS','teacher','教师五',NULL),
 ('student1','student1@example.com',NULL,'$2a$10$zJpIYkPp7OLoOqMZ9o4m3uQV1YVQdGmJ8VxgQf3o3PzF8q6QJk7uS','student','学生一',NULL),
 ('student2','student2@example.com',NULL,'$2a$10$zJpIYkPp7OLoOqMZ9o4m3uQV1YVQdGmJ8VxgQf3o3PzF8q6QJk7uS','student','学生二',NULL),
 ('student3','student3@example.com',NULL,'$2a$10$zJpIYkPp7OLoOqMZ9o4m3uQV1YVQdGmJ8VxgQf3o3PzF8q6QJk7uS','student','学生三',NULL),
 ('student4','student4@example.com',NULL,'$2a$10$zJpIYkPp7OLoOqMZ9o4m3uQV1YVQdGmJ8VxgQf3o3PzF8q6QJk7uS','student','学生四',NULL),
 ('test','test@example.com',NULL,'$2a$10$zJpIYkPp7OLoOqMZ9o4m3uQV1YVQdGmJ8VxgQf3o3PzF8q6QJk7uS','student','测试生',NULL);

-- 角色 5 条
INSERT IGNORE INTO sys_role(role_name,role_key,data_scope,status,remark) VALUES
 ('管理员','ADMIN','1',1,'系统管理员'),
 ('教师','TEACHER','1',1,'教师角色'),
 ('学生','STUDENT','1',1,'学生角色'),
 ('监考','MONITOR','1',1,'监考角色'),
 ('审核员','AUDITOR','1',1,'审核角色');

-- 菜单 5 条
INSERT IGNORE INTO sys_menu(parent_id,name,type,perms,path,component,icon,sort_order,visible) VALUES
 (0,'题库管理','M','bank:view','/bank','teacher/Bank.vue','Collection',1,1),
 (0,'试卷管理','M','paper:view','/papers','teacher/Paper.vue','Document',2,1),
 (0,'考试管理','M','exam:view','/exams','teacher/Exam.vue','Timer',3,1),
 (0,'成绩管理','M','score:view','/scores','teacher/Score.vue','Histogram',4,1),
 (0,'审核管理','M','audit:view','/audit','teacher/Audit.vue','CircleCheck',5,1);

-- 用户-角色映射（按类型自动）
INSERT IGNORE INTO sys_user_role(user_id,role_id)
 SELECT u.id, r.id FROM users u JOIN sys_role r ON (
   (u.user_type='admin' AND r.role_key='ADMIN') OR
   (u.user_type='teacher' AND r.role_key='TEACHER') OR
   (u.user_type='student' AND r.role_key='STUDENT')
 );

-- 角色-菜单映射（ADMIN/TEACHER 有所有教学菜单）
INSERT IGNORE INTO sys_role_menu(role_id,menu_id)
 SELECT r.id, m.id FROM sys_role r JOIN sys_menu m ON (
   (r.role_key IN ('ADMIN','TEACHER') AND m.perms IN ('bank:view','paper:view','exam:view','score:view','audit:view'))
 );

-- 教师与学生档案 5 条各
INSERT IGNORE INTO biz_teacher(user_id,teacher_no,real_name,dept_id,title,entry_date) VALUES
 ((SELECT id FROM users WHERE username='teacher1'),'T2023001','教师一',(SELECT id FROM sys_organization WHERE code='ORG-CS'),'讲师','2023-09-01'),
 ((SELECT id FROM users WHERE username='teacher2'),'T2023002','教师二',(SELECT id FROM sys_organization WHERE code='ORG-SE'),'副教授','2022-03-01'),
 ((SELECT id FROM users WHERE username='teacher3'),'T2023003','教师三',(SELECT id FROM sys_organization WHERE code='ORG-CS'),'讲师','2021-06-01'),
 ((SELECT id FROM users WHERE username='teacher4'),'T2023004','教师四',(SELECT id FROM sys_organization WHERE code='ORG-CS'),'教授','2019-01-01'),
 ((SELECT id FROM users WHERE username='teacher5'),'T2023005','教师五',(SELECT id FROM sys_organization WHERE code='ORG-SE'),'讲师','2020-10-01');

INSERT IGNORE INTO biz_student(user_id,student_no,real_name,gender,class_id,major_code,enrollment_year,politics_status) VALUES
 ((SELECT id FROM users WHERE username='test'),'S2023000','测试生',1,100,'CS',2023,'群众'),
 ((SELECT id FROM users WHERE username='student1'),'S2023001','张三',1,101,'CS',2023,'群众'),
 ((SELECT id FROM users WHERE username='student2'),'S2023002','李四',1,101,'CS',2023,'团员'),
 ((SELECT id FROM users WHERE username='student3'),'S2023003','王五',1,102,'SE',2022,'群众'),
 ((SELECT id FROM users WHERE username='student4'),'S2023004','赵六',0,102,'SE',2022,'团员');

-- 题目（四门学科各5题，共20题）
INSERT IGNORE INTO biz_question(type_id,content,options,answer,analysis,difficulty,subject,knowledge_points,file_id,creator_id,status,create_time)
 VALUES
 (1,'关系数据库中主键的作用是？',CAST('[{"key":"A","value":"唯一标识记录"},{"key":"B","value":"限制空值"},{"key":"C","value":"提升查询速度"}]' AS JSON),CAST('["A"]' AS JSON),'主键用于唯一标识记录',1,'数据库设计','主键',NULL,(SELECT id FROM users WHERE username='teacher1'),1,NOW()),
 (2,'下列哪些属于数据库设计范式？',CAST('[{"key":"A","value":"第一范式"},{"key":"B","value":"第二范式"},{"key":"C","value":"外键范式"},{"key":"D","value":"第三范式"}]' AS JSON),CAST('["A","B","D"]' AS JSON),'数据库三大范式',2,'数据库设计','范式',NULL,(SELECT id FROM users WHERE username='teacher2'),1,NOW()),
 (3,'BCNF比3NF更强，对吗？',NULL,CAST('true' AS JSON),'BCNF是更严格的范式',1,'数据库设计','BCNF',NULL,(SELECT id FROM users WHERE username='teacher3'),1,NOW()),
 (4,'ER模型中的三种基本元素是：实体、____、____',NULL,CAST('["属性","联系"]' AS JSON),NULL,2,'数据库设计','ER模型',NULL,(SELECT id FROM users WHERE username='teacher4'),1,NOW()),
 (5,'简述事务的ACID特性',NULL,CAST('"原子性、一致性、隔离性、持久性"' AS JSON),NULL,3,'数据库设计','事务',NULL,(SELECT id FROM users WHERE username='teacher5'),1,NOW()),
 (1,'对称加密的特点是？',CAST('[{"key":"A","value":"同一密钥加密解密"},{"key":"B","value":"公钥加密"},{"key":"C","value":"哈希不可逆"}]' AS JSON),CAST('["A"]' AS JSON),'对称加密密钥相同',1,'计算机网络安全','加密',NULL,(SELECT id FROM users WHERE username='teacher1'),1,NOW()),
 (2,'常见的网络攻击类型有？',CAST('[{"key":"A","value":"DDoS"},{"key":"B","value":"SQL注入"},{"key":"C","value":"XSS"},{"key":"D","value":"DHCP"}]' AS JSON),CAST('["A","B","C"]' AS JSON),'网络攻击分类',2,'计算机网络安全','攻击类型',NULL,(SELECT id FROM users WHERE username='teacher2'),1,NOW()),
 (3,'HTTPS是基于TLS的协议，对吗？',NULL,CAST('true' AS JSON),'HTTPS运行在TLS之上',1,'计算机网络安全','HTTPS/TLS',NULL,(SELECT id FROM users WHERE username='teacher3'),1,NOW()),
 (4,'TLS握手中用于服务器身份验证的证书由____颁发',NULL,CAST('["CA"]' AS JSON),NULL,2,'计算机网络安全','证书',NULL,(SELECT id FROM users WHERE username='teacher4'),1,NOW()),
 (5,'简述防火墙的主要作用',NULL,CAST('"基于策略过滤流量，隔离内外网络"' AS JSON),NULL,3,'计算机网络安全','防火墙',NULL,(SELECT id FROM users WHERE username='teacher5'),1,NOW()),
 (1,'发生网络分区时通常无法同时满足哪两项？',CAST('[{"key":"A","value":"一致性与可用性"},{"key":"B","value":"一致性与分区容忍"},{"key":"C","value":"可用性与分区容忍"}]' AS JSON),CAST('["A"]' AS JSON),'CAP定理',2,'分布式系统原理','CAP',NULL,(SELECT id FROM users WHERE username='teacher1'),1,NOW()),
 (2,'常见的一致性算法有？',CAST('[{"key":"A","value":"Paxos"},{"key":"B","value":"Raft"},{"key":"C","value":"两阶段提交"},{"key":"D","value":"Gossip"}]' AS JSON),CAST('["A","B"]' AS JSON),'共识算法',3,'分布式系统原理','一致性算法',NULL,(SELECT id FROM users WHERE username='teacher2'),1,NOW()),
 (3,'最终一致性允许临时不一致，对吗？',NULL,CAST('true' AS JSON),'最终一致性定义',2,'分布式系统原理','一致性',NULL,(SELECT id FROM users WHERE username='teacher3'),1,NOW()),
 (4,'用于将事件按顺序排列的是____时钟',NULL,CAST('["逻辑"]' AS JSON),NULL,2,'分布式系统原理','Lamport时钟',NULL,(SELECT id FROM users WHERE username='teacher4'),1,NOW()),
 (5,'简述Leader选举的作用',NULL,CAST('"确定主节点以协调集群状态"' AS JSON),NULL,3,'分布式系统原理','选举',NULL,(SELECT id FROM users WHERE username='teacher5'),1,NOW()),
 (1,'以下哪项属于监督学习？',CAST('[{"key":"A","value":"K-means"},{"key":"B","value":"线性回归"},{"key":"C","value":"PCA"}]' AS JSON),CAST('["B"]' AS JSON),'监督学习示例',1,'人工智能基础','监督学习',NULL,(SELECT id FROM users WHERE username='teacher1'),1,NOW()),
 (2,'常见的激活函数有？',CAST('[{"key":"A","value":"ReLU"},{"key":"B","value":"Sigmoid"},{"key":"C","value":"Tanh"},{"key":"D","value":"Softmax"}]' AS JSON),CAST('["A","B","C"]' AS JSON),'激活函数',2,'人工智能基础','激活函数',NULL,(SELECT id FROM users WHERE username='teacher2'),1,NOW()),
 (3,'过拟合常由模型过于复杂导致，对吗？',NULL,CAST('true' AS JSON),'过拟合原因',1,'人工智能基础','过拟合',NULL,(SELECT id FROM users WHERE username='teacher3'),1,NOW()),
 (4,'梯度下降的核心是沿____方向更新参数',NULL,CAST('["负梯度"]' AS JSON),NULL,2,'人工智能基础','优化',NULL,(SELECT id FROM users WHERE username='teacher4'),1,NOW()),
 (5,'简述训练集与测试集的区别',NULL,CAST('"训练用于拟合模型，测试用于评估泛化"' AS JSON),NULL,3,'人工智能基础','数据集',NULL,(SELECT id FROM users WHERE username='teacher5'),1,NOW());

-- 清理旧试卷、考试及关联数据（按名称前缀）
DELETE FROM biz_exam_answer WHERE record_id IN (
  SELECT id FROM biz_exam_record WHERE exam_id IN (
    SELECT id FROM biz_exam WHERE name LIKE 'Java%' OR name LIKE '网络%' OR name LIKE '算法%' OR name LIKE '操作系统%'
  )
);
DELETE FROM biz_exam_record WHERE exam_id IN (
  SELECT id FROM biz_exam WHERE name LIKE 'Java%' OR name LIKE '网络%' OR name LIKE '算法%' OR name LIKE '操作系统%'
);
DELETE FROM biz_exam_student WHERE exam_id IN (
  SELECT id FROM biz_exam WHERE name LIKE 'Java%' OR name LIKE '网络%' OR name LIKE '算法%' OR name LIKE '操作系统%'
);
DELETE FROM biz_exam WHERE name LIKE 'Java%' OR name LIKE '网络%' OR name LIKE '算法%' OR name LIKE '操作系统%';
DELETE FROM biz_paper_question WHERE paper_id IN (
  SELECT id FROM biz_paper WHERE subject IN ('Java','网络','算法','操作系统') OR name LIKE 'Java%' OR name LIKE '网络%' OR name LIKE '算法%' OR name LIKE '操作系统%'
);
DELETE FROM biz_paper WHERE subject IN ('Java','网络','算法','操作系统') OR name LIKE 'Java%' OR name LIKE '网络%' OR name LIKE '算法%' OR name LIKE '操作系统%';

-- 试卷 4 条（学科名更完整）
INSERT IGNORE INTO biz_paper(name,subject,total_score,pass_score,question_count,status,creator_id)
 VALUES
 ('数据库设计试卷1','数据库设计',100,60,5,1,(SELECT id FROM users WHERE username='teacher1')),
 ('计算机网络安全试卷1','计算机网络安全',100,60,5,0,(SELECT id FROM users WHERE username='teacher2')),
 ('分布式系统原理试卷1','分布式系统原理',100,60,5,0,(SELECT id FROM users WHERE username='teacher3')),
 ('人工智能基础试卷1','人工智能基础',100,60,5,0,(SELECT id FROM users WHERE username='teacher4'));

INSERT IGNORE INTO biz_paper(name,subject,total_score,pass_score,question_count,status,creator_id)
 VALUES
('数据库设计综合试卷A','数据库设计',100,60,5,1,(SELECT id FROM users WHERE username='teacher1')),
('计算机网络安全阶段性试卷B','计算机网络安全',100,60,5,1,(SELECT id FROM users WHERE username='teacher2')),
('分布式系统原理期末试卷C','分布式系统原理',100,60,5,1,(SELECT id FROM users WHERE username='teacher3')),
('人工智能基础结课试卷D','人工智能基础',100,60,5,1,(SELECT id FROM users WHERE username='teacher4'));

-- 试卷题目关联（确保每张试卷涵盖不同题型）
INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name='数据库设计综合试卷A'), q.id, 20, 1
 FROM (SELECT id FROM biz_question WHERE type_id=1 AND subject='数据库设计' ORDER BY id LIMIT 1) q;
INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name='数据库设计综合试卷A'), q.id, 20, 2
 FROM (SELECT id FROM biz_question WHERE type_id=2 AND subject='数据库设计' ORDER BY id LIMIT 1) q;
INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name='数据库设计综合试卷A'), q.id, 20, 3
 FROM (SELECT id FROM biz_question WHERE type_id=3 AND subject='数据库设计' ORDER BY id LIMIT 1) q;
INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name='数据库设计综合试卷A'), q.id, 20, 4
 FROM (SELECT id FROM biz_question WHERE type_id=4 AND subject='数据库设计' ORDER BY id LIMIT 1) q;
INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name='数据库设计综合试卷A'), q.id, 20, 5
 FROM (SELECT id FROM biz_question WHERE type_id=5 AND subject='数据库设计' ORDER BY id LIMIT 1) q;

INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name='计算机网络安全阶段性试卷B'), q.id, 20, 1
 FROM (SELECT id FROM biz_question WHERE type_id=1 AND subject='计算机网络安全' ORDER BY id LIMIT 1) q;
INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name='计算机网络安全阶段性试卷B'), q.id, 20, 2
 FROM (SELECT id FROM biz_question WHERE type_id=2 AND subject='计算机网络安全' ORDER BY id LIMIT 1) q;
INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name='计算机网络安全阶段性试卷B'), q.id, 20, 3
 FROM (SELECT id FROM biz_question WHERE type_id=3 AND subject='计算机网络安全' ORDER BY id LIMIT 1) q;
INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name='计算机网络安全阶段性试卷B'), q.id, 20, 4
 FROM (SELECT id FROM biz_question WHERE type_id=4 AND subject='计算机网络安全' ORDER BY id LIMIT 1) q;
INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name='计算机网络安全阶段性试卷B'), q.id, 20, 5
 FROM (SELECT id FROM biz_question WHERE type_id=5 AND subject='计算机网络安全' ORDER BY id LIMIT 1) q;

INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name='分布式系统原理期末试卷C'), q.id, 20, 1
 FROM (SELECT id FROM biz_question WHERE type_id=1 AND subject='分布式系统原理' ORDER BY id LIMIT 1) q;
INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name='分布式系统原理期末试卷C'), q.id, 20, 2
 FROM (SELECT id FROM biz_question WHERE type_id=2 AND subject='分布式系统原理' ORDER BY id LIMIT 1) q;
INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name='分布式系统原理期末试卷C'), q.id, 20, 3
 FROM (SELECT id FROM biz_question WHERE type_id=3 AND subject='分布式系统原理' ORDER BY id LIMIT 1) q;
INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name='分布式系统原理期末试卷C'), q.id, 20, 4
 FROM (SELECT id FROM biz_question WHERE type_id=4 AND subject='分布式系统原理' ORDER BY id LIMIT 1) q;
INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name='分布式系统原理期末试卷C'), q.id, 20, 5
 FROM (SELECT id FROM biz_question WHERE type_id=5 AND subject='分布式系统原理' ORDER BY id LIMIT 1) q;

INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name='人工智能基础结课试卷D'), q.id, 20, 1
 FROM (SELECT id FROM biz_question WHERE type_id=1 AND subject='人工智能基础' ORDER BY id LIMIT 1) q;
INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name='人工智能基础结课试卷D'), q.id, 20, 2
 FROM (SELECT id FROM biz_question WHERE type_id=2 AND subject='人工智能基础' ORDER BY id LIMIT 1) q;
INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name='人工智能基础结课试卷D'), q.id, 20, 3
 FROM (SELECT id FROM biz_question WHERE type_id=3 AND subject='人工智能基础' ORDER BY id LIMIT 1) q;
INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name='人工智能基础结课试卷D'), q.id, 20, 4
 FROM (SELECT id FROM biz_question WHERE type_id=4 AND subject='人工智能基础' ORDER BY id LIMIT 1) q;
INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name='人工智能基础结课试卷D'), q.id, 20, 5
 FROM (SELECT id FROM biz_question WHERE type_id=5 AND subject='人工智能基础' ORDER BY id LIMIT 1) q;
-- 试卷题目关联（每张试卷关联对应学科的前5题）
INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name='数据库设计试卷1'), q.id, 20, ROW_NUMBER() OVER (ORDER BY q.id)
 FROM (SELECT id FROM biz_question WHERE subject='数据库设计' ORDER BY id LIMIT 5) q;
INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name='计算机网络安全试卷1'), q.id, 20, ROW_NUMBER() OVER (ORDER BY q.id)
 FROM (SELECT id FROM biz_question WHERE subject='计算机网络安全' ORDER BY id LIMIT 5) q;
INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name='分布式系统原理试卷1'), q.id, 20, ROW_NUMBER() OVER (ORDER BY q.id)
 FROM (SELECT id FROM biz_question WHERE subject='分布式系统原理' ORDER BY id LIMIT 5) q;
INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name='人工智能基础试卷1'), q.id, 20, ROW_NUMBER() OVER (ORDER BY q.id)
 FROM (SELECT id FROM biz_question WHERE subject='人工智能基础' ORDER BY id LIMIT 5) q;

-- 考试 4 条（与新试卷对应）
INSERT IGNORE INTO biz_exam(name,paper_id,start_time,end_time,duration,status,creator_id)
 VALUES
 ('数据库设计期末考试1',(SELECT id FROM biz_paper WHERE name='数据库设计试卷1'),'2025-12-20 09:00:00','2025-12-20 11:00:00',120,1,(SELECT id FROM users WHERE username='teacher1')),
 ('计算机网络安全期末考试1',(SELECT id FROM biz_paper WHERE name='计算机网络安全试卷1'),'2025-12-21 09:00:00','2025-12-21 11:00:00',120,0,(SELECT id FROM users WHERE username='teacher2')),
 ('分布式系统原理期末考试1',(SELECT id FROM biz_paper WHERE name='分布式系统原理试卷1'),'2025-12-22 09:00:00','2025-12-22 11:00:00',120,0,(SELECT id FROM users WHERE username='teacher3')),
 ('人工智能基础期末考试1',(SELECT id FROM biz_paper WHERE name='人工智能基础试卷1'),'2025-12-23 09:00:00','2025-12-23 11:00:00',120,0,(SELECT id FROM users WHERE username='teacher4'));

INSERT IGNORE INTO biz_exam(name,paper_id,start_time,end_time,duration,status,creator_id)
 VALUES
 ('数据库设计课程期末统一考试（2025冬季）',(SELECT id FROM biz_paper WHERE name='数据库设计综合试卷A'),'2025-12-26 09:00:00','2025-12-26 23:00:00',840,1,(SELECT id FROM users WHERE username='teacher1')),
 ('计算机网络安全课程阶段性测评（第十三周）',(SELECT id FROM biz_paper WHERE name='计算机网络安全阶段性试卷B'),'2025-12-24 08:00:00','2025-12-28 20:00:00',5760,1,(SELECT id FROM users WHERE username='teacher2')),
 ('人工智能基础课程期末统一考试（2026春季）',(SELECT id FROM biz_paper WHERE name='人工智能基础结课试卷D'),'2026-01-10 09:00:00','2026-01-10 11:00:00',120,0,(SELECT id FROM users WHERE username='teacher4')),
 ('分布式系统原理课程期末统一考试（2025秋季）',(SELECT id FROM biz_paper WHERE name='分布式系统原理期末试卷C'),'2025-10-01 08:00:00','2025-10-01 20:00:00',720,2,(SELECT id FROM users WHERE username='teacher3'));

-- 考试记录 4 条
INSERT IGNORE INTO biz_exam_record(exam_id,student_id,score,status,start_time,submit_time)
 VALUES
 ((SELECT id FROM biz_exam WHERE name='数据库设计期末考试1'),(SELECT id FROM users WHERE username='student1'),NULL,0,NOW(),NULL),
 ((SELECT id FROM biz_exam WHERE name='数据库设计期末考试1'),(SELECT id FROM users WHERE username='student2'),NULL,0,NOW(),NULL),
 ((SELECT id FROM biz_exam WHERE name='计算机网络安全期末考试1'),(SELECT id FROM users WHERE username='student3'),NULL,0,NOW(),NULL),
 ((SELECT id FROM biz_exam WHERE name='分布式系统原理期末考试1'),(SELECT id FROM users WHERE username='student1'),NULL,0,NOW(),NULL);

INSERT IGNORE INTO biz_exam_student (exam_id, user_id)
SELECT e.id, (SELECT id FROM users WHERE username='student1')
FROM biz_exam e
WHERE e.name IN (
'数据库设计课程期末统一考试（2025冬季）',
'计算机网络安全课程阶段性测评（第十三周）',
'人工智能基础课程期末统一考试（2026春季）',
'分布式系统原理课程期末统一考试（2025秋季）'
);

-- 答题明细 4 条
INSERT IGNORE INTO biz_exam_answer(record_id,question_id,student_answer,score,is_correct,comment)
 SELECT r.id, q.id, CAST('["A"]' AS JSON), NULL, NULL, NULL
 FROM (SELECT id FROM biz_exam_record ORDER BY id LIMIT 4) r
 JOIN (SELECT id FROM biz_question ORDER BY id LIMIT 1) q;

INSERT IGNORE INTO biz_question_audit(submitter_id,submit_time,type_id,content,answer,difficulty,subject_id,status,audit_comment,auditor_id,audit_time)
 VALUES
 ((SELECT id FROM users WHERE username='teacher1'),NOW(),1,'{"stem":"题干1"}','参考答案1',2,1,1,'通过',(SELECT id FROM users WHERE username='admin1'),NOW()),
 ((SELECT id FROM users WHERE username='teacher2'),NOW(),2,'{"stem":"题干2"}','参考答案2',3,1,2,'描述不清',NULL,NULL),
 ((SELECT id FROM users WHERE username='student1'),NOW(),1,'{"stem":"题干3"}','参考答案3',1,1,0,NULL,NULL,NULL),
 ((SELECT id FROM users WHERE username='teacher3'),NOW(),3,'{"stem":"题干4"}','参考答案4',2,1,1,'通过',(SELECT id FROM users WHERE username='admin1'),NOW()),
 ((SELECT id FROM users WHERE username='student2'),NOW(),4,'{"stem":"题干5"}','参考答案5',3,1,2,'不符合规范',NULL,NULL);

INSERT IGNORE INTO sys_oper_log(title,business_type,method,request_method,oper_name,oper_url,oper_ip,oper_location,oper_param,json_result,status,error_msg,cost_time)
 VALUES
 ('登录',1,'AuthController.login','POST','admin1','/api/auth/login','127.0.0.1','本地','{"u":"admin1"}','{"code":200}',0,NULL,12),
 ('注册',1,'AuthController.register','POST','student1','/api/auth/register','127.0.0.1','本地','{"u":"student1"}','{"code":200}',0,NULL,20),
 ('获取题目列表',1,'QuestionBankController.list','GET','teacher1','/api/questions','127.0.0.1','本地','{}','{"code":200}',0,NULL,8),
 ('创建试卷',1,'PaperController.create','POST','teacher1','/api/papers','127.0.0.1','本地','{}','{"code":200}',0,NULL,15),
 ('发布考试',1,'ExamController.create','POST','teacher1','/api/exams','127.0.0.1','本地','{}','{"code":200}',0,NULL,16);

INSERT IGNORE INTO biz_exam(name,paper_id,start_time,end_time,duration,status,creator_id)
 VALUES
 ('数据库设计长时考试-春季',(SELECT id FROM biz_paper WHERE name='数据库设计试卷1'),'2025-04-10 08:00:00','2025-04-15 23:00:00',720,1,(SELECT id FROM users WHERE username='teacher1')),
 ('计算机网络安全专项测试-春季',(SELECT id FROM biz_paper WHERE name='计算机网络安全试卷1'),'2025-05-05 09:00:00','2025-05-05 21:00:00',480,1,(SELECT id FROM users WHERE username='teacher2')),
 ('分布式系统原理加长考试-秋季',(SELECT id FROM biz_paper WHERE name='分布式系统原理试卷1'),'2025-09-20 08:00:00','2025-09-27 23:00:00',1440,0,(SELECT id FROM users WHERE username='teacher3')),
 ('人工智能基础周测-秋季',(SELECT id FROM biz_paper WHERE name='人工智能基础试卷1'),'2025-10-01 08:00:00','2025-10-01 20:00:00',720,1,(SELECT id FROM users WHERE username='teacher4')),
 ('数据库设计假期作业考试',(SELECT id FROM biz_paper WHERE name='数据库设计试卷1'),'2026-01-02 08:00:00','2026-01-08 23:00:00',1440,0,(SELECT id FROM users WHERE username='teacher1')),
 ('计算机网络安全强化测验',(SELECT id FROM biz_paper WHERE name='计算机网络安全试卷1'),'2025-07-01 08:00:00','2025-07-01 22:00:00',540,1,(SELECT id FROM users WHERE username='teacher2')),
 ('分布式系统原理月度测验',(SELECT id FROM biz_paper WHERE name='分布式系统原理试卷1'),'2025-03-20 09:00:00','2025-03-20 18:00:00',540,1,(SELECT id FROM users WHERE username='teacher3')),
 ('人工智能基础期末加时',(SELECT id FROM biz_paper WHERE name='人工智能基础试卷1'),'2025-12-25 08:00:00','2025-12-25 20:00:00',720,1,(SELECT id FROM users WHERE username='teacher4')),
 ('数据库设计随堂测验-春季',(SELECT id FROM biz_paper WHERE name='数据库设计试卷1'),'2025-04-22 10:00:00','2025-04-22 18:00:00',480,1,(SELECT id FROM users WHERE username='teacher1')),
 ('计算机网络安全大作业提交-秋季',(SELECT id FROM biz_paper WHERE name='计算机网络安全试卷1'),'2025-11-05 00:00:00','2025-11-10 23:59:00',1440,0,(SELECT id FROM users WHERE username='teacher2')),
 ('分布式系统原理专项训练-春季',(SELECT id FROM biz_paper WHERE name='分布式系统原理试卷1'),'2025-03-28 08:00:00','2025-03-28 20:00:00',600,1,(SELECT id FROM users WHERE username='teacher3')),
 ('人工智能基础实验考试-春季',(SELECT id FROM biz_paper WHERE name='人工智能基础试卷1'),'2025-05-15 09:00:00','2025-05-15 21:00:00',600,1,(SELECT id FROM users WHERE username='teacher4'));

INSERT IGNORE INTO biz_exam_student (exam_id, user_id)
 SELECT e.id, u.id FROM biz_exam e JOIN users u ON u.username='test'
 WHERE e.name IN ('数据库设计长时考试-春季','计算机网络安全专项测试-春季','分布式系统原理加长考试-秋季','人工智能基础周测-秋季','数据库设计假期作业考试','计算机网络安全强化测验','分布式系统原理月度测验','人工智能基础期末加时','数据库设计随堂测验-春季','计算机网络安全大作业提交-秋季','分布式系统原理专项训练-春季','人工智能基础实验考试-春季');
INSERT IGNORE INTO biz_exam_student (exam_id, user_id)
 SELECT e.id, u.id FROM biz_exam e JOIN users u ON u.username='student1'
 WHERE e.name IN ('数据库设计长时考试-春季','计算机网络安全专项测试-春季','分布式系统原理加长考试-秋季','人工智能基础周测-秋季','数据库设计假期作业考试','计算机网络安全强化测验','分布式系统原理月度测验','人工智能基础期末加时','数据库设计随堂测验-春季','计算机网络安全大作业提交-秋季','分布式系统原理专项训练-春季','人工智能基础实验考试-春季');
INSERT IGNORE INTO biz_exam_student (exam_id, user_id)
 SELECT e.id, u.id FROM biz_exam e JOIN users u ON u.username='student2'
 WHERE e.name IN ('数据库设计长时考试-春季','计算机网络安全专项测试-春季','分布式系统原理加长考试-秋季','人工智能基础周测-秋季','数据库设计假期作业考试','计算机网络安全强化测验','分布式系统原理月度测验','人工智能基础期末加时','数据库设计随堂测验-春季','计算机网络安全大作业提交-秋季','分布式系统原理专项训练-春季','人工智能基础实验考试-春季');
INSERT IGNORE INTO biz_exam_student (exam_id, user_id)
 SELECT e.id, u.id FROM biz_exam e JOIN users u ON u.username='student3'
 WHERE e.name IN ('数据库设计长时考试-春季','计算机网络安全专项测试-春季','分布式系统原理加长考试-秋季','人工智能基础周测-秋季','数据库设计假期作业考试','计算机网络安全强化测验','分布式系统原理月度测验','人工智能基础期末加时','数据库设计随堂测验-春季','计算机网络安全大作业提交-秋季','分布式系统原理专项训练-春季','人工智能基础实验考试-春季');
INSERT IGNORE INTO biz_exam_student (exam_id, user_id)
 SELECT e.id, u.id FROM biz_exam e JOIN users u ON u.username='student4'
 WHERE e.name IN ('数据库设计长时考试-春季','计算机网络安全专项测试-春季','分布式系统原理加长考试-秋季','人工智能基础周测-秋季','数据库设计假期作业考试','计算机网络安全强化测验','分布式系统原理月度测验','人工智能基础期末加时','数据库设计随堂测验-春季','计算机网络安全大作业提交-秋季','分布式系统原理专项训练-春季','人工智能基础实验考试-春季');

INSERT IGNORE INTO biz_exam_record(exam_id,student_id,score,status,start_time,submit_time)
 SELECT e.id, u.id, 88, 2, '2025-05-05 10:00:00','2025-05-05 16:00:00'
 FROM biz_exam e JOIN users u ON u.username='student1'
 WHERE e.name='计算机网络安全专项测试-春季';
INSERT IGNORE INTO biz_exam_record(exam_id,student_id,score,status,start_time,submit_time)
 SELECT e.id, u.id, NULL, 1, '2025-03-20 09:05:00','2025-03-20 17:45:00'
 FROM biz_exam e JOIN users u ON u.username='student2'
 WHERE e.name='分布式系统原理月度测验';
INSERT IGNORE INTO biz_exam_record(exam_id,student_id,score,status,start_time,submit_time)
 SELECT e.id, u.id, NULL, 0, NOW(), NULL
 FROM biz_exam e JOIN users u ON u.username='student3'
 WHERE e.name='人工智能基础周测-秋季';
INSERT IGNORE INTO biz_exam_record(exam_id,student_id,score,status,start_time,submit_time)
 SELECT e.id, u.id, 95, 2, '2025-04-11 08:10:00','2025-04-11 18:00:00'
 FROM biz_exam e JOIN users u ON u.username='test'
 WHERE e.name='数据库设计长时考试-春季';
INSERT IGNORE INTO biz_exam_record(exam_id,student_id,score,status,start_time,submit_time)
 SELECT e.id, u.id, NULL, 1, '2025-07-01 09:05:00','2025-07-01 21:55:00'
 FROM biz_exam e JOIN users u ON u.username='student4'
 WHERE e.name='计算机网络安全强化测验';
