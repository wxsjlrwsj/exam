SET NAMES utf8mb4;
USE chaoxing;

CREATE TEMPORARY TABLE tmp_finished_exam_ids AS
SELECT e.id
FROM biz_exam e
WHERE (e.status = 2) OR (e.end_time IS NOT NULL AND e.end_time < NOW());

DELETE FROM biz_monitor_warning
WHERE exam_id IN (SELECT id FROM tmp_finished_exam_ids);

DELETE FROM biz_exam_monitor_event
WHERE exam_id IN (SELECT id FROM tmp_finished_exam_ids);

DELETE FROM biz_exam_answer
WHERE record_id IN (
  SELECT id FROM biz_exam_record
  WHERE exam_id IN (SELECT id FROM tmp_finished_exam_ids)
);

DELETE FROM biz_exam_record
WHERE exam_id IN (SELECT id FROM tmp_finished_exam_ids);

DELETE FROM biz_exam_student
WHERE exam_id IN (SELECT id FROM tmp_finished_exam_ids);

UPDATE biz_student_error_book
SET exam_id = NULL
WHERE exam_id IN (SELECT id FROM tmp_finished_exam_ids);

DELETE FROM biz_exam
WHERE id IN (SELECT id FROM tmp_finished_exam_ids);

DROP TEMPORARY TABLE tmp_finished_exam_ids;
