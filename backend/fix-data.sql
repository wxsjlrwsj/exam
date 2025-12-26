-- 修复损坏的中文数据并添加可发布的试卷
USE chaoxing;

-- 1. 删除损坏的考试数据（ID 5-8）
DELETE FROM biz_exam_student WHERE exam_id IN (5,6,7,8);
DELETE FROM biz_exam WHERE id IN (5,6,7,8);

-- 2. 删除损坏的题目数据（ID 45-54）
DELETE FROM biz_paper_question WHERE question_id >= 45;
DELETE FROM biz_question WHERE id >= 45;

-- 3. 重新插入正确的题目数据
INSERT INTO biz_question (id, type_id, content, options, answer, analysis, difficulty, subject, knowledge_points, status, creator_id) VALUES
-- Java题目
(45, 4, 'OSI模型共有____层', '[]', '["7"]', '开放系统互连参考模型（OSI）包含7层：物理层、数据链路层、网络层、传输层、会话层、表示层、应用层', 2, '计算机网络', '网络基础', 1, 2),
(46, 4, '数据库的三级模式结构包括外模式、____和内模式', '[]', '["模式"]', '数据库系统的三级模式结构：外模式（用户视图）、模式（逻辑结构）、内模式（物理结构）', 2, '数据库原理', '数据库系统结构', 1, 2),
(47, 4, 'SQL语言中用于查询的关键字是____', '[]', '["SELECT"]', 'SQL的SELECT语句用于从数据库中查询数据', 1, '数据库原理', 'SQL基础', 1, 2),
(48, 4, '在Java中，用于处理异常的关键字是try、catch和____', '[]', '["finally"]', 'Java异常处理机制包括try、catch、finally三个关键字', 2, 'Java', '异常处理', 1, 2),
(49, 5, '简述Java中ArrayList和LinkedList的区别及各自的适用场景', '[]', '["ArrayList基于动态数组实现，查询快O(1)，插入删除慢O(n)；LinkedList基于双向链表实现，插入删除快O(1)，查询慢O(n)。ArrayList适合随机访问场景，LinkedList适合频繁插入删除场景。"]', '考察对Java集合框架的理解', 3, 'Java', '集合框架', 1, 2),
(50, 5, '什么是死锁？如何预防死锁？', '[]', '["死锁是指两个或多个进程在执行过程中，因争夺资源而造成的互相等待现象。预防死锁的方法：1.破坏互斥条件 2.破坏请求和保持条件 3.破坏不可剥夺条件 4.破坏循环等待条件"]', '考察操作系统死锁概念', 4, '操作系统', '进程管理', 1, 2),
(51, 5, '简述TCP三次握手的过程', '[]', '["第一次握手：客户端发送SYN包到服务器；第二次握手：服务器收到SYN包，回应SYN+ACK包；第三次握手：客户端收到SYN+ACK包，发送ACK包。三次握手完成后，TCP连接建立。"]', '考察计算机网络TCP协议', 3, '计算机网络', 'TCP协议', 1, 2),
(52, 5, '解释数据库事务的ACID特性', '[]', '["A-原子性(Atomicity)：事务是不可分割的最小单位；C-一致性(Consistency)：事务前后数据完整性保持一致；I-隔离性(Isolation)：多个事务并发执行时互不干扰；D-持久性(Durability)：事务提交后永久保存"]', '考察数据库事务特性', 3, '数据库原理', '事务管理', 1, 2),
(53, 1, '以下哪个不是Python的数据类型？', '["A. list", "B. tuple", "C. array", "D. dict"]', '["C"]', 'Python内置数据类型包括list、tuple、dict、set等，array需要导入numpy库', 2, 'Python', '数据类型', 1, 2),
(54, 1, '在关系数据库中，用于唯一标识元组的属性或属性组称为？', '["A. 外键", "B. 主键", "C. 索引", "D. 约束"]', '["B"]', '主键用于唯一标识表中的每一行记录', 1, '数据库原理', '关系模型', 1, 2);

-- 4. 重新插入正确的考试数据
INSERT INTO biz_exam (id, name, description, paper_id, creator_id, start_time, end_time, duration, total_score, pass_score, status, create_time) VALUES
(5, 'Java程序设计期末考试（2025秋季）', 'Java程序设计课程期末统一考试', 1, 2, '2025-12-27 09:00:00', '2025-12-27 11:00:00', 120, 100, 60, 1, NOW()),
(6, '数据库原理期中测试（2025秋季）', '数据库原理课程期中阶段性测评', 2, 2, '2025-12-28 14:00:00', '2025-12-28 16:00:00', 90, 100, 60, 1, NOW()),
(7, '计算机网络基础测试（第十周）', '计算机网络课程第十周测验', 3, 2, '2025-12-29 10:00:00', '2025-12-29 11:30:00', 90, 100, 60, 0, NOW()),
(8, '操作系统原理综合测试', '操作系统课程综合能力测试', 4, 2, '2026-01-10 09:00:00', '2026-01-10 11:00:00', 120, 120, 72, 1, NOW());

-- 5. 为考试分配学生
INSERT INTO biz_exam_student (exam_id, user_id) VALUES
(5, 3), (6, 3), (7, 3), (8, 3);

-- 6. 创建新的可发布试卷
INSERT INTO biz_paper (name, subject, total_score, pass_score, status, creator_id) VALUES
('Java基础知识测试卷A', 'Java', 100, 60, 2, 2),
('数据库系统原理测试卷B', '数据库原理', 100, 60, 2, 2),
('计算机网络技术测试卷C', '计算机网络', 100, 60, 2, 2),
('操作系统综合测试卷D', '操作系统', 120, 72, 2, 2),
('数据结构与算法测试卷E', '数据结构', 100, 60, 2, 2);

-- 7. 为新试卷添加题目（使用现有的正确题目）
-- 获取新创建的试卷ID
SET @paper11 = (SELECT id FROM biz_paper WHERE name = 'Java基础知识测试卷A');
SET @paper12 = (SELECT id FROM biz_paper WHERE name = '数据库系统原理测试卷B');
SET @paper13 = (SELECT id FROM biz_paper WHERE name = '计算机网络技术测试卷C');
SET @paper14 = (SELECT id FROM biz_paper WHERE name = '操作系统综合测试卷D');
SET @paper15 = (SELECT id FROM biz_paper WHERE name = '数据结构与算法测试卷E');

-- 试卷11: Java基础知识测试卷A (20题)
INSERT INTO biz_paper_question (paper_id, question_id, score, sort_order) VALUES
(@paper11, 1, 5, 1), (@paper11, 2, 5, 2), (@paper11, 3, 5, 3), (@paper11, 48, 5, 4), (@paper11, 49, 10, 5),
(@paper11, 1, 5, 6), (@paper11, 2, 5, 7), (@paper11, 3, 5, 8), (@paper11, 48, 5, 9), (@paper11, 49, 10, 10),
(@paper11, 1, 5, 11), (@paper11, 2, 5, 12), (@paper11, 3, 5, 13), (@paper11, 48, 5, 14), (@paper11, 49, 10, 15),
(@paper11, 1, 5, 16), (@paper11, 2, 5, 17), (@paper11, 3, 5, 18), (@paper11, 48, 5, 19), (@paper11, 49, 10, 20);

-- 试卷12: 数据库系统原理测试卷B (18题)
INSERT INTO biz_paper_question (paper_id, question_id, score, sort_order) VALUES
(@paper12, 10, 5, 1), (@paper12, 54, 5, 2), (@paper12, 47, 5, 3), (@paper12, 46, 5, 4), (@paper12, 52, 10, 5),
(@paper12, 10, 5, 6), (@paper12, 54, 5, 7), (@paper12, 47, 5, 8), (@paper12, 46, 5, 9), (@paper12, 52, 10, 10),
(@paper12, 10, 5, 11), (@paper12, 54, 5, 12), (@paper12, 47, 5, 13), (@paper12, 46, 5, 14), (@paper12, 52, 10, 15),
(@paper12, 9, 10, 16), (@paper12, 9, 10, 17), (@paper12, 9, 10, 18);

-- 试卷13: 计算机网络技术测试卷C (22题)
INSERT INTO biz_paper_question (paper_id, question_id, score, sort_order) VALUES
(@paper13, 4, 4, 1), (@paper13, 5, 4, 2), (@paper13, 45, 4, 3), (@paper13, 51, 8, 4),
(@paper13, 4, 4, 5), (@paper13, 5, 4, 6), (@paper13, 45, 4, 7), (@paper13, 51, 8, 8),
(@paper13, 4, 4, 9), (@paper13, 5, 4, 10), (@paper13, 45, 4, 11), (@paper13, 51, 8, 12),
(@paper13, 4, 4, 13), (@paper13, 5, 4, 14), (@paper13, 45, 4, 15), (@paper13, 51, 8, 16),
(@paper13, 4, 4, 17), (@paper13, 5, 4, 18), (@paper13, 45, 4, 19), (@paper13, 51, 8, 20),
(@paper13, 51, 8, 21), (@paper13, 51, 8, 22);

-- 试卷14: 操作系统综合测试卷D (25题)
INSERT INTO biz_paper_question (paper_id, question_id, score, sort_order) VALUES
(@paper14, 8, 4, 1), (@paper14, 8, 4, 2), (@paper14, 8, 4, 3), (@paper14, 8, 4, 4), (@paper14, 50, 8, 5),
(@paper14, 8, 4, 6), (@paper14, 8, 4, 7), (@paper14, 8, 4, 8), (@paper14, 8, 4, 9), (@paper14, 50, 8, 10),
(@paper14, 8, 4, 11), (@paper14, 8, 4, 12), (@paper14, 8, 4, 13), (@paper14, 8, 4, 14), (@paper14, 50, 8, 15),
(@paper14, 8, 4, 16), (@paper14, 8, 4, 17), (@paper14, 8, 4, 18), (@paper14, 8, 4, 19), (@paper14, 50, 8, 20),
(@paper14, 50, 8, 21), (@paper14, 50, 8, 22), (@paper14, 50, 8, 23), (@paper14, 50, 8, 24), (@paper14, 50, 8, 25);

-- 试卷15: 数据结构与算法测试卷E (20题)
INSERT INTO biz_paper_question (paper_id, question_id, score, sort_order) VALUES
(@paper15, 6, 5, 1), (@paper15, 7, 5, 2), (@paper15, 6, 5, 3), (@paper15, 7, 5, 4), (@paper15, 6, 5, 5),
(@paper15, 7, 5, 6), (@paper15, 6, 5, 7), (@paper15, 7, 5, 8), (@paper15, 6, 5, 9), (@paper15, 7, 5, 10),
(@paper15, 6, 5, 11), (@paper15, 7, 5, 12), (@paper15, 6, 5, 13), (@paper15, 7, 5, 14), (@paper15, 6, 5, 15),
(@paper15, 7, 5, 16), (@paper15, 6, 5, 17), (@paper15, 7, 5, 18), (@paper15, 6, 5, 19), (@paper15, 7, 5, 20);

-- 8. 验证数据
SELECT '=== 修复后的考试数据 ===' as info;
SELECT id, name, status FROM biz_exam WHERE id >= 5;

SELECT '=== 修复后的题目数据 ===' as info;
SELECT id, LEFT(content, 40) as content, subject FROM biz_question WHERE id >= 45;

SELECT '=== 新创建的试卷 ===' as info;
SELECT id, name, subject, question_count, total_score, status FROM biz_paper WHERE id >= 11;

SELECT '=== 试卷题目关联 ===' as info;
SELECT paper_id, COUNT(*) as question_count FROM biz_paper_question WHERE paper_id >= @paper11 GROUP BY paper_id;
