SET NAMES utf8mb4;
USE chaoxing;

DELETE FROM biz_monitor_warning WHERE exam_id = 7;
DELETE FROM biz_exam_monitor_event WHERE exam_id = 7;
DELETE FROM biz_exam_answer WHERE record_id IN (SELECT id FROM biz_exam_record WHERE exam_id = 7);
DELETE FROM biz_exam_record WHERE exam_id = 7;
DELETE FROM biz_exam_student WHERE exam_id = 7;
UPDATE biz_student_error_book SET exam_id = NULL WHERE exam_id = 7;
DELETE FROM biz_exam WHERE id = 7;
