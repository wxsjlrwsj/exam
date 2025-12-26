USE chaoxing;

CREATE TABLE IF NOT EXISTS biz_student_error_book (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  student_id BIGINT NOT NULL,
  question_id BIGINT NOT NULL,
  exam_id BIGINT NULL,
  wrong_answer TEXT NULL,
  wrong_count INT NOT NULL DEFAULT 1,
  mastered TINYINT NOT NULL DEFAULT 0,
  last_wrong_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uniq_student_question (student_id, question_id),
  KEY idx_student_id (student_id),
  KEY idx_question_id (question_id),
  KEY idx_exam_id (exam_id),
  KEY idx_mastered (mastered)
);

CREATE TABLE IF NOT EXISTS biz_error_book_note (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  error_book_id BIGINT NOT NULL,
  note_content TEXT NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY idx_error_book_id (error_book_id)
);

CREATE INDEX idx_student_mastered ON biz_student_error_book(student_id, mastered);
CREATE INDEX idx_last_wrong_time ON biz_student_error_book(last_wrong_time DESC);

