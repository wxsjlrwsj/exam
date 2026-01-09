SET NAMES utf8mb4;
USE chaoxing;

CREATE TEMPORARY TABLE tmp_used_paper_ids AS
SELECT p.id
FROM biz_paper p
LEFT JOIN biz_exam e ON e.paper_id = p.id
WHERE p.status = 1 AND e.id IS NULL;

DELETE FROM biz_paper_question
WHERE paper_id IN (SELECT id FROM tmp_used_paper_ids);

DELETE FROM biz_paper
WHERE id IN (SELECT id FROM tmp_used_paper_ids);

DROP TEMPORARY TABLE tmp_used_paper_ids;
