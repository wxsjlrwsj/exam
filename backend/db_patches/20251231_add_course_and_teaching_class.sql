SET NAMES utf8mb4;
USE chaoxing;

CREATE TABLE IF NOT EXISTS biz_course (
  id BIGINT NOT NULL AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  creator_id BIGINT NOT NULL,
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_creator (creator_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS biz_course_teacher (
  id BIGINT NOT NULL AUTO_INCREMENT,
  course_id BIGINT NOT NULL,
  teacher_id BIGINT NOT NULL,
  assign_time DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_course_teacher (course_id, teacher_id),
  KEY idx_course (course_id),
  KEY idx_teacher (teacher_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS biz_teaching_class (
  id BIGINT NOT NULL AUTO_INCREMENT,
  course_id BIGINT NOT NULL,
  name VARCHAR(100) NOT NULL,
  assigned_teacher_id BIGINT,
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_course (course_id),
  KEY idx_assigned_teacher (assigned_teacher_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS biz_teaching_class_student (
  id BIGINT NOT NULL AUTO_INCREMENT,
  class_id BIGINT NOT NULL,
  user_id BIGINT NOT NULL,
  add_time DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_class_user (class_id, user_id),
  KEY idx_class (class_id),
  KEY idx_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SET @exists_course := (
  SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES 
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'biz_course'
);
SET @sql_course := IF(@exists_course>0, 'ALTER TABLE biz_course CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci', 'SELECT 1');
PREPARE s_course FROM @sql_course; EXECUTE s_course; DEALLOCATE PREPARE s_course;

SET @exists_ct := (
  SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES 
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'biz_course_teacher'
);
SET @sql_ct := IF(@exists_ct>0, 'ALTER TABLE biz_course_teacher CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci', 'SELECT 1');
PREPARE s_ct FROM @sql_ct; EXECUTE s_ct; DEALLOCATE PREPARE s_ct;

SET @exists_tc := (
  SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES 
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'biz_teaching_class'
);
SET @sql_tc := IF(@exists_tc>0, 'ALTER TABLE biz_teaching_class CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci', 'SELECT 1');
PREPARE s_tc FROM @sql_tc; EXECUTE s_tc; DEALLOCATE PREPARE s_tc;

SET @exists_tcs := (
  SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES 
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'biz_teaching_class_student'
);
SET @sql_tcs := IF(@exists_tcs>0, 'ALTER TABLE biz_teaching_class_student CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci', 'SELECT 1');
PREPARE s_tcs FROM @sql_tcs; EXECUTE s_tcs; DEALLOCATE PREPARE s_tcs;

SET @teacher1 := (SELECT id FROM users WHERE username='teacher1');
SET @teacher2 := (SELECT id FROM users WHERE username='teacher2');

INSERT IGNORE INTO biz_course (name, description, creator_id)
SELECT s.name, s.description,
CASE s.code
  WHEN 'java' THEN @teacher1
  WHEN 'ds' THEN @teacher1
  WHEN 'network' THEN @teacher2
  WHEN 'os' THEN @teacher2
  WHEN 'database' THEN @teacher1
  WHEN 'se' THEN @teacher2
  WHEN 'computer_org' THEN @teacher2
  WHEN 'compiler' THEN @teacher1
  ELSE @teacher1
END
FROM biz_subject s
WHERE NOT EXISTS (SELECT 1 FROM biz_course c WHERE c.name = s.name);

INSERT IGNORE INTO biz_course_teacher (course_id, teacher_id)
SELECT c.id, @teacher1
FROM biz_course c
JOIN biz_subject s ON c.name COLLATE utf8mb4_0900_ai_ci = s.name
WHERE s.code IN ('java','ds','database','compiler');

INSERT IGNORE INTO biz_course_teacher (course_id, teacher_id)
SELECT c.id, @teacher2
FROM biz_course c
JOIN biz_subject s ON c.name COLLATE utf8mb4_0900_ai_ci = s.name
WHERE s.code IN ('network','os','se','computer_org');

INSERT IGNORE INTO biz_teaching_class (course_id, name, assigned_teacher_id)
SELECT c.id, CONCAT(s.name,'-2025春A'), @teacher1
FROM biz_course c
JOIN biz_subject s ON c.name COLLATE utf8mb4_0900_ai_ci = s.name
WHERE s.code IN ('java','ds','database','compiler');

INSERT IGNORE INTO biz_teaching_class (course_id, name, assigned_teacher_id)
SELECT c.id, CONCAT(s.name,'-2025春A'), @teacher2
FROM biz_course c
JOIN biz_subject s ON c.name COLLATE utf8mb4_0900_ai_ci = s.name
WHERE s.code IN ('network','os','se','computer_org');

SET @cls_java := (
  SELECT tc.id
  FROM biz_teaching_class tc
  JOIN biz_course c ON tc.course_id = c.id
  JOIN biz_subject s ON c.name COLLATE utf8mb4_0900_ai_ci = s.name
  WHERE s.code='java'
  LIMIT 1
);
SET @cls_ds := (
  SELECT tc.id
  FROM biz_teaching_class tc
  JOIN biz_course c ON tc.course_id = c.id
  JOIN biz_subject s ON c.name COLLATE utf8mb4_0900_ai_ci = s.name
  WHERE s.code='ds'
  LIMIT 1
);
SET @cls_network := (
  SELECT tc.id
  FROM biz_teaching_class tc
  JOIN biz_course c ON tc.course_id = c.id
  JOIN biz_subject s ON c.name COLLATE utf8mb4_0900_ai_ci = s.name
  WHERE s.code='network'
  LIMIT 1
);
SET @cls_os := (
  SELECT tc.id
  FROM biz_teaching_class tc
  JOIN biz_course c ON tc.course_id = c.id
  JOIN biz_subject s ON c.name COLLATE utf8mb4_0900_ai_ci = s.name
  WHERE s.code='os'
  LIMIT 1
);

INSERT IGNORE INTO biz_teaching_class_student (class_id, user_id)
SELECT @cls_java, u.id FROM users u WHERE u.username IN ('student1','student2','student3');

INSERT IGNORE INTO biz_teaching_class_student (class_id, user_id)
SELECT @cls_ds, u.id FROM users u WHERE u.username IN ('student4','student5','student6');

INSERT IGNORE INTO biz_teaching_class_student (class_id, user_id)
SELECT @cls_network, u.id FROM users u WHERE u.username IN ('student7','student8','student9');

INSERT IGNORE INTO biz_teaching_class_student (class_id, user_id)
SELECT @cls_os, u.id FROM users u WHERE u.username IN ('student10','student11','student12');
