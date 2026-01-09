SET NAMES utf8mb4;
USE chaoxing;
SELECT subject, type_id, COUNT(*) AS cnt 
FROM biz_exam_question 
WHERE subject IN ('编译原理','数据库原理')
GROUP BY subject, type_id
ORDER BY subject, type_id;
