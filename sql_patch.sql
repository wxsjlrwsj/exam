INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name=''数据库设计综合试卷A''), q.id, 20, 1
 FROM (SELECT id FROM biz_question WHERE type_id=1 AND subject=''数据库原理'' ORDER BY id LIMIT 1) q;
INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name=''数据库设计综合试卷A''), q.id, 20, 2
 FROM (SELECT id FROM biz_question WHERE type_id=2 ORDER BY id LIMIT 1) q;
INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name=''数据库设计综合试卷A''), q.id, 20, 3
 FROM (SELECT id FROM biz_question WHERE type_id=3 ORDER BY id LIMIT 1) q;
INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name=''数据库设计综合试卷A''), q.id, 20, 4
 FROM (SELECT id FROM biz_question WHERE type_id=4 ORDER BY id LIMIT 1) q;
INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name=''数据库设计综合试卷A''), q.id, 20, 5
 FROM (SELECT id FROM biz_question WHERE type_id=5 AND subject=''数据库原理'' ORDER BY id LIMIT 1) q;

INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name=''计算机网络安全阶段性试卷B''), q.id, 20, 1
 FROM (SELECT id FROM biz_question WHERE type_id=1 AND subject=''计算机网络'' ORDER BY id LIMIT 1) q;
INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name=''计算机网络安全阶段性试卷B''), q.id, 20, 2
 FROM (SELECT id FROM biz_question WHERE type_id=2 ORDER BY id LIMIT 1) q;
INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name=''计算机网络安全阶段性试卷B''), q.id, 20, 3
 FROM (SELECT id FROM biz_question WHERE type_id=3 AND subject=''计算机网络'' ORDER BY id LIMIT 1) q;
INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name=''计算机网络安全阶段性试卷B''), q.id, 20, 4
 FROM (SELECT id FROM biz_question WHERE type_id=4 ORDER BY id LIMIT 1) q;
INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name=''计算机网络安全阶段性试卷B''), q.id, 20, 5
 FROM (SELECT id FROM biz_question WHERE type_id=5 ORDER BY id LIMIT 1) q;

INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name=''分布式系统原理期末试卷C''), q.id, 20, 1
 FROM (SELECT id FROM biz_question WHERE type_id=1 ORDER BY id LIMIT 1) q;
INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name=''分布式系统原理期末试卷C''), q.id, 20, 2
 FROM (SELECT id FROM biz_question WHERE type_id=2 ORDER BY id LIMIT 1) q;
INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name=''分布式系统原理期末试卷C''), q.id, 20, 3
 FROM (SELECT id FROM biz_question WHERE type_id=3 ORDER BY id LIMIT 1) q;
INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name=''分布式系统原理期末试卷C''), q.id, 20, 4
 FROM (SELECT id FROM biz_question WHERE type_id=4 ORDER BY id LIMIT 1) q;
INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name=''分布式系统原理期末试卷C''), q.id, 20, 5
 FROM (SELECT id FROM biz_question WHERE type_id=5 ORDER BY id LIMIT 1) q;

INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name=''人工智能基础结课试卷D''), q.id, 20, 1
 FROM (SELECT id FROM biz_question WHERE type_id=1 AND subject=''人工智能基础'' ORDER BY id LIMIT 1) q;
INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name=''人工智能基础结课试卷D''), q.id, 20, 2
 FROM (SELECT id FROM biz_question WHERE type_id=2 AND subject=''人工智能基础'' ORDER BY id LIMIT 1) q;
INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name=''人工智能基础结课试卷D''), q.id, 20, 3
 FROM (SELECT id FROM biz_question WHERE type_id=3 AND subject=''人工智能基础'' ORDER BY id LIMIT 1) q;
INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name=''人工智能基础结课试卷D''), q.id, 20, 4
 FROM (SELECT id FROM biz_question WHERE type_id=4 AND subject=''人工智能基础'' ORDER BY id LIMIT 1) q;
INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
 SELECT (SELECT id FROM biz_paper WHERE name=''人工智能基础结课试卷D''), q.id, 20, 5
 FROM (SELECT id FROM biz_question WHERE type_id=5 AND subject=''人工智能基础'' ORDER BY id LIMIT 1) q;