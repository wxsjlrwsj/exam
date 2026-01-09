SET NAMES utf8mb4;
USE chaoxing;

ALTER TABLE biz_subject
  ADD COLUMN creator_user_id BIGINT NULL;

UPDATE biz_subject s
LEFT JOIN (
  SELECT subject_id, MIN(teacher_id) AS tid
  FROM biz_teacher_subject_map
  GROUP BY subject_id
) m ON m.subject_id = s.id
SET s.creator_user_id = COALESCE(s.creator_user_id, m.tid)
WHERE s.creator_user_id IS NULL;
