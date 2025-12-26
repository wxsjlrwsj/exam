-- 错题本表结构迁移脚本
-- 创建日期: 2024-12-25

USE chaoxing;

-- 创建错题本表
CREATE TABLE IF NOT EXISTS biz_student_error_book (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  student_id BIGINT NOT NULL COMMENT '学生ID',
  question_id BIGINT NOT NULL COMMENT '题目ID',
  exam_id BIGINT NULL COMMENT '关联考试ID（可选）',
  wrong_answer TEXT NULL COMMENT '错误答案',
  wrong_count INT NOT NULL DEFAULT 1 COMMENT '错误次数',
  mastered TINYINT NOT NULL DEFAULT 0 COMMENT '是否已掌握(0-未掌握, 1-已掌握)',
  last_wrong_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '最近一次做错时间',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  UNIQUE KEY uniq_student_question (student_id, question_id),
  KEY idx_student_id (student_id),
  KEY idx_question_id (question_id),
  KEY idx_exam_id (exam_id),
  KEY idx_mastered (mastered)
) COMMENT='学生错题本表';

-- 添加外键约束（可选，取决于数据完整性要求）
-- ALTER TABLE biz_student_error_book 
--   ADD CONSTRAINT fk_error_book_student FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
--   ADD CONSTRAINT fk_error_book_question FOREIGN KEY (question_id) REFERENCES biz_question(id) ON DELETE CASCADE;

-- 添加错题笔记表（可选扩展功能）
CREATE TABLE IF NOT EXISTS biz_error_book_note (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  error_book_id BIGINT NOT NULL COMMENT '错题本记录ID',
  note_content TEXT NOT NULL COMMENT '笔记内容',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  KEY idx_error_book_id (error_book_id)
) COMMENT='错题笔记表';

-- 添加索引以优化查询性能
CREATE INDEX idx_student_mastered ON biz_student_error_book(student_id, mastered);
CREATE INDEX idx_last_wrong_time ON biz_student_error_book(last_wrong_time DESC);

