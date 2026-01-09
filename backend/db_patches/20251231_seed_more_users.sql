SET NAMES utf8mb4;
USE chaoxing;

-- 批量导入更多教师（仅创建用户，不绑定学院，便于在学院/班级进行分配）
INSERT IGNORE INTO users (username, email, password_hash, user_type, real_name)
VALUES
 ('teacher6','teacher6@example.com','$2a$10$NmSOuZw1f36ATVUKqTV5f.wVI3DVxqyYJdMQIQsK4CAel6wYslBke','teacher','教师六'),
 ('teacher7','teacher7@example.com','$2a$10$NmSOuZw1f36ATVUKqTV5f.wVI3DVxqyYJdMQIQsK4CAel6wYslBke','teacher','教师七'),
 ('teacher8','teacher8@example.com','$2a$10$NmSOuZw1f36ATVUKqTV5f.wVI3DVxqyYJdMQIQsK4CAel6wYslBke','teacher','教师八'),
 ('teacher9','teacher9@example.com','$2a$10$NmSOuZw1f36ATVUKqTV5f.wVI3DVxqyYJdMQIQsK4CAel6wYslBke','teacher','教师九'),
 ('teacher10','teacher10@example.com','$2a$10$NmSOuZw1f36ATVUKqTV5f.wVI3DVxqyYJdMQIQsK4CAel6wYslBke','teacher','教师十'),
 ('teacher11','teacher11@example.com','$2a$10$NmSOuZw1f36ATVUKqTV5f.wVI3DVxqyYJdMQIQsK4CAel6wYslBke','teacher','教师十一'),
 ('teacher12','teacher12@example.com','$2a$10$NmSOuZw1f36ATVUKqTV5f.wVI3DVxqyYJdMQIQsK4CAel6wYslBke','teacher','教师十二'),
 ('teacher13','teacher13@example.com','$2a$10$NmSOuZw1f36ATVUKqTV5f.wVI3DVxqyYJdMQIQsK4CAel6wYslBke','teacher','教师十三'),
 ('teacher14','teacher14@example.com','$2a$10$NmSOuZw1f36ATVUKqTV5f.wVI3DVxqyYJdMQIQsK4CAel6wYslBke','teacher','教师十四'),
 ('teacher15','teacher15@example.com','$2a$10$NmSOuZw1f36ATVUKqTV5f.wVI3DVxqyYJdMQIQsK4CAel6wYslBke','teacher','教师十五');

-- 批量导入更多学生（仅创建用户，不绑定班级，便于在班级进行分配）
INSERT IGNORE INTO users (username, email, password_hash, user_type, real_name)
VALUES
 ('student10','student10@example.com','$2a$10$NmSOuZw1f36ATVUKqTV5f.wVI3DVxqyYJdMQIQsK4CAel6wYslBke','student','学生十'),
 ('student11','student11@example.com','$2a$10$NmSOuZw1f36ATVUKqTV5f.wVI3DVxqyYJdMQIQsK4CAel6wYslBke','student','学生十一'),
 ('student12','student12@example.com','$2a$10$NmSOuZw1f36ATVUKqTV5f.wVI3DVxqyYJdMQIQsK4CAel6wYslBke','student','学生十二'),
 ('student13','student13@example.com','$2a$10$NmSOuZw1f36ATVUKqTV5f.wVI3DVxqyYJdMQIQsK4CAel6wYslBke','student','学生十三'),
 ('student14','student14@example.com','$2a$10$NmSOuZw1f36ATVUKqTV5f.wVI3DVxqyYJdMQIQsK4CAel6wYslBke','student','学生十四'),
 ('student15','student15@example.com','$2a$10$NmSOuZw1f36ATVUKqTV5f.wVI3DVxqyYJdMQIQsK4CAel6wYslBke','student','学生十五'),
 ('student16','student16@example.com','$2a$10$NmSOuZw1f36ATVUKqTV5f.wVI3DVxqyYJdMQIQsK4CAel6wYslBke','student','学生十六'),
 ('student17','student17@example.com','$2a$10$NmSOuZw1f36ATVUKqTV5f.wVI3DVxqyYJdMQIQsK4CAel6wYslBke','student','学生十七'),
 ('student18','student18@example.com','$2a$10$NmSOuZw1f36ATVUKqTV5f.wVI3DVxqyYJdMQIQsK4CAel6wYslBke','student','学生十八'),
 ('student19','student19@example.com','$2a$10$NmSOuZw1f36ATVUKqTV5f.wVI3DVxqyYJdMQIQsK4CAel6wYslBke','student','学生十九'),
 ('student20','student20@example.com','$2a$10$NmSOuZw1f36ATVUKqTV5f.wVI3DVxqyYJdMQIQsK4CAel6wYslBke','student','学生二十'),
 ('student21','student21@example.com','$2a$10$NmSOuZw1f36ATVUKqTV5f.wVI3DVxqyYJdMQIQsK4CAel6wYslBke','student','学生二十一'),
 ('student22','student22@example.com','$2a$10$NmSOuZw1f36ATVUKqTV5f.wVI3DVxqyYJdMQIQsK4CAel6wYslBke','student','学生二十二'),
 ('student23','student23@example.com','$2a$10$NmSOuZw1f36ATVUKqTV5f.wVI3DVxqyYJdMQIQsK4CAel6wYslBke','student','学生二十三'),
 ('student24','student24@example.com','$2a$10$NmSOuZw1f36ATVUKqTV5f.wVI3DVxqyYJdMQIQsK4CAel6wYslBke','student','学生二十四'),
 ('student25','student25@example.com','$2a$10$NmSOuZw1f36ATVUKqTV5f.wVI3DVxqyYJdMQIQsK4CAel6wYslBke','student','学生二十五');

