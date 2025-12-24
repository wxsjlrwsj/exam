-- 教师端功能数据库迁移脚本
-- 创建所需的新表和扩展现有表字段

-- 1. 创建考试-学生关联表
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

-- 2. 创建班级表
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

-- 3. 创建学生-班级关联表
CREATE TABLE IF NOT EXISTS biz_class_student (
  id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
  class_id BIGINT NOT NULL COMMENT '班级ID',
  user_id BIGINT NOT NULL COMMENT '用户ID（学生）',
  join_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '加入时间',
  INDEX idx_class (class_id),
  INDEX idx_user (user_id),
  UNIQUE KEY uk_class_user (class_id, user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='班级学生关联表';

-- 4. 创建监考警告记录表
CREATE TABLE IF NOT EXISTS biz_monitor_warning (
  id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
  exam_id BIGINT NOT NULL COMMENT '考试ID',
  student_id BIGINT NOT NULL COMMENT '学生ID',
  message TEXT COMMENT '警告内容',
  type VARCHAR(50) COMMENT '警告类型：switch_screen-切屏, idle-长时间无操作',
  teacher_id BIGINT COMMENT '发送警告的教师ID',
  send_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '发送时间',
  INDEX idx_exam_student (exam_id, student_id),
  INDEX idx_exam_time (exam_id, send_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='监考警告记录表';

-- 5. 创建成绩调整记录表
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

-- 6. 创建科目表
CREATE TABLE IF NOT EXISTS biz_subject (
  id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
  name VARCHAR(100) NOT NULL COMMENT '科目名称',
  code VARCHAR(50) UNIQUE COMMENT '科目代码',
  description TEXT COMMENT '科目描述',
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  INDEX idx_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='科目表';

-- 7. 扩展考试记录表（添加监考相关字段）
-- 使用存储过程安全地添加字段（避免重复添加错误）

DELIMITER $$

-- 添加答题进度字段
DROP PROCEDURE IF EXISTS add_progress_column$$
CREATE PROCEDURE add_progress_column()
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = DATABASE() 
        AND table_name = 'biz_exam_record' 
        AND column_name = 'progress'
    ) THEN
        ALTER TABLE biz_exam_record ADD COLUMN progress INT DEFAULT 0 COMMENT '答题进度（百分比）';
    END IF;
END$$

-- 添加切屏次数字段
DROP PROCEDURE IF EXISTS add_switch_count_column$$
CREATE PROCEDURE add_switch_count_column()
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = DATABASE() 
        AND table_name = 'biz_exam_record' 
        AND column_name = 'switch_count'
    ) THEN
        ALTER TABLE biz_exam_record ADD COLUMN switch_count INT DEFAULT 0 COMMENT '切屏次数';
    END IF;
END$$

-- 添加最后活跃时间字段
DROP PROCEDURE IF EXISTS add_last_active_time_column$$
CREATE PROCEDURE add_last_active_time_column()
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = DATABASE() 
        AND table_name = 'biz_exam_record' 
        AND column_name = 'last_active_time'
    ) THEN
        ALTER TABLE biz_exam_record ADD COLUMN last_active_time DATETIME COMMENT '最后活跃时间';
    END IF;
END$$

-- 添加IP地址字段
DROP PROCEDURE IF EXISTS add_ip_address_column$$
CREATE PROCEDURE add_ip_address_column()
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = DATABASE() 
        AND table_name = 'biz_exam_record' 
        AND column_name = 'ip_address'
    ) THEN
        ALTER TABLE biz_exam_record ADD COLUMN ip_address VARCHAR(50) COMMENT 'IP地址';
    END IF;
END$$

DELIMITER ;

-- 执行存储过程
CALL add_progress_column();
CALL add_switch_count_column();
CALL add_last_active_time_column();
CALL add_ip_address_column();

-- 清理存储过程
DROP PROCEDURE IF EXISTS add_progress_column;
DROP PROCEDURE IF EXISTS add_switch_count_column;
DROP PROCEDURE IF EXISTS add_last_active_time_column;
DROP PROCEDURE IF EXISTS add_ip_address_column;

-- 8. 插入初始科目数据
INSERT INTO biz_subject (name, code, description) VALUES
('Java程序设计', 'java', 'Java编程语言基础与应用'),
('数据结构', 'ds', '数据结构与算法'),
('计算机网络', 'network', '计算机网络原理'),
('操作系统', 'os', '操作系统原理与设计'),
('数据库原理', 'database', '数据库系统原理'),
('软件工程', 'se', '软件工程方法与实践'),
('计算机组成原理', 'computer_org', '计算机硬件系统'),
('编译原理', 'compiler', '编译原理与技术')
ON DUPLICATE KEY UPDATE name=VALUES(name);

-- 9. 插入示例班级数据（可选）
INSERT INTO biz_class (class_name, class_code, grade, major) VALUES
('计算机科学与技术1班', 'cs1', '2021', '计算机科学与技术'),
('计算机科学与技术2班', 'cs2', '2021', '计算机科学与技术'),
('软件工程1班', 'se1', '2021', '软件工程'),
('软件工程2班', 'se2', '2021', '软件工程'),
('网络工程1班', 'ne1', '2021', '网络工程')
ON DUPLICATE KEY UPDATE class_name=VALUES(class_name);

-- 10. 为已有考试创建考生关联（可选）
-- 如果系统中已经有考试和学生数据，可以执行以下语句建立关联
-- INSERT INTO biz_exam_student (exam_id, user_id, status)
-- SELECT DISTINCT e.id, u.id, 'normal'
-- FROM biz_exam e
-- CROSS JOIN sys_user u
-- WHERE u.user_type = 'student'
-- ON DUPLICATE KEY UPDATE status='normal';

COMMIT;

-- 验证表创建
SELECT 'Tables created successfully!' AS message;
SELECT TABLE_NAME, TABLE_COMMENT 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = DATABASE() 
AND TABLE_NAME IN (
  'biz_exam_student',
  'biz_class', 
  'biz_class_student',
  'biz_monitor_warning',
  'biz_score_adjustment',
  'biz_subject'
);

