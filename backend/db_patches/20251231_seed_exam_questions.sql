USE chaoxing;

INSERT INTO biz_exam_question(type_id,content,options,answer,analysis,difficulty,subject,knowledge_points,file_id,creator_id,status,create_time)
VALUES
(1,'Java中Runnable接口的方法是？','[{\"key\":\"A\",\"value\":\"start\"},{\"key\":\"B\",\"value\":\"run\"},{\"key\":\"C\",\"value\":\"stop\"}]','[\"B\"]','Runnable只有一个run方法',2,'Java程序设计','线程基础',NULL,(SELECT id FROM users WHERE username='teacher1'),1,NOW()),
(2,'下列哪些属于集合框架接口？','[{\"key\":\"A\",\"value\":\"List\"},{\"key\":\"B\",\"value\":\"Map\"},{\"key\":\"C\",\"value\":\"Queue\"},{\"key\":\"D\",\"value\":\"Thread\"}]','[\"A\",\"B\",\"C\"]','Java集合框架',3,'Java程序设计','集合框架',NULL,(SELECT id FROM users WHERE username='teacher2'),1,NOW()),
(3,'JVM的垃圾回收机制会自动释放无引用对象，对吗？',NULL,'true','GC会回收不可达对象',2,'Java程序设计','JVM/GC',NULL,(SELECT id FROM users WHERE username='teacher3'),1,NOW()),
(4,'SQL中用于分组统计的关键字是____',NULL,'[\"GROUP BY\"]','分组统计',3,'数据库原理','分组与聚合',NULL,(SELECT id FROM users WHERE username='teacher4'),1,NOW()),
(5,'简述事务隔离级别的四种类型',NULL,'\"读未提交、读已提交、可重复读、串行化\"','隔离级别说明',4,'数据库原理','事务/隔离级别',NULL,(SELECT id FROM users WHERE username='teacher5'),1,NOW()),
(1,'OSI七层模型中传输层提供的核心服务是？','[{\"key\":\"A\",\"value\":\"路由选择\"},{\"key\":\"B\",\"value\":\"端到端传输\"},{\"key\":\"C\",\"value\":\"数据链路控制\"}]','[\"B\"]','传输层提供端到端传输',2,'计算机网络','网络分层',NULL,(SELECT id FROM users WHERE username='teacher1'),1,NOW()),
(2,'TCP拥塞控制的算法包括？','[{\"key\":\"A\",\"value\":\"慢启动\"},{\"key\":\"B\",\"value\":\"拥塞避免\"},{\"key\":\"C\",\"value\":\"快速重传\"},{\"key\":\"D\",\"value\":\"快速恢复\"}]','[\"A\",\"B\",\"C\",\"D\"]','拥塞控制四要素',4,'计算机网络','拥塞控制',NULL,(SELECT id FROM users WHERE username='teacher2'),1,NOW()),
(3,'操作系统的进程与线程是同一个概念，对吗？',NULL,'false','进程与线程不同',1,'操作系统','进程/线程',NULL,(SELECT id FROM users WHERE username='teacher3'),1,NOW()),
(4,'分页置换算法中优先淘汰最近最少使用的是____算法',NULL,'[\"LRU\"]','LRU置换',3,'操作系统','内存管理',NULL,(SELECT id FROM users WHERE username='teacher4'),1,NOW()),
(5,'简述临界区与互斥的关系',NULL,'\"临界区需要互斥访问以避免竞态\"','并发互斥',3,'操作系统','并发/互斥',NULL,(SELECT id FROM users WHERE username='teacher5'),1,NOW());
