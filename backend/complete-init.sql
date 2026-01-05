-- ==========================================
-- 超星考试系统 - 完整数据库初始化脚本
-- 创建日期: 2024-12-25
-- 说明: 此脚本整合了所有表结构、初始数据和迁移脚本
-- ==========================================

SET NAMES utf8mb4;
DROP DATABASE IF EXISTS chaoxing;
CREATE DATABASE chaoxing CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE chaoxing;

-- ==========================================
-- 第一部分: 基础表结构 (from schema.sql)
-- ==========================================

-- 用户表
CREATE TABLE IF NOT EXISTS users (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  username VARCHAR(50) NOT NULL UNIQUE,
  email VARCHAR(100) NOT NULL UNIQUE,
  phone VARCHAR(20),
  qq_number VARCHAR(15),
  password_hash VARCHAR(100) NOT NULL,
  user_type VARCHAR(20) NOT NULL,
  real_name VARCHAR(50) NOT NULL,
  avatar VARCHAR(255),
  bio TEXT,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 系统模块表
CREATE TABLE IF NOT EXISTS system_modules (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(50) NOT NULL UNIQUE,
  code VARCHAR(50) NOT NULL UNIQUE,
  category VARCHAR(20) NOT NULL,
  version VARCHAR(20) NOT NULL,
  enabled BOOLEAN NOT NULL DEFAULT TRUE,
  show_in_menu BOOLEAN NOT NULL DEFAULT TRUE,
  route_path VARCHAR(100),
  allowed_roles VARCHAR(200),
  dependencies VARCHAR(200),
  description TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 组织架构表
CREATE TABLE IF NOT EXISTS sys_organization (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  parent_id BIGINT,
  name VARCHAR(100) NOT NULL,
  code VARCHAR(50) UNIQUE,
  type VARCHAR(20) NOT NULL,
  sort_order INT,
  path VARCHAR(500),
  status INT DEFAULT 1,
  leader VARCHAR(50),
  phone VARCHAR(20),
  description TEXT,
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
  update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 角色表
CREATE TABLE IF NOT EXISTS sys_role (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  role_name VARCHAR(50) NOT NULL,
  role_key VARCHAR(50) NOT NULL UNIQUE,
  data_scope VARCHAR(10),
  status INT,
  remark VARCHAR(200)
);

-- 用户角色关联表
CREATE TABLE IF NOT EXISTS sys_user_role (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT NOT NULL,
  role_id BIGINT NOT NULL,
  UNIQUE KEY uk_user_role (user_id, role_id)
);

-- 角色-菜单关联表
CREATE TABLE IF NOT EXISTS sys_role_menu (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  role_id BIGINT NOT NULL,
  menu_id BIGINT NOT NULL,
  UNIQUE KEY uk_role_menu (role_id, menu_id)
);

-- 权限菜单表
CREATE TABLE IF NOT EXISTS sys_menu (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  parent_id BIGINT NOT NULL DEFAULT 0,
  name VARCHAR(50) NOT NULL,
  type CHAR(1) NOT NULL,
  perms VARCHAR(100),
  path VARCHAR(200),
  component VARCHAR(200),
  icon VARCHAR(100),
  sort_order INT NOT NULL DEFAULT 1,
  visible TINYINT NOT NULL DEFAULT 1
);

-- 教师档案表
CREATE TABLE IF NOT EXISTS biz_teacher (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT NOT NULL UNIQUE,
  employee_no VARCHAR(20) NOT NULL UNIQUE,
  real_name VARCHAR(50) NOT NULL,
  gender TINYINT NOT NULL,
  dept_id BIGINT,
  title VARCHAR(50),
  research_direction VARCHAR(200),
  education VARCHAR(50),
  email VARCHAR(100),
  phone VARCHAR(20),
  enrollment_year INT
);

-- 学生档案表
CREATE TABLE IF NOT EXISTS biz_student (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT NOT NULL UNIQUE,
  student_no VARCHAR(20) NOT NULL UNIQUE,
  real_name VARCHAR(50) NOT NULL,
  gender TINYINT NOT NULL,
  class_id BIGINT,
  major_code VARCHAR(50),
  enrollment_year INT,
  politics_status VARCHAR(20)
);

-- 题型字典表
CREATE TABLE IF NOT EXISTS biz_question_type (
  type_id TINYINT PRIMARY KEY,
  type_name VARCHAR(32) NOT NULL,
  type_code VARCHAR(16) NOT NULL UNIQUE,
  answer_json JSON NOT NULL,
  config_json JSON NOT NULL,
  is_active TINYINT NOT NULL DEFAULT 1,
  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 题目表
CREATE TABLE IF NOT EXISTS biz_question (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  type_id TINYINT NOT NULL,
  content TEXT NOT NULL,
  options JSON,
  answer JSON NOT NULL,
  analysis TEXT,
  difficulty TINYINT NOT NULL DEFAULT 1,
  subject VARCHAR(50),
  knowledge_points VARCHAR(200),
  file_id VARCHAR(100),
  creator_id BIGINT,
  status TINYINT NOT NULL DEFAULT 0,
  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 题目审核表
CREATE TABLE IF NOT EXISTS biz_question_audit (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  question_id BIGINT,
  submitter_id BIGINT NOT NULL,
  submit_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  type_id TINYINT NOT NULL,
  content TEXT NOT NULL,
  answer TEXT NOT NULL,
  difficulty TINYINT,
  subject_id BIGINT,
  status TINYINT NOT NULL DEFAULT 0,
  audit_comment TEXT,
  auditor_id BIGINT,
  audit_time DATETIME
);

-- 试卷表
CREATE TABLE IF NOT EXISTS biz_paper (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  subject VARCHAR(50) NOT NULL,
  total_score INT NOT NULL DEFAULT 0,
  pass_score INT NOT NULL DEFAULT 60,
  question_count INT NOT NULL DEFAULT 0,
  status TINYINT NOT NULL DEFAULT 0,
  creator_id BIGINT NOT NULL,
  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 试卷-题目关联表
CREATE TABLE IF NOT EXISTS biz_paper_question (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  paper_id BIGINT NOT NULL,
  question_id BIGINT NOT NULL,
  score INT NOT NULL,
  sort_order INT NOT NULL DEFAULT 0
);

-- 考试表
CREATE TABLE IF NOT EXISTS biz_exam (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  paper_id BIGINT NOT NULL,
  creator_id BIGINT NOT NULL,
  start_time DATETIME NOT NULL,
  end_time DATETIME NOT NULL,
  duration INT NOT NULL,
  total_score DECIMAL(5,2) NOT NULL,
  pass_score DECIMAL(5,2),
  allow_review TINYINT NOT NULL DEFAULT 0,
  shuffle_questions TINYINT NOT NULL DEFAULT 0,
  shuffle_options TINYINT NOT NULL DEFAULT 0,
  anti_cheat TINYINT NOT NULL DEFAULT 0,
  status TINYINT NOT NULL DEFAULT 0,
  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 考试记录表
CREATE TABLE IF NOT EXISTS biz_exam_record (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  exam_id BIGINT NOT NULL,
  student_id BIGINT NOT NULL,
  score INT,
  status TINYINT NOT NULL DEFAULT 0,
  start_time DATETIME,
  submit_time DATETIME,
  remark TEXT,
  progress INT DEFAULT 0 COMMENT '答题进度',
  switch_count INT DEFAULT 0 COMMENT '切屏次数',
  last_active_time DATETIME COMMENT '最后活跃时间',
  ip_address VARCHAR(50) COMMENT 'IP地址'
);

-- 答题明细表
CREATE TABLE IF NOT EXISTS biz_exam_answer (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  record_id BIGINT NOT NULL,
  question_id BIGINT NOT NULL,
  student_answer JSON NOT NULL,
  file_id VARCHAR(64),
  score INT,
  is_correct TINYINT(1),
  comment VARCHAR(500),
  INDEX idx_record_question (record_id, question_id)
);

-- 操作日志表
CREATE TABLE IF NOT EXISTS sys_oper_log (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  title VARCHAR(100),
  business_type INT,
  method VARCHAR(200),
  request_method VARCHAR(10),
  operator_name VARCHAR(50),
  request_url VARCHAR(500),
  operator_ip VARCHAR(50),
  operator_location VARCHAR(100),
  request_param TEXT,
  response_result TEXT,
  status INT,
  error_msg TEXT,
  cost_time INT,
  oper_time DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 监考事件表
CREATE TABLE IF NOT EXISTS biz_exam_monitor_event (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  exam_id BIGINT NOT NULL,
  student_id BIGINT NOT NULL,
  event_type VARCHAR(50),
  event_data TEXT,
  severity VARCHAR(20),
  event_time DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================
-- 第二部分: 教师端扩展表 (from teacher migration)
-- ==========================================

-- 考试-学生关联表
CREATE TABLE IF NOT EXISTS biz_exam_student (
  id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
  exam_id BIGINT NOT NULL COMMENT '考试ID',
  user_id BIGINT NOT NULL COMMENT '用户ID（学生）',
  status VARCHAR(20) DEFAULT 'normal' COMMENT '状态：normal-正常, removed-已移除',
  add_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '添加时间',
  INDEX idx_exam (exam_id),
  INDEX idx_user (user_id),
  UNIQUE KEY uk_exam_user (exam_id, user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='考试学生关联表';

-- 班级表
CREATE TABLE IF NOT EXISTS biz_class (
  id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
  class_name VARCHAR(100) NOT NULL COMMENT '班级名称',
  class_code VARCHAR(50) COMMENT '班级代码',
  grade VARCHAR(10) COMMENT '年级',
  major VARCHAR(100) COMMENT '专业',
  advisor_id BIGINT COMMENT '辅导员ID',
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  INDEX idx_code (class_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='班级表';

-- 学生-班级关联表
CREATE TABLE IF NOT EXISTS biz_class_student (
  id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
  class_id BIGINT NOT NULL COMMENT '班级ID',
  user_id BIGINT NOT NULL COMMENT '用户ID（学生）',
  join_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '加入时间',
  INDEX idx_class (class_id),
  INDEX idx_user (user_id),
  UNIQUE KEY uk_class_user (class_id, user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='班级学生关联表';

-- 监考警告记录表
CREATE TABLE IF NOT EXISTS biz_monitor_warning (
  id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
  exam_id BIGINT NOT NULL COMMENT '考试ID',
  student_id BIGINT NOT NULL COMMENT '学生ID',
  message TEXT COMMENT '警告内容',
  type VARCHAR(50) COMMENT '警告类型',
  teacher_id BIGINT COMMENT '发送警告的教师ID',
  send_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '发送时间',
  INDEX idx_exam_student (exam_id, student_id),
  INDEX idx_exam_time (exam_id, send_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='监考警告记录表';

-- 成绩调整记录表
CREATE TABLE IF NOT EXISTS biz_score_adjustment (
  id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
  score_id BIGINT NOT NULL COMMENT '成绩记录ID',
  original_score DECIMAL(5,2) COMMENT '原始分数',
  new_score DECIMAL(5,2) COMMENT '调整后分数',
  reason TEXT COMMENT '调整原因',
  adjuster_id BIGINT COMMENT '调整人ID',
  adjust_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '调整时间',
  INDEX idx_score (score_id),
  INDEX idx_time (adjust_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='成绩调整记录表';

-- 科目表
CREATE TABLE IF NOT EXISTS biz_subject (
  id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
  name VARCHAR(100) NOT NULL COMMENT '科目名称',
  code VARCHAR(50) UNIQUE COMMENT '科目代码',
  description TEXT COMMENT '科目描述',
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  INDEX idx_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='科目表';

-- ==========================================
-- 第三部分: 学生端错题本表 (from error book migration)
-- ==========================================

-- 错题本表
CREATE TABLE IF NOT EXISTS biz_student_error_book (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  student_id BIGINT NOT NULL COMMENT '学生ID',
  question_id BIGINT NOT NULL COMMENT '题目ID',
  exam_id BIGINT NULL COMMENT '关联考试ID',
  wrong_answer TEXT NULL COMMENT '错误答案',
  wrong_count INT NOT NULL DEFAULT 1 COMMENT '错误次数',
  mastered TINYINT NOT NULL DEFAULT 0 COMMENT '是否已掌握',
  last_wrong_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '最近做错时间',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  UNIQUE KEY uniq_student_question (student_id, question_id),
  KEY idx_student_id (student_id),
  KEY idx_question_id (question_id),
  KEY idx_exam_id (exam_id),
  KEY idx_mastered (mastered),
  KEY idx_student_mastered (student_id, mastered),
  KEY idx_last_wrong_time (last_wrong_time DESC)
) COMMENT='学生错题本表';

-- 错题笔记表
CREATE TABLE IF NOT EXISTS biz_error_book_note (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  error_book_id BIGINT NOT NULL COMMENT '错题本记录ID',
  note_content TEXT NOT NULL COMMENT '笔记内容',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  KEY idx_error_book_id (error_book_id)
) COMMENT='错题笔记表';

-- ==========================================
-- 第四部分: 学生个性化题集表
-- ==========================================

-- 学生题集表
CREATE TABLE IF NOT EXISTS biz_student_collection (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  student_id BIGINT NOT NULL,
  name VARCHAR(100) NOT NULL,
  is_default TINYINT(1) NOT NULL DEFAULT 0,
  question_count INT NOT NULL DEFAULT 0,
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
  update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_student (student_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='学生题集表';

-- 题集-题目关联表
CREATE TABLE IF NOT EXISTS biz_collection_question (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  collection_id BIGINT NOT NULL,
  question_id BIGINT NOT NULL,
  add_time DATETIME DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_collection_question (collection_id, question_id),
  INDEX idx_collection (collection_id),
  INDEX idx_question (question_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='题集题目关联表';

-- ==========================================
-- 第四部分: 扩展考试记录表字段
-- ==========================================

-- 注意: 这些字段已在初始表结构中定义，此部分仅作为说明保留

-- ==========================================
-- 第五部分: 初始数据
-- ==========================================

-- 插入题型数据
INSERT IGNORE INTO biz_question_type(type_id,type_name,type_code,answer_json,config_json,is_active,create_time,update_time) VALUES
 (1,'单选题','SINGLE',CAST('[\"B\"]' AS JSON),CAST('{\"leak_score\":0.0,\"max_option\":5,\"is_objective\":true,\"requires_file_id\":false}' AS JSON),1,NOW(),NOW()),
 (2,'多选题','MULTI',CAST('[\"A\",\"C\"]' AS JSON),CAST('{\"leak_score\":0.5,\"max_option\":6,\"is_objective\":true,\"requires_file_id\":false}' AS JSON),1,NOW(),NOW()),
 (3,'判断题','TRUE_FALSE',CAST('true' AS JSON),CAST('{\"is_objective\":true,\"requires_file_id\":false}' AS JSON),1,NOW(),NOW()),
 (4,'填空题','FILL',CAST('[\"空1\",\"空2\"]' AS JSON),CAST('{\"is_objective\":false,\"requires_file_id\":false}' AS JSON),1,NOW(),NOW()),
 (5,'简答题','SHORT',CAST('"文本"' AS JSON),CAST('{\"is_objective\":false,\"requires_file_id\":false}' AS JSON),1,NOW(),NOW());

-- 插入系统模块数据
INSERT IGNORE INTO system_modules(name,code,category,version,enabled,show_in_menu,route_path,allowed_roles,dependencies,description) VALUES
 ('题目审核','tch_audit','teacher','1.0',1,1,'/audit','TEACHER,ADMIN','', '审核老师或学生试题'),
 ('题库管理','tch_bank','teacher','1.0',1,1,'/bank','TEACHER,ADMIN','', '维护系统题库'),
 ('试卷管理','tch_paper','teacher','1.0',1,1,'/papers','TEACHER,ADMIN','', '组卷与维护'),
 ('考试管理','tch_exam','teacher','1.0',1,1,'/exams','TEACHER,ADMIN','', '发布考试与监考'),
 ('成绩管理','tch_score','teacher','1.0',1,1,'/scores','TEACHER,ADMIN','', '阅卷与统计');

-- 插入组织架构数据
INSERT IGNORE INTO sys_organization(parent_id,name,code,type,sort_order,path,status,leader,phone,description) VALUES
(NULL,'信息学院','ORG-INFO','college',1,'/信息学院',1,'张主任','0571-0000001','学院'),
(NULL,'计算机系','ORG-CS','department',1,'/信息学院/计算机系',1,'李老师','0571-0000002','系'),
(NULL,'软件工程系','ORG-SE','department',2,'/信息学院/软件工程系',1,'王老师','0571-0000003','系'),
(NULL,'机电学院','ORG-MECH','college',2,'/机电学院',1,'赵主任','0571-0000004','学院'),
(NULL,'自动化系','ORG-AUTO','department',1,'/机电学院/自动化系',1,'钱老师','0571-0000005','系');

-- 插入班级数据
SET @org_cs_id = (SELECT id FROM sys_organization WHERE code='ORG-CS');
SET @org_se_id = (SELECT id FROM sys_organization WHERE code='ORG-SE');
INSERT IGNORE INTO sys_organization(id,parent_id,name,code,type,sort_order,path,status,leader,phone,description) VALUES
 (100,@org_cs_id,'计科一班','CLS-CS-101','class',1,'/信息学院/计算机系/计科一班',1,'班主任甲','0571-1000001','班级'),
 (101,@org_cs_id,'计科二班','CLS-CS-102','class',2,'/信息学院/计算机系/计科二班',1,'班主任乙','0571-1000002','班级'),
 (102,@org_se_id,'软工一班','CLS-SE-101','class',1,'/信息学院/软件工程系/软工一班',1,'班主任丙','0571-1000003','班级');

INSERT IGNORE INTO users(username,email,phone,password_hash,user_type,real_name,avatar) VALUES
('admin1','admin1@example.com',NULL,'$2a$10$NmSOuZw1f36ATVUKqTV5f.wVI3DVxqyYJdMQIQsK4CAel6wYslBke','admin','管理员一',NULL),
('teacher1','teacher1@example.com',NULL,'$2a$10$NmSOuZw1f36ATVUKqTV5f.wVI3DVxqyYJdMQIQsK4CAel6wYslBke','teacher','教师一',NULL),
('teacher2','teacher2@example.com',NULL,'$2a$10$NmSOuZw1f36ATVUKqTV5f.wVI3DVxqyYJdMQIQsK4CAel6wYslBke','teacher','教师二',NULL),
('teacher3','teacher3@example.com',NULL,'$2a$10$NmSOuZw1f36ATVUKqTV5f.wVI3DVxqyYJdMQIQsK4CAel6wYslBke','teacher','教师三',NULL),
('student1','student1@example.com',NULL,'$2a$10$NmSOuZw1f36ATVUKqTV5f.wVI3DVxqyYJdMQIQsK4CAel6wYslBke','student','学生一',NULL),
('student2','student2@example.com',NULL,'$2a$10$NmSOuZw1f36ATVUKqTV5f.wVI3DVxqyYJdMQIQsK4CAel6wYslBke','student','学生二',NULL),
('student3','student3@example.com',NULL,'$2a$10$NmSOuZw1f36ATVUKqTV5f.wVI3DVxqyYJdMQIQsK4CAel6wYslBke','student','学生三',NULL),
('student4','student4@example.com',NULL,'$2a$10$NmSOuZw1f36ATVUKqTV5f.wVI3DVxqyYJdMQIQsK4CAel6wYslBke','student','学生四',NULL),
('test','test@example.com',NULL,'$2a$10$NmSOuZw1f36ATVUKqTV5f.wVI3DVxqyYJdMQIQsK4CAel6wYslBke','student','测试生',NULL);

INSERT IGNORE INTO biz_student(user_id,student_no,real_name,gender,class_id,major_code,enrollment_year,politics_status) VALUES
 ((SELECT id FROM users WHERE username='test'),'S2023000','测试生',1,(SELECT id FROM sys_organization WHERE code='CLS-CS-101'),'CS',2023,'群众'),
 ((SELECT id FROM users WHERE username='student1'),'S2023001','张三',1,(SELECT id FROM sys_organization WHERE code='CLS-CS-102'),'CS',2023,'群众'),
 ((SELECT id FROM users WHERE username='student2'),'S2023002','李四',1,(SELECT id FROM sys_organization WHERE code='CLS-CS-102'),'CS',2023,'团员'),
 ((SELECT id FROM users WHERE username='student3'),'S2023003','王五',1,(SELECT id FROM sys_organization WHERE code='CLS-SE-101'),'SE',2022,'群众'),
 ((SELECT id FROM users WHERE username='student4'),'S2023004','赵六',0,(SELECT id FROM sys_organization WHERE code='CLS-SE-101'),'SE',2022,'团员');
-- 插入角色数据
INSERT IGNORE INTO sys_role(role_name,role_key,data_scope,status,remark) VALUES
 ('学生','STUDENT','5',1,'学生角色'),
 ('教师','TEACHER','2',1,'教师角色'),
 ('管理员','ADMIN','1',1,'管理员角色'),
 ('系统管理员','SYSADMIN','0',1,'超级管理员'),
 ('审核员','AUDITOR','3',1,'题目审核员');

-- 插入科目数据
INSERT IGNORE INTO biz_subject (name, code, description) VALUES
('Java程序设计', 'java', 'Java编程语言基础与应用'),
('数据结构', 'ds', '数据结构与算法'),
('计算机网络', 'network', '计算机网络原理'),
('操作系统', 'os', '操作系统原理与设计'),
('数据库原理', 'database', '数据库系统原理'),
('软件工程', 'se', '软件工程方法与实践'),
('计算机组成原理', 'computer_org', '计算机硬件系统'),
('编译原理', 'compiler', '编译原理与技术');

-- 插入班级数据
INSERT IGNORE INTO biz_class (class_name, class_code, grade, major) VALUES
('计算机科学与技术1班', 'cs1', '2021', '计算机科学与技术'),
('计算机科学与技术2班', 'cs2', '2021', '计算机科学与技术'),
('软件工程1班', 'se1', '2021', '软件工程'),
('软件工程2班', 'se2', '2021', '软件工程'),
('网络工程1班', 'ne1', '2021', '网络工程');

-- 插入示例题目数据
INSERT IGNORE INTO biz_question (type_id, content, options, answer, analysis, difficulty, subject, knowledge_points, file_id, creator_id, status)
VALUES
(1, 'Java中Runnable接口定义的方法是？', '[{"key":"A","value":"start"},{"key":"B","value":"run"},{"key":"C","value":"stop"},{"key":"D","value":"sleep"}]', JSON_QUOTE('B'), 'Runnable只有一个run方法', 2, 'Java', '线程基础', NULL, 1, 1),
(1, '下列关于Java集合的说法，正确的是？', '[{"key":"A","value":"List是有序可重复的集合"},{"key":"B","value":"Set允许重复元素"},{"key":"C","value":"Map实现了Collection接口"},{"key":"D","value":"Queue不支持FIFO"}]', JSON_QUOTE('A'), 'Set不允许重复，Map不实现Collection', 2, 'Java', '集合框架', NULL, 1, 1),
(2, '以下哪些属于线程安全的集合？', '[{"key":"A","value":"Vector"},{"key":"B","value":"ArrayList"},{"key":"C","value":"ConcurrentHashMap"},{"key":"D","value":"HashMap"}]', JSON_ARRAY('A','C'), 'Vector与ConcurrentHashMap是线程安全的', 3, 'Java', '并发集合', NULL, 1, 1),
(3, 'TCP是面向连接的协议', NULL, JSON_QUOTE('T'), '正确', 1, '计算机网络', 'TCP基础', NULL, 1, 1),
(3, 'HTTP属于应用层协议', NULL, JSON_QUOTE('T'), 'HTTP基于TCP的应用层协议', 1, '计算机网络', 'OSI模型', NULL, 1, 1),
(4, '二分查找的时间复杂度是O(____)', NULL, JSON_ARRAY('log n'), '二分查找每次折半', 2, '数据结构', '查找算法', NULL, 1, 1),
(4, '快速排序的平均时间复杂度是O(____)', NULL, JSON_ARRAY('n log n'), '平均复杂度O(n log n)', 3, '数据结构', '排序算法', NULL, 1, 1),
 (1, 'Java中int占用几个字节？', '[{"key":"A","value":"2"},{"key":"B","value":"4"}]', JSON_QUOTE('B'), 'Java基本类型int占4字节', 1, 'Java程序设计', '数据类型', NULL, 1, 1),
 (3, 'List是线程安全吗？', NULL, JSON_QUOTE('F'), 'ArrayList等常用实现非线程安全', 2, 'Java程序设计', '集合框架', NULL, 1, 1),
 (5, '简述MVC模式', NULL, JSON_QUOTE('Model-View-Controller'), '略', 3, '软件工程', '架构模式', NULL, 1, 1),
 (2, '以下属于Java集合框架的接口有？', '[{"key":"A","value":"List"},{"key":"B","value":"Map"},{"key":"C","value":"Thread"},{"key":"D","value":"Set"}]', JSON_ARRAY('A','B','D'), 'Thread是类不是集合接口', 2, 'Java程序设计', '集合框架', NULL, 1, 1),
 (1, '栈的特点是？', '[{"key":"A","value":"先进先出"},{"key":"B","value":"后进先出"}]', JSON_QUOTE('B'), '栈是后进先出', 2, '数据结构', '栈与队列', NULL, 1, 1),
 (3, '队列是先进先出的数据结构', NULL, JSON_QUOTE('T'), '队列先进先出', 1, '数据结构', '栈与队列', NULL, 1, 1),
 (5, '简述哈希冲突的常见解决方法', NULL, JSON_QUOTE('开放地址、链地址法等'), '略', 3, '数据结构', '哈希', NULL, 1, 1),
 (4, '平衡二叉树的定义是____', NULL, JSON_ARRAY('任意节点左右子树高度差不超过1'), '略', 3, '数据结构', '树', NULL, 1, 1),
 (1, '堆排序的时间复杂度是？', '[{"key":"A","value":"O(n)"},{"key":"B","value":"O(n log n)"}]', JSON_QUOTE('B'), '堆排序复杂度O(n log n)', 2, '数据结构', '排序', NULL, 1, 1),
 (2, '下列属于图的遍历算法有？', '[{"key":"A","value":"DFS"},{"key":"B","value":"BFS"},{"key":"C","value":"Dijkstra"},{"key":"D","value":"Bellman-Ford"}]', JSON_ARRAY('A','B'), 'DFS与BFS是遍历算法', 2, '数据结构', '图', NULL, 1, 1),
 (3, '红黑树满足所有节点红黑性质', NULL, JSON_QUOTE('T'), '红黑树性质', 3, '数据结构', '树', NULL, 1, 1);
-- 以下三行存在部分 MySQL 在不同系统编码下解析异常的问题，移除以避免初始化失败
-- (5, '简述产生死锁的四个必要条件', NULL, JSON_QUOTE('互斥,占有且等待,不可抢占,循环等待'), '典型死锁条件', 4, '操作系统', '进程与死锁', NULL, 1, 1),
-- (5, '简述数据库事务的ACID特性', NULL, JSON_QUOTE('原子性,一致性,隔离性,持久性'), '事务四大特性', 3, '数据库原理', '事务管理', NULL, 1, 1),
-- (1, 'SQL中用于分组统计的关键字是？', '[{\"key\":\"A\",\"value\":\"WHERE\"},{\"key\":\"B\",\"value\":\"GROUP BY\"},{\"key\":\"C\",\"value\":\"ORDER BY\"},{\"key\":\"D\",\"value\":\"JOIN\"}]', JSON_QUOTE('B'), 'GROUP BY用于分组', 1, '数据库原理', 'SQL基础', NULL, 1, 1);

-- 追加练题题库示例数据（覆盖多学科与题型）
INSERT IGNORE INTO biz_question (type_id, content, options, answer, analysis, difficulty, subject, knowledge_points, file_id, creator_id, status)
VALUES
(1, '以下哪个不是SQL聚合函数？', '[{\"key\":\"A\",\"value\":\"COUNT\"},{\"key\":\"B\",\"value\":\"SUM\"},{\"key\":\"C\",\"value\":\"AVG\"},{\"key\":\"D\",\"value\":\"SELECT\"}]', JSON_QUOTE('D'), 'SELECT是查询关键字，不是聚合函数', 1, '数据库原理', 'SQL函数', NULL, 1, 1),
(2, '以下哪些属于常见进程调度算法？', '[{\"key\":\"A\",\"value\":\"先来先服务(FCFS)\"},{\"key\":\"B\",\"value\":\"最短作业优先(SJF)\"},{\"key\":\"C\",\"value\":\"时间片轮转(RR)\"},{\"key\":\"D\",\"value\":\"最近最久未使用(LRU)\"}]', JSON_ARRAY('A','B','C'), 'LRU是页面置换算法，非调度算法', 2, '操作系统', '进程调度', NULL, 1, 1),
(3, 'DNS查询通常使用UDP协议', NULL, JSON_QUOTE('T'), '大多数情况下DNS使用UDP，区域传送使用TCP', 1, '计算机网络', '应用层协议', NULL, 1, 1),
(4, '哈希表的平均查找时间复杂度为O(____)', NULL, JSON_ARRAY('1'), '理想情况下平均为常数时间', 2, '数据结构', '哈希表', NULL, 1, 1),
(5, '简述进程与线程的区别', NULL, JSON_QUOTE('进程是资源分配单位，线程是CPU调度单位；进程间相互独立，线程共享进程资源'), '核心区别在于资源与调度', 3, '操作系统', '进程与线程', NULL, 1, 1),
(1, 'Java中所有异常的顶层父类是？', '[{\"key\":\"A\",\"value\":\"Exception\"},{\"key\":\"B\",\"value\":\"Error\"},{\"key\":\"C\",\"value\":\"Throwable\"},{\"key\":\"D\",\"value\":\"RuntimeException\"}]', JSON_QUOTE('C'), 'Throwable是异常的根类', 2, 'Java', '异常体系', NULL, 1, 1),
(2, 'HTTP/2的特性包含哪些？', '[{\"key\":\"A\",\"value\":\"多路复用\"},{\"key\":\"B\",\"value\":\"服务端推送\"},{\"key\":\"C\",\"value\":\"二进制分帧\"},{\"key\":\"D\",\"value\":\"基于UDP传输\"}]', JSON_ARRAY('A','B','C'), 'HTTP/2仍基于TCP，不是UDP', 2, '计算机网络', 'HTTP/2', NULL, 1, 1),
(3, '进程和线程是同一概念', NULL, JSON_QUOTE('F'), '两者不是同一概念', 1, '操作系统', '基础概念', NULL, 1, 1),
(4, 'SQL中用于计数的函数是(____)', NULL, JSON_ARRAY('COUNT'), 'COUNT用于计数', 1, '数据库原理', 'SQL函数', NULL, 1, 1),
(5, '简述索引的作用与影响', NULL, JSON_QUOTE('索引可提升查询性能，但会增加写入成本与存储开销'), '概念性说明', 2, '数据库原理', '索引', NULL, 1, 1);

INSERT IGNORE INTO biz_question(type_id,content,options,answer,analysis,difficulty,subject,knowledge_points,file_id,creator_id,status,create_time)
VALUES (
  1,
  '关于OSI模型中网络层的主要功能是？',
  '[{"key":"A","value":"路由与转发"},{"key":"B","value":"数据加密"},{"key":"C","value":"显示控制"},{"key":"D","value":"数据表示"}]',
  JSON_QUOTE('A'),
  '网络层负责路由选择与数据包转发',
  2,
  '计算机网络',
  'OSI模型',
  NULL,
  (SELECT id FROM users WHERE username='teacher2'),
  1,
  NOW()
);

-- 插入试卷数据（用于后续考试关联）
INSERT IGNORE INTO biz_paper (name, subject, total_score, pass_score, status, creator_id)
VALUES
('数据库设计综合试卷A','数据库原理',100,60,1,(SELECT id FROM users WHERE username='teacher1')),
('计算机网络安全阶段性试卷B','计算机网络',100,60,1,(SELECT id FROM users WHERE username='teacher2')),
('分布式系统原理期末试卷C','分布式系统原理',100,60,1,(SELECT id FROM users WHERE username='teacher3')),
('人工智能基础结课试卷D','人工智能基础',100,60,1,(SELECT id FROM users WHERE username='teacher4'));

-- 试卷题目关联（确保每张试卷涵盖不同题型）
INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name='数据库设计综合试卷A'), q.id, 20, 1
 FROM (SELECT id FROM biz_question WHERE type_id=1 AND subject='数据库原理' ORDER BY id LIMIT 1) q;
INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name='数据库设计综合试卷A'), q.id, 20, 2
 FROM (SELECT id FROM biz_question WHERE type_id=2 ORDER BY id LIMIT 1) q;
INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name='数据库设计综合试卷A'), q.id, 20, 3
 FROM (SELECT id FROM biz_question WHERE type_id=3 ORDER BY id LIMIT 1) q;
INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name='数据库设计综合试卷A'), q.id, 20, 4
 FROM (SELECT id FROM biz_question WHERE type_id=4 ORDER BY id LIMIT 1) q;
INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name='数据库设计综合试卷A'), q.id, 20, 5
 FROM (SELECT id FROM biz_question WHERE type_id=5 AND subject='数据库原理' ORDER BY id LIMIT 1) q;

INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name='计算机网络安全阶段性试卷B'), q.id, 20, 1
 FROM (SELECT id FROM biz_question WHERE type_id=1 AND subject='计算机网络' ORDER BY id LIMIT 1) q;
INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name='计算机网络安全阶段性试卷B'), q.id, 20, 2
 FROM (SELECT id FROM biz_question WHERE type_id=2 ORDER BY id LIMIT 1) q;
INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name='计算机网络安全阶段性试卷B'), q.id, 20, 3
 FROM (SELECT id FROM biz_question WHERE type_id=3 AND subject='计算机网络' ORDER BY id LIMIT 1) q;
INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name='计算机网络安全阶段性试卷B'), q.id, 20, 4
 FROM (SELECT id FROM biz_question WHERE type_id=4 ORDER BY id LIMIT 1) q;
INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name='计算机网络安全阶段性试卷B'), q.id, 20, 5
 FROM (SELECT id FROM biz_question WHERE type_id=5 ORDER BY id LIMIT 1) q;

INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name='分布式系统原理期末试卷C'), q.id, 20, 1
 FROM (SELECT id FROM biz_question WHERE type_id=1 ORDER BY id LIMIT 1) q;
INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name='分布式系统原理期末试卷C'), q.id, 20, 2
 FROM (SELECT id FROM biz_question WHERE type_id=2 ORDER BY id LIMIT 1) q;
INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name='分布式系统原理期末试卷C'), q.id, 20, 3
 FROM (SELECT id FROM biz_question WHERE type_id=3 ORDER BY id LIMIT 1) q;
INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name='分布式系统原理期末试卷C'), q.id, 20, 4
 FROM (SELECT id FROM biz_question WHERE type_id=4 ORDER BY id LIMIT 1) q;
INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name='分布式系统原理期末试卷C'), q.id, 20, 5
 FROM (SELECT id FROM biz_question WHERE type_id=5 ORDER BY id LIMIT 1) q;

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
-- 插入考试数据（2进行中，1未开始，1已结束）
INSERT IGNORE INTO biz_exam (name, paper_id, start_time, end_time, duration, status, creator_id)
VALUES
('数据库设计课程期末统一考试（2025冬季）',
 (SELECT id FROM biz_paper WHERE name='数据库设计综合试卷A'),
 '2025-12-26 09:00:00','2025-12-26 23:00:00',840,1,(SELECT id FROM users WHERE username='teacher1')),
('计算机网络安全课程阶段性测评（第十三周）',
 (SELECT id FROM biz_paper WHERE name='计算机网络安全阶段性试卷B'),
 '2025-12-24 08:00:00','2025-12-28 20:00:00',5760,1,(SELECT id FROM users WHERE username='teacher2')),
('人工智能基础课程期末统一考试（2026春季）',
 (SELECT id FROM biz_paper WHERE name='人工智能基础结课试卷D'),
 '2026-01-10 09:00:00','2026-01-10 11:00:00',120,0,(SELECT id FROM users WHERE username='teacher4')),
('分布式系统原理课程期末统一考试（2025秋季）',
 (SELECT id FROM biz_paper WHERE name='分布式系统原理期末试卷C'),
 '2025-10-01 08:00:00','2025-10-01 20:00:00',720,2,(SELECT id FROM users WHERE username='teacher3'));

-- 分配学生到上述考试
INSERT IGNORE INTO biz_exam_student (exam_id, user_id)
SELECT e.id, (SELECT id FROM users WHERE username='student1')
FROM biz_exam e
WHERE e.name IN (
'数据库设计课程期末统一考试（2025冬季）',
'计算机网络安全课程阶段性测评（第十三周）',
'人工智能基础课程期末统一考试（2026春季）',
'分布式系统原理课程期末统一考试（2025秋季）'
);

-- 新增试卷（用于进行中考试）
INSERT IGNORE INTO biz_paper (name, subject, total_score, pass_score, status, creator_id)
VALUES
('数据结构阶段性测验E','数据结构',100,60,1,(SELECT id FROM users WHERE username='teacher1')),
('Java语言程序设计阶段性测验F','Java程序设计',100,60,1,(SELECT id FROM users WHERE username='teacher2'));

-- 试卷题目关联（E）
INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name='数据结构阶段性测验E'), q.id, 20, 1
 FROM (SELECT id FROM biz_question WHERE type_id=1 ORDER BY id LIMIT 1) q;
INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name='数据结构阶段性测验E'), q.id, 20, 2
 FROM (SELECT id FROM biz_question WHERE type_id=2 ORDER BY id LIMIT 1) q;
INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name='数据结构阶段性测验E'), q.id, 20, 3
 FROM (SELECT id FROM biz_question WHERE type_id=3 ORDER BY id LIMIT 1) q;
INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name='数据结构阶段性测验E'), q.id, 20, 4
 FROM (SELECT id FROM biz_question WHERE type_id=4 ORDER BY id LIMIT 1) q;
INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name='数据结构阶段性测验E'), q.id, 20, 5
 FROM (SELECT id FROM biz_question WHERE type_id=5 ORDER BY id LIMIT 1) q;

-- 试卷题目关联（F）
INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name='Java语言程序设计阶段性测验F'), q.id, 20, 1
 FROM (SELECT id FROM biz_question WHERE type_id=1 AND subject='Java' ORDER BY id LIMIT 1) q;
INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name='Java语言程序设计阶段性测验F'), q.id, 20, 2
 FROM (SELECT id FROM biz_question WHERE type_id=2 AND subject='Java' ORDER BY id LIMIT 1) q;
INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name='Java语言程序设计阶段性测验F'), q.id, 20, 3
 FROM (SELECT id FROM biz_question WHERE type_id=3 ORDER BY id LIMIT 1) q;
INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name='Java语言程序设计阶段性测验F'), q.id, 20, 4
 FROM (SELECT id FROM biz_question WHERE type_id=4 ORDER BY id LIMIT 1) q;
INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name='Java语言程序设计阶段性测验F'), q.id, 20, 5
 FROM (SELECT id FROM biz_question WHERE type_id=5 ORDER BY id LIMIT 1) q;

-- 新增进行中考试（确保当前时间在开始与结束之间）
INSERT IGNORE INTO biz_exam (name, paper_id, start_time, end_time, duration, status, creator_id)
VALUES
('数据结构阶段性测验（第十四周）',
 (SELECT id FROM biz_paper WHERE name='数据结构阶段性测验E'),
 '2025-12-25 08:00:00','2025-12-29 20:00:00',90,1,(SELECT id FROM users WHERE username='teacher1')),
('Java语言程序设计阶段性测验（第十二周）',
 (SELECT id FROM biz_paper WHERE name='Java语言程序设计阶段性测验F'),
 '2025-12-25 08:00:00','2025-12-31 20:00:00',120,1,(SELECT id FROM users WHERE username='teacher2'));

-- 分配学生到新考试
INSERT IGNORE INTO biz_exam_student (exam_id, user_id)
SELECT e.id, (SELECT id FROM users WHERE username='student1')
FROM biz_exam e
WHERE e.name IN (
'数据结构阶段性测验（第十四周）',
'Java语言程序设计阶段性测验（第十二周）'
);
INSERT IGNORE INTO biz_exam_student (exam_id, user_id)
SELECT e.id, (SELECT id FROM users WHERE username='student2')
FROM biz_exam e
WHERE e.name IN (
'数据结构阶段性测验（第十四周）',
'Java语言程序设计阶段性测验（第十二周）'
);

-- 个性化题集初始数据（基于前端占位）
SET @student1_id = (SELECT id FROM users WHERE username='student1');
INSERT IGNORE INTO biz_student_collection (student_id, name, is_default, question_count)
VALUES
(@student1_id, '我的错题集', 1, 12),
(@student1_id, 'Java重点复习', 0, 5),
(@student1_id, '数据结构收藏', 0, 8);

SET @col_default = (SELECT id FROM biz_student_collection WHERE student_id=@student1_id AND name='我的错题集');
SET @col_java = (SELECT id FROM biz_student_collection WHERE student_id=@student1_id AND name='Java重点复习');
SET @col_ds = (SELECT id FROM biz_student_collection WHERE student_id=@student1_id AND name='数据结构收藏');

INSERT IGNORE INTO biz_collection_question (collection_id, question_id)
SELECT @col_default, q.id FROM (SELECT id FROM biz_question ORDER BY id LIMIT 12) q;

INSERT IGNORE INTO biz_collection_question (collection_id, question_id)
SELECT @col_java, q.id FROM (SELECT id FROM biz_question WHERE subject LIKE 'Java%' ORDER BY id LIMIT 5) q;

INSERT IGNORE INTO biz_collection_question (collection_id, question_id)
SELECT @col_ds, q.id FROM (SELECT id FROM biz_question WHERE subject='数据结构' ORDER BY id LIMIT 8) q;

-- 完成
SELECT '数据库初始化完成！' AS message;
SELECT '默认密码: 123456' AS info;
