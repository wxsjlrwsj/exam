INSERT IGNORE INTO biz_collection_question (collection_id, question_id)
SELECT c.id, q.id
FROM biz_student_collection c
JOIN (SELECT id FROM biz_question ORDER BY id LIMIT 5) q
WHERE c.is_default = 1;

UPDATE biz_student_collection c
JOIN (
  SELECT collection_id, COUNT(*) AS cnt
  FROM biz_collection_question
  GROUP BY collection_id
) x ON x.collection_id = c.id
SET c.question_count = x.cnt
WHERE c.is_default = 1;
