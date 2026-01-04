CREATE TABLE IF NOT EXISTS `biz_exam_question` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `type_id` tinyint NOT NULL,
  `content` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `options` json DEFAULT NULL,
  `answer` json NOT NULL,
  `analysis` text COLLATE utf8mb4_unicode_ci,
  `difficulty` tinyint NOT NULL DEFAULT '1',
  `subject` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `knowledge_points` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `file_id` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `creator_id` bigint DEFAULT NULL,
  `status` tinyint NOT NULL DEFAULT '0',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `biz_exam_question` (
  `id`, `type_id`, `content`, `options`, `answer`, `analysis`, `difficulty`,
  `subject`, `knowledge_points`, `file_id`, `creator_id`, `status`, `create_time`, `update_time`
) 
SELECT 
  q.`id`, q.`type_id`, q.`content`, q.`options`, q.`answer`, q.`analysis`, q.`difficulty`,
  q.`subject`, q.`knowledge_points`, q.`file_id`, q.`creator_id`, q.`status`, q.`create_time`, q.`update_time`
FROM `biz_question` q
WHERE NOT EXISTS (SELECT 1 FROM `biz_exam_question` e WHERE e.`id` = q.`id`);
