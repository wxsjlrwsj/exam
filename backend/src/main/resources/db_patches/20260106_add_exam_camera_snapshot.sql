CREATE TABLE IF NOT EXISTS biz_exam_camera_snapshot (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  exam_id BIGINT NOT NULL,
  student_id BIGINT NOT NULL,
  image_data LONGBLOB NOT NULL,
  content_type VARCHAR(50) NOT NULL,
  capture_time DATETIME DEFAULT CURRENT_TIMESTAMP,
  KEY idx_exam_student_time (exam_id, student_id, capture_time)
);
