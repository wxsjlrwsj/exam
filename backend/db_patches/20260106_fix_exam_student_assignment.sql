SET NAMES utf8mb4;

INSERT INTO biz_exam_student (exam_id, user_id, status)
SELECT 
  e.id AS exam_id,
  tcs.user_id AS user_id,
  'normal' AS status
FROM biz_exam e
JOIN biz_paper p ON p.id = e.paper_id
JOIN biz_subject s ON s.name = p.subject
JOIN biz_teaching_class tc ON tc.subject_id = s.id
JOIN biz_teaching_class_student tcs ON tcs.class_id = tc.id
LEFT JOIN biz_exam_student es ON es.exam_id = e.id AND es.user_id = tcs.user_id
WHERE es.exam_id IS NULL
  AND (e.status IS NULL OR e.status IN (0, 1));
