-- ============================================
-- 学生端功能数据库迁移脚本
-- 版本: v1.0
-- 日期: 2024-12-24
-- 说明: 为学生端功能添加必要的数据库表和字段
-- ============================================

-- 设置字符集
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================
-- 1. 学生题集表
-- ============================================
CREATE TABLE IF NOT EXISTS biz_student_collection (
  id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '题集ID',
  student_id BIGINT NOT NULL COMMENT '学生ID',
  name VARCHAR(100) NOT NULL COMMENT '题集名称',
  description VARCHAR(500) COMMENT '题集描述',
  is_default TINYINT(1) DEFAULT 0 COMMENT '是否默认题集(错题本)',
  question_count INT DEFAULT 0 COMMENT '题目数量',
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  INDEX idx_student (student_id),
  INDEX idx_create_time (create_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='学生题集表';

-- ============================================
-- 2. 题集题目关联表
-- ============================================
CREATE TABLE IF NOT EXISTS biz_collection_question (
  id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'ID',
  collection_id BIGINT NOT NULL COMMENT '题集ID',
  question_id BIGINT NOT NULL COMMENT '题目ID',
  add_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '添加时间',
  INDEX idx_collection (collection_id),
  INDEX idx_question (question_id),
  UNIQUE KEY uk_collection_question (collection_id, question_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='题集题目关联表';

-- ============================================
-- 3. 学生错题记录表
-- ============================================
CREATE TABLE IF NOT EXISTS biz_student_error (
  id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '错题ID',
  student_id BIGINT NOT NULL COMMENT '学生ID',
  question_id BIGINT NOT NULL COMMENT '题目ID',
  exam_id BIGINT COMMENT '考试ID(如果来自考试)',
  error_count INT DEFAULT 1 COMMENT '错误次数',
  first_error_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '首次错误时间',
  last_error_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后错误时间',
  is_solved TINYINT(1) DEFAULT 0 COMMENT '是否已攻克',
  solve_time DATETIME COMMENT '攻克时间',
  student_answer TEXT COMMENT '学生错误答案',
  correct_answer VARCHAR(500) COMMENT '正确答案',
  INDEX idx_student (student_id),
  INDEX idx_question (question_id),
  INDEX idx_exam (exam_id),
  UNIQUE KEY uk_student_question (student_id, question_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='学生错题记录表';

-- ============================================
-- 4. 学生自测记录表
-- ============================================
CREATE TABLE IF NOT EXISTS biz_student_quiz (
  id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '自测ID',
  student_id BIGINT NOT NULL COMMENT '学生ID',
  collection_id BIGINT COMMENT '题集ID',
  name VARCHAR(200) COMMENT '自测名称',
  question_count INT NOT NULL COMMENT '题目数量',
  score INT COMMENT '得分',
  total_score INT COMMENT '总分',
  duration INT COMMENT '用时(秒)',
  start_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '开始时间',
  submit_time DATETIME COMMENT '提交时间',
  status TINYINT DEFAULT 0 COMMENT '状态:0-进行中,1-已完成',
  INDEX idx_student (student_id),
  INDEX idx_collection (collection_id),
  INDEX idx_start_time (start_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='学生自测记录表';

-- ============================================
-- 5. 自测答案表
-- ============================================
CREATE TABLE IF NOT EXISTS biz_quiz_answer (
  id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'ID',
  quiz_id BIGINT NOT NULL COMMENT '自测ID',
  question_id BIGINT NOT NULL COMMENT '题目ID',
  student_answer TEXT COMMENT '学生答案(JSON)',
  is_correct TINYINT(1) COMMENT '是否正确',
  score INT COMMENT '得分',
  INDEX idx_quiz (quiz_id),
  INDEX idx_question (question_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='自测答案表';

-- ============================================
-- 6. 考试监考事件表
-- ============================================
CREATE TABLE IF NOT EXISTS biz_exam_monitor_event (
  id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '事件ID',
  record_id BIGINT COMMENT '考试记录ID',
  student_id BIGINT NOT NULL COMMENT '学生ID',
  exam_id BIGINT NOT NULL COMMENT '考试ID',
  event_type VARCHAR(50) NOT NULL COMMENT '事件类型:SWITCH_SCREEN,FACE_MISSING,BROWSER_BLUR等',
  event_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '事件时间',
  event_data TEXT COMMENT '事件数据(JSON)',
  severity VARCHAR(20) DEFAULT 'INFO' COMMENT '严重程度:INFO,WARNING,CRITICAL',
  INDEX idx_record (record_id),
  INDEX idx_student_exam (student_id, exam_id),
  INDEX idx_event_time (event_time),
  INDEX idx_event_type (event_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='考试监考事件表';

-- ============================================
-- 7. 人脸验证记录表
-- ============================================
CREATE TABLE IF NOT EXISTS biz_face_verification (
  id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'ID',
  student_id BIGINT NOT NULL COMMENT '学生ID',
  exam_id BIGINT NOT NULL COMMENT '考试ID',
  image_data MEDIUMTEXT COMMENT '人脸图片(Base64)',
  verification_result TINYINT(1) COMMENT '验证结果:1-通过,0-失败',
  similarity DECIMAL(5,2) COMMENT '相似度(0-100)',
  verify_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '验证时间',
  failure_reason VARCHAR(200) COMMENT '失败原因',
  INDEX idx_student_exam (student_id, exam_id),
  INDEX idx_verify_time (verify_time),
  INDEX idx_result (verification_result)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='人脸验证记录表';

-- ============================================
-- 8. 为每个学生创建默认错题集
-- ============================================
-- 注意：这个需要在有学生数据后执行，或者在学生首次登录时自动创建

-- ============================================
-- 9. 初始化测试数据（可选）
-- ============================================

-- 为测试学生创建默认题集（假设student_id=1存在）
INSERT INTO biz_student_collection (student_id, name, description, is_default, question_count) 
SELECT 1, '我的错题集', '系统自动创建的错题集', 1, 0
WHERE NOT EXISTS (
    SELECT 1 FROM biz_student_collection WHERE student_id = 1 AND is_default = 1
);

-- ============================================
-- 10. 验证表创建
-- ============================================
SELECT '数据库迁移完成！' as message;

SELECT 
    TABLE_NAME as '表名',
    TABLE_COMMENT as '说明'
FROM information_schema.TABLES 
WHERE TABLE_SCHEMA = DATABASE() 
AND TABLE_NAME IN (
    'biz_student_collection',
    'biz_collection_question',
    'biz_student_error',
    'biz_student_quiz',
    'biz_quiz_answer',
    'biz_exam_monitor_event',
    'biz_face_verification'
);

SET FOREIGN_KEY_CHECKS = 1;

