-- ==========================================
-- 额外题目和试卷数据 - 用于教师端题库和考试管理
-- 创建日期: 2025-12-26
-- 说明: 此脚本添加更多题目和试卷，确保教师端有足够的数据可用
-- ==========================================

USE chaoxing;

-- 添加一个新教师账户用于创建题目
INSERT IGNORE INTO users(username,email,phone,password_hash,user_type,real_name,avatar) VALUES
 ('teacher4','teacher4@example.com',NULL,'$2a$10$NmSOuZw1f36ATVUKqTV5f.wVI3DVxqyYJdMQIQsK4CAel6wYslBke','teacher','教师四',NULL);

-- ==========================================
-- 第一部分: 添加更多题目（涵盖多个科目和题型）
-- ==========================================

-- Java程序设计题目（单选题 type_id=1）
INSERT IGNORE INTO biz_question (type_id, content, options, answer, analysis, difficulty, subject, knowledge_points, file_id, creator_id, status)
VALUES
(1, 'Java中String类的特点是？', '[{"key":"A","value":"可变对象"},{"key":"B","value":"不可变对象"},{"key":"C","value":"基本数据类型"},{"key":"D","value":"接口类型"}]', JSON_QUOTE('B'), 'String是不可变对象，每次修改都会创建新对象', 1, 'Java程序设计', 'String类', NULL, (SELECT id FROM users WHERE username='teacher1'), 1),
(1, '下列哪个关键字用于定义接口？', '[{"key":"A","value":"class"},{"key":"B","value":"interface"},{"key":"C","value":"abstract"},{"key":"D","value":"extends"}]', JSON_QUOTE('B'), 'interface关键字用于定义接口', 1, 'Java程序设计', '接口定义', NULL, (SELECT id FROM users WHERE username='teacher1'), 1),
(1, 'Java中哪个集合类是线程安全的？', '[{"key":"A","value":"ArrayList"},{"key":"B","value":"HashMap"},{"key":"C","value":"Vector"},{"key":"D","value":"LinkedList"}]', JSON_QUOTE('C'), 'Vector是线程安全的集合类', 2, 'Java程序设计', '集合框架', NULL, (SELECT id FROM users WHERE username='teacher1'), 1),
(1, 'Java异常处理中，finally块的作用是？', '[{"key":"A","value":"捕获异常"},{"key":"B","value":"抛出异常"},{"key":"C","value":"无论是否发生异常都会执行"},{"key":"D","value":"只在发生异常时执行"}]', JSON_QUOTE('C'), 'finally块无论是否发生异常都会执行', 2, 'Java程序设计', '异常处理', NULL, (SELECT id FROM users WHERE username='teacher1'), 1),
(1, 'Java中==和equals()的区别是？', '[{"key":"A","value":"没有区别"},{"key":"B","value":"==比较地址，equals比较内容"},{"key":"C","value":"==比较内容，equals比较地址"},{"key":"D","value":"都比较地址"}]', JSON_QUOTE('B'), '==比较引用地址，equals()比较对象内容', 2, 'Java程序设计', '对象比较', NULL, (SELECT id FROM users WHERE username='teacher1'), 1);

-- 数据结构题目（单选题）
INSERT IGNORE INTO biz_question (type_id, content, options, answer, analysis, difficulty, subject, knowledge_points, file_id, creator_id, status)
VALUES
(1, '栈的特点是？', '[{"key":"A","value":"先进先出"},{"key":"B","value":"后进先出"},{"key":"C","value":"随机访问"},{"key":"D","value":"双向访问"}]', JSON_QUOTE('B'), '栈是后进先出(LIFO)的数据结构', 1, '数据结构', '栈', NULL, (SELECT id FROM users WHERE username='teacher2'), 1),
(1, '二叉树的遍历方式不包括？', '[{"key":"A","value":"前序遍历"},{"key":"B","value":"中序遍历"},{"key":"C","value":"后序遍历"},{"key":"D","value":"环形遍历"}]', JSON_QUOTE('D'), '二叉树只有前中后序和层次遍历', 2, '数据结构', '二叉树', NULL, (SELECT id FROM users WHERE username='teacher2'), 1),
(1, '哈希表解决冲突的方法不包括？', '[{"key":"A","value":"链地址法"},{"key":"B","value":"开放地址法"},{"key":"C","value":"再哈希法"},{"key":"D","value":"递归法"}]', JSON_QUOTE('D'), '常见冲突解决方法有链地址法、开放地址法和再哈希法', 3, '数据结构', '哈希表', NULL, (SELECT id FROM users WHERE username='teacher2'), 1),
(1, '队列的特点是？', '[{"key":"A","value":"后进先出"},{"key":"B","value":"先进先出"},{"key":"C","value":"随机访问"},{"key":"D","value":"栈式访问"}]', JSON_QUOTE('B'), '队列是先进先出(FIFO)的数据结构', 1, '数据结构', '队列', NULL, (SELECT id FROM users WHERE username='teacher2'), 1);

-- 计算机网络题目（单选题）
INSERT IGNORE INTO biz_question (type_id, content, options, answer, analysis, difficulty, subject, knowledge_points, file_id, creator_id, status)
VALUES
(1, 'TCP/IP模型共有几层？', '[{"key":"A","value":"3层"},{"key":"B","value":"4层"},{"key":"C","value":"5层"},{"key":"D","value":"7层"}]', JSON_QUOTE('B'), 'TCP/IP模型分为4层：应用层、传输层、网络层、网络接口层', 1, '计算机网络', 'TCP/IP模型', NULL, (SELECT id FROM users WHERE username='teacher2'), 1),
(1, 'HTTP协议默认使用的端口号是？', '[{"key":"A","value":"21"},{"key":"B","value":"23"},{"key":"C","value":"80"},{"key":"D","value":"443"}]', JSON_QUOTE('C'), 'HTTP默认端口是80，HTTPS是443', 1, '计算机网络', 'HTTP协议', NULL, (SELECT id FROM users WHERE username='teacher2'), 1),
(1, 'IP地址192.168.1.1属于哪类地址？', '[{"key":"A","value":"A类"},{"key":"B","value":"B类"},{"key":"C","value":"C类"},{"key":"D","value":"D类"}]', JSON_QUOTE('C'), 'C类地址范围是192.0.0.0-223.255.255.255', 2, '计算机网络', 'IP地址', NULL, (SELECT id FROM users WHERE username='teacher2'), 1),
(1, 'DNS协议的作用是？', '[{"key":"A","value":"文件传输"},{"key":"B","value":"域名解析"},{"key":"C","value":"邮件传输"},{"key":"D","value":"网页浏览"}]', JSON_QUOTE('B'), 'DNS用于将域名解析为IP地址', 1, '计算机网络', 'DNS', NULL, (SELECT id FROM users WHERE username='teacher2'), 1);

-- 操作系统题目（单选题）
INSERT IGNORE INTO biz_question (type_id, content, options, answer, analysis, difficulty, subject, knowledge_points, file_id, creator_id, status)
VALUES
(1, '进程和线程的区别是？', '[{"key":"A","value":"没有区别"},{"key":"B","value":"进程是资源分配单位，线程是调度单位"},{"key":"C","value":"线程是资源分配单位，进程是调度单位"},{"key":"D","value":"都是资源分配单位"}]', JSON_QUOTE('B'), '进程是资源分配的基本单位，线程是CPU调度的基本单位', 2, '操作系统', '进程与线程', NULL, (SELECT id FROM users WHERE username='teacher3'), 1),
(1, '页面置换算法不包括？', '[{"key":"A","value":"FIFO"},{"key":"B","value":"LRU"},{"key":"C","value":"LFU"},{"key":"D","value":"DFS"}]', JSON_QUOTE('D'), 'DFS是图遍历算法，不是页面置换算法', 2, '操作系统', '内存管理', NULL, (SELECT id FROM users WHERE username='teacher3'), 1),
(1, '临界区的作用是？', '[{"key":"A","value":"提高效率"},{"key":"B","value":"保证互斥访问"},{"key":"C","value":"减少内存"},{"key":"D","value":"加速运算"}]', JSON_QUOTE('B'), '临界区用于保证对共享资源的互斥访问', 2, '操作系统', '进程同步', NULL, (SELECT id FROM users WHERE username='teacher3'), 1);

-- 数据库原理题目（单选题）
INSERT IGNORE INTO biz_question (type_id, content, options, answer, analysis, difficulty, subject, knowledge_points, file_id, creator_id, status)
VALUES
(1, '关系数据库的基本操作不包括？', '[{"key":"A","value":"选择"},{"key":"B","value":"投影"},{"key":"C","value":"连接"},{"key":"D","value":"编译"}]', JSON_QUOTE('D'), '关系代数基本操作包括选择、投影、连接、并、差、交等', 2, '数据库原理', '关系代数', NULL, (SELECT id FROM users WHERE username='teacher1'), 1),
(1, 'SQL中DELETE和TRUNCATE的区别是？', '[{"key":"A","value":"没有区别"},{"key":"B","value":"DELETE可回滚，TRUNCATE不可回滚"},{"key":"C","value":"TRUNCATE可回滚，DELETE不可回滚"},{"key":"D","value":"都不可回滚"}]', JSON_QUOTE('B'), 'DELETE是DML语句可回滚，TRUNCATE是DDL语句不可回滚', 3, '数据库原理', 'SQL语句', NULL, (SELECT id FROM users WHERE username='teacher1'), 1),
(1, '数据库的第一范式要求？', '[{"key":"A","value":"消除部分依赖"},{"key":"B","value":"消除传递依赖"},{"key":"C","value":"属性不可再分"},{"key":"D","value":"消除冗余"}]', JSON_QUOTE('C'), '第一范式要求每个属性都是不可再分的原子值', 2, '数据库原理', '范式理论', NULL, (SELECT id FROM users WHERE username='teacher1'), 1);

-- 多选题（type_id=2）
INSERT IGNORE INTO biz_question (type_id, content, options, answer, analysis, difficulty, subject, knowledge_points, file_id, creator_id, status)
VALUES
(2, 'Java中的访问修饰符包括？', '[{"key":"A","value":"public"},{"key":"B","value":"private"},{"key":"C","value":"protected"},{"key":"D","value":"default"}]', JSON_ARRAY('A','B','C','D'), 'Java有四种访问修饰符', 2, 'Java程序设计', '访问控制', NULL, (SELECT id FROM users WHERE username='teacher1'), 1),
(2, '以下哪些是Java的基本数据类型？', '[{"key":"A","value":"int"},{"key":"B","value":"String"},{"key":"C","value":"boolean"},{"key":"D","value":"char"}]', JSON_ARRAY('A','C','D'), 'String是引用类型，不是基本数据类型', 2, 'Java程序设计', '数据类型', NULL, (SELECT id FROM users WHERE username='teacher1'), 1),
(2, '数据库事务的特性包括？', '[{"key":"A","value":"原子性"},{"key":"B","value":"一致性"},{"key":"C","value":"隔离性"},{"key":"D","value":"持久性"}]', JSON_ARRAY('A','B','C','D'), 'ACID是事务的四大特性', 2, '数据库原理', '事务管理', NULL, (SELECT id FROM users WHERE username='teacher1'), 1),
(2, '常见的排序算法包括？', '[{"key":"A","value":"冒泡排序"},{"key":"B","value":"快速排序"},{"key":"C","value":"归并排序"},{"key":"D","value":"二分查找"}]', JSON_ARRAY('A','B','C'), '二分查找是查找算法，不是排序算法', 2, '数据结构', '排序算法', NULL, (SELECT id FROM users WHERE username='teacher2'), 1),
(2, 'TCP协议的特点包括？', '[{"key":"A","value":"面向连接"},{"key":"B","value":"可靠传输"},{"key":"C","value":"无连接"},{"key":"D","value":"流量控制"}]', JSON_ARRAY('A','B','D'), 'TCP是面向连接的可靠传输协议，支持流量控制', 2, '计算机网络', 'TCP协议', NULL, (SELECT id FROM users WHERE username='teacher2'), 1);

-- 判断题（type_id=3）
INSERT IGNORE INTO biz_question (type_id, content, options, answer, analysis, difficulty, subject, knowledge_points, file_id, creator_id, status)
VALUES
(3, 'Java是纯面向对象的编程语言', NULL, JSON_QUOTE('F'), 'Java不是纯面向对象语言，因为有基本数据类型', 2, 'Java程序设计', 'Java特性', NULL, (SELECT id FROM users WHERE username='teacher1'), 1),
(3, '栈是一种先进先出的数据结构', NULL, JSON_QUOTE('F'), '栈是后进先出(LIFO)，队列才是先进先出(FIFO)', 1, '数据结构', '栈', NULL, (SELECT id FROM users WHERE username='teacher2'), 1),
(3, 'UDP协议提供可靠的数据传输', NULL, JSON_QUOTE('F'), 'UDP是不可靠的传输协议，TCP才提供可靠传输', 1, '计算机网络', 'UDP协议', NULL, (SELECT id FROM users WHERE username='teacher2'), 1),
(3, '死锁的四个必要条件缺一不可', NULL, JSON_QUOTE('T'), '互斥、占有且等待、不可抢占、循环等待四个条件同时满足才会死锁', 2, '操作系统', '死锁', NULL, (SELECT id FROM users WHERE username='teacher3'), 1),
(3, 'SQL的SELECT语句属于DDL', NULL, JSON_QUOTE('F'), 'SELECT属于DQL(数据查询语言)，DDL是数据定义语言', 1, '数据库原理', 'SQL分类', NULL, (SELECT id FROM users WHERE username='teacher1'), 1),
(3, 'IPv6地址长度是128位', NULL, JSON_QUOTE('T'), 'IPv6使用128位地址，IPv4使用32位', 1, '计算机网络', 'IP协议', NULL, (SELECT id FROM users WHERE username='teacher2'), 1),
(3, 'Java中的接口可以有构造方法', NULL, JSON_QUOTE('F'), '接口不能有构造方法，只能有抽象方法和常量', 2, 'Java程序设计', '接口', NULL, (SELECT id FROM users WHERE username='teacher1'), 1);

-- 填空题（type_id=4）
INSERT IGNORE INTO biz_question (type_id, content, options, answer, analysis, difficulty, subject, knowledge_points, file_id, creator_id, status)
VALUES
(4, 'Java中用于创建对象的关键字是____', NULL, JSON_ARRAY('new'), 'new关键字用于创建对象实例', 1, 'Java程序设计', '对象创建', NULL, (SELECT id FROM users WHERE username='teacher1'), 1),
(4, '数组的时间复杂度是O(____)，链表插入的时间复杂度是O(____)', NULL, JSON_ARRAY('1','1'), '数组随机访问O(1)，链表插入O(1)', 2, '数据结构', '时间复杂度', NULL, (SELECT id FROM users WHERE username='teacher2'), 1),
(4, 'OSI模型共有____层', NULL, JSON_ARRAY('7'), 'OSI参考模型有7层', 1, '计算机网络', 'OSI模型', NULL, (SELECT id FROM users WHERE username='teacher2'), 1),
(4, '进程的三种基本状态是就绪、____和阻塞', NULL, JSON_ARRAY('运行'), '进程三态：就绪、运行、阻塞', 2, '操作系统', '进程状态', NULL, (SELECT id FROM users WHERE username='teacher3'), 1),
(4, 'SQL中用于去重的关键字是____', NULL, JSON_ARRAY('DISTINCT'), 'DISTINCT用于去除重复记录', 1, '数据库原理', 'SQL查询', NULL, (SELECT id FROM users WHERE username='teacher1'), 1),
(4, '平衡二叉树的左右子树高度差不超过____', NULL, JSON_ARRAY('1'), 'AVL树要求左右子树高度差不超过1', 2, '数据结构', '平衡二叉树', NULL, (SELECT id FROM users WHERE username='teacher2'), 1);

-- 简答题（type_id=5）
INSERT IGNORE INTO biz_question (type_id, content, options, answer, analysis, difficulty, subject, knowledge_points, file_id, creator_id, status)
VALUES
(5, '简述Java中ArrayList和LinkedList的区别', NULL, JSON_QUOTE('ArrayList基于数组实现，随机访问快O(1)，插入删除慢O(n)；LinkedList基于链表实现，插入删除快O(1)，随机访问慢O(n)'), '考察集合框架的底层实现', 3, 'Java程序设计', '集合框架', NULL, (SELECT id FROM users WHERE username='teacher1'), 1),
(5, '简述快速排序的基本思想', NULL, JSON_QUOTE('选择一个基准元素，将数组分为两部分，小于基准的放左边，大于基准的放右边，然后递归排序左右两部分'), '分治算法的典型应用', 3, '数据结构', '排序算法', NULL, (SELECT id FROM users WHERE username='teacher2'), 1),
(5, '简述TCP三次握手的过程', NULL, JSON_QUOTE('1.客户端发送SYN；2.服务器回复SYN+ACK；3.客户端发送ACK确认，连接建立'), 'TCP连接建立过程', 3, '计算机网络', 'TCP协议', NULL, (SELECT id FROM users WHERE username='teacher2'), 1),
(5, '简述进程调度算法中的时间片轮转算法', NULL, JSON_QUOTE('每个进程分配一个时间片，按FIFO顺序执行，时间片用完则切换到下一个进程，适合分时系统'), '常见的调度算法', 3, '操作系统', '进程调度', NULL, (SELECT id FROM users WHERE username='teacher3'), 1),
(5, '简述数据库索引的优缺点', NULL, JSON_QUOTE('优点：加快查询速度，提高检索效率；缺点：占用存储空间，降低插入、删除、更新的速度'), '索引的权衡', 3, '数据库原理', '索引', NULL, (SELECT id FROM users WHERE username='teacher1'), 1),
(5, '简述面向对象的三大特性', NULL, JSON_QUOTE('封装：隐藏内部实现细节；继承：代码复用和扩展；多态：同一接口不同实现'), 'OOP核心概念', 2, 'Java程序设计', '面向对象', NULL, (SELECT id FROM users WHERE username='teacher1'), 1);

-- ==========================================
-- 第二部分: 添加更多试卷
-- ==========================================

INSERT IGNORE INTO biz_paper (name, subject, total_score, pass_score, status, creator_id)
VALUES
('Java程序设计期末考试A卷','Java程序设计',100,60,1,(SELECT id FROM users WHERE username='teacher1')),
('Java程序设计期末考试B卷','Java程序设计',100,60,1,(SELECT id FROM users WHERE username='teacher1')),
('数据结构与算法综合测试','数据结构',100,60,1,(SELECT id FROM users WHERE username='teacher2')),
('计算机网络基础测试','计算机网络',100,60,1,(SELECT id FROM users WHERE username='teacher2')),
('操作系统原理考试','操作系统',100,60,1,(SELECT id FROM users WHERE username='teacher3')),
('数据库系统综合考试','数据库原理',100,60,1,(SELECT id FROM users WHERE username='teacher1'));

-- ==========================================
-- 第三部分: 关联试卷和题目
-- ==========================================

-- Java程序设计期末考试A卷（5道单选，2道多选，2道判断，1道填空，1道简答）
INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
SELECT (SELECT id FROM biz_paper WHERE name='Java程序设计期末考试A卷'), id, 4, 
  ROW_NUMBER() OVER (ORDER BY id)
FROM biz_question 
WHERE type_id=1 AND subject='Java程序设计' AND status=1
LIMIT 5;

INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
SELECT (SELECT id FROM biz_paper WHERE name='Java程序设计期末考试A卷'), id, 10, 
  5 + ROW_NUMBER() OVER (ORDER BY id)
FROM biz_question 
WHERE type_id=2 AND subject='Java程序设计' AND status=1
LIMIT 2;

INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
SELECT (SELECT id FROM biz_paper WHERE name='Java程序设计期末考试A卷'), id, 5, 
  7 + ROW_NUMBER() OVER (ORDER BY id)
FROM biz_question 
WHERE type_id=3 AND subject='Java程序设计' AND status=1
LIMIT 2;

INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
SELECT (SELECT id FROM biz_paper WHERE name='Java程序设计期末考试A卷'), id, 6, 
  9 + ROW_NUMBER() OVER (ORDER BY id)
FROM biz_question 
WHERE type_id=4 AND subject='Java程序设计' AND status=1
LIMIT 1;

INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
SELECT (SELECT id FROM biz_paper WHERE name='Java程序设计期末考试A卷'), id, 20, 
  10 + ROW_NUMBER() OVER (ORDER BY id)
FROM biz_question 
WHERE type_id=5 AND subject='Java程序设计' AND status=1
LIMIT 1;

-- 数据结构与算法综合测试
INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
SELECT (SELECT id FROM biz_paper WHERE name='数据结构与算法综合测试'), id, 5, 
  ROW_NUMBER() OVER (ORDER BY id)
FROM biz_question 
WHERE type_id=1 AND subject='数据结构' AND status=1
LIMIT 4;

INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
SELECT (SELECT id FROM biz_paper WHERE name='数据结构与算法综合测试'), id, 10, 
  4 + ROW_NUMBER() OVER (ORDER BY id)
FROM biz_question 
WHERE type_id=2 AND subject='数据结构' AND status=1
LIMIT 2;

INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
SELECT (SELECT id FROM biz_paper WHERE name='数据结构与算法综合测试'), id, 5, 
  6 + ROW_NUMBER() OVER (ORDER BY id)
FROM biz_question 
WHERE type_id=3 AND subject='数据结构' AND status=1
LIMIT 2;

INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
SELECT (SELECT id FROM biz_paper WHERE name='数据结构与算法综合测试'), id, 10, 
  8 + ROW_NUMBER() OVER (ORDER BY id)
FROM biz_question 
WHERE type_id=4 AND subject='数据结构' AND status=1
LIMIT 2;

INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
SELECT (SELECT id FROM biz_paper WHERE name='数据结构与算法综合测试'), id, 20, 
  10 + ROW_NUMBER() OVER (ORDER BY id)
FROM biz_question 
WHERE type_id=5 AND subject='数据结构' AND status=1
LIMIT 1;

-- 计算机网络基础测试
INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
SELECT (SELECT id FROM biz_paper WHERE name='计算机网络基础测试'), id, 5, 
  ROW_NUMBER() OVER (ORDER BY id)
FROM biz_question 
WHERE type_id=1 AND subject='计算机网络' AND status=1
LIMIT 4;

INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
SELECT (SELECT id FROM biz_paper WHERE name='计算机网络基础测试'), id, 10, 
  4 + ROW_NUMBER() OVER (ORDER BY id)
FROM biz_question 
WHERE type_id=2 AND subject='计算机网络' AND status=1
LIMIT 2;

INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
SELECT (SELECT id FROM biz_paper WHERE name='计算机网络基础测试'), id, 5, 
  6 + ROW_NUMBER() OVER (ORDER BY id)
FROM biz_question 
WHERE type_id=3 AND subject='计算机网络' AND status=1
LIMIT 3;

INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
SELECT (SELECT id FROM biz_paper WHERE name='计算机网络基础测试'), id, 5, 
  9 + ROW_NUMBER() OVER (ORDER BY id)
FROM biz_question 
WHERE type_id=4 AND subject='计算机网络' AND status=1
LIMIT 1;

INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
SELECT (SELECT id FROM biz_paper WHERE name='计算机网络基础测试'), id, 20, 
  10 + ROW_NUMBER() OVER (ORDER BY id)
FROM biz_question 
WHERE type_id=5 AND subject='计算机网络' AND status=1
LIMIT 1;

-- 操作系统原理考试
INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
SELECT (SELECT id FROM biz_paper WHERE name='操作系统原理考试'), id, 5, 
  ROW_NUMBER() OVER (ORDER BY id)
FROM biz_question 
WHERE type_id=1 AND subject='操作系统' AND status=1
LIMIT 3;

INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
SELECT (SELECT id FROM biz_paper WHERE name='操作系统原理考试'), id, 5, 
  3 + ROW_NUMBER() OVER (ORDER BY id)
FROM biz_question 
WHERE type_id=3 AND subject='操作系统' AND status=1
LIMIT 2;

INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
SELECT (SELECT id FROM biz_paper WHERE name='操作系统原理考试'), id, 10, 
  5 + ROW_NUMBER() OVER (ORDER BY id)
FROM biz_question 
WHERE type_id=4 AND subject='操作系统' AND status=1
LIMIT 1;

INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
SELECT (SELECT id FROM biz_paper WHERE name='操作系统原理考试'), id, 25, 
  6 + ROW_NUMBER() OVER (ORDER BY id)
FROM biz_question 
WHERE type_id=5 AND subject='操作系统' AND status=1
LIMIT 2;

-- 数据库系统综合考试
INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
SELECT (SELECT id FROM biz_paper WHERE name='数据库系统综合考试'), id, 5, 
  ROW_NUMBER() OVER (ORDER BY id)
FROM biz_question 
WHERE type_id=1 AND subject='数据库原理' AND status=1
LIMIT 4;

INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
SELECT (SELECT id FROM biz_paper WHERE name='数据库系统综合考试'), id, 10, 
  4 + ROW_NUMBER() OVER (ORDER BY id)
FROM biz_question 
WHERE type_id=2 AND subject='数据库原理' AND status=1
LIMIT 1;

INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
SELECT (SELECT id FROM biz_paper WHERE name='数据库系统综合考试'), id, 5, 
  5 + ROW_NUMBER() OVER (ORDER BY id)
FROM biz_question 
WHERE type_id=3 AND subject='数据库原理' AND status=1
LIMIT 2;

INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
SELECT (SELECT id FROM biz_paper WHERE name='数据库系统综合考试'), id, 10, 
  7 + ROW_NUMBER() OVER (ORDER BY id)
FROM biz_question 
WHERE type_id=4 AND subject='数据库原理' AND status=1
LIMIT 1;

INSERT IGNORE INTO biz_paper_question(paper_id,question_id,score,sort_order)
SELECT (SELECT id FROM biz_paper WHERE name='数据库系统综合考试'), id, 20, 
  8 + ROW_NUMBER() OVER (ORDER BY id)
FROM biz_question 
WHERE type_id=5 AND subject='数据库原理' AND status=1
LIMIT 1;

-- ==========================================
-- 第四部分: 添加考试数据
-- ==========================================

INSERT IGNORE INTO biz_exam (name, paper_id, start_time, end_time, duration, status, creator_id)
VALUES
('Java程序设计2025秋季期末考试',
 (SELECT id FROM biz_paper WHERE name='Java程序设计期末考试A卷'),
 '2025-12-27 09:00:00','2025-12-27 23:59:00',120,1,(SELECT id FROM users WHERE username='teacher1')),
('数据结构与算法阶段测试',
 (SELECT id FROM biz_paper WHERE name='数据结构与算法综合测试'),
 '2025-12-28 14:00:00','2025-12-30 18:00:00',90,1,(SELECT id FROM users WHERE username='teacher2')),
('计算机网络期中考试',
 (SELECT id FROM biz_paper WHERE name='计算机网络基础测试'),
 '2026-01-05 10:00:00','2026-01-05 12:00:00',120,0,(SELECT id FROM users WHERE username='teacher2')),
('操作系统原理期末考试',
 (SELECT id FROM biz_paper WHERE name='操作系统原理考试'),
 '2025-12-29 09:00:00','2025-12-29 23:59:00',150,1,(SELECT id FROM users WHERE username='teacher3'));

-- 分配学生到考试
INSERT IGNORE INTO biz_exam_student (exam_id, user_id)
SELECT e.id, u.id
FROM biz_exam e
CROSS JOIN users u
WHERE e.name IN (
  'Java程序设计2025秋季期末考试',
  '数据结构与算法阶段测试',
  '计算机网络期中考试',
  '操作系统原理期末考试'
)
AND u.user_type = 'student'
AND u.username IN ('student1', 'student2', 'student3');

SELECT '额外数据插入完成！' AS message;
SELECT CONCAT('新增题目数量: ', COUNT(*)) AS question_count FROM biz_question WHERE creator_id IN (SELECT id FROM users WHERE username IN ('teacher1','teacher2','teacher3','teacher4'));
SELECT CONCAT('新增试卷数量: ', COUNT(*)) AS paper_count FROM biz_paper WHERE name LIKE '%期末%' OR name LIKE '%测试%' OR name LIKE '%考试%';
