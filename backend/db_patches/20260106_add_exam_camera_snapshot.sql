CREATE TABLE IF NOT EXISTS biz_exam_camera_snapshot (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  exam_id BIGINT NOT NULL,
  student_id BIGINT NOT NULL,
  image_data LONGBLOB NOT NULL,
  content_type VARCHAR(100) DEFAULT 'image/jpeg',
  capture_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_exam_student_time (exam_id, student_id, capture_time)
);
