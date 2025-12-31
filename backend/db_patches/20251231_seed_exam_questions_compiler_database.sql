SET NAMES utf8mb4;
USE chaoxing;

INSERT IGNORE INTO biz_question_type(type_id,type_name,type_code,answer_json,config_json,is_active,create_time,update_time)
VALUES (6,'编程题','PROGRAM',CAST('"文本"' AS JSON),CAST('{"is_objective":false,"requires_file_id":true}' AS JSON),1,NOW(),NOW());

INSERT INTO biz_exam_question(type_id,content,options,answer,analysis,difficulty,subject,knowledge_points,file_id,creator_id,status,create_time)
VALUES
(1,'词法分析的主要任务是？','[{\"key\":\"A\",\"value\":\"语义检查\"},{\"key\":\"B\",\"value\":\"将字符流转换为记号(Token)\"},{\"key\":\"C\",\"value\":\"生成目标代码\"},{\"key\":\"D\",\"value\":\"寄存器分配\"}]','[\"B\"]','词法分析将源程序的字符序列切分成记号序列供语法分析使用',2,'编译原理','词法分析',NULL,(SELECT id FROM users WHERE username='teacher1'),1,NOW()),
(1,'LR(1)分析法属于哪一类语法分析方法？','[{\"key\":\"A\",\"value\":\"自顶向下递归下降\"},{\"key\":\"B\",\"value\":\"预测分析\"},{\"key\":\"C\",\"value\":\"自底向上移进-归约\"},{\"key\":\"D\",\"value\":\"图搜索\"}]','[\"C\"]','LR家族是自底向上的移进-归约方法',3,'编译原理','语法分析',NULL,(SELECT id FROM users WHERE username='teacher2'),1,NOW()),
(2,'以下哪些属于常见的语法分析方法？','[{\"key\":\"A\",\"value\":\"LL(1)\"},{\"key\":\"B\",\"value\":\"LR(1)\"},{\"key\":\"C\",\"value\":\"SLR\"},{\"key\":\"D\",\"value\":\"DFA\"}]','[\"A\",\"B\",\"C\"]','LL与LR系列为语法分析方法，DFA用于词法分析',3,'编译原理','语法分析',NULL,(SELECT id FROM users WHERE username='teacher3'),1,NOW()),
(2,'中间代码常见形式有哪些？','[{\"key\":\"A\",\"value\":\"三址码\"},{\"key\":\"B\",\"value\":\"抽象语法树(AST)\"},{\"key\":\"C\",\"value\":\"四元式\"},{\"key\":\"D\",\"value\":\"词法单元(Token)\"}]','[\"A\",\"C\"]','三址码/四元式常用于中间表示，Token用于词法',2,'编译原理','中间代码',NULL,(SELECT id FROM users WHERE username='teacher4'),1,NOW()),
(3,'上下文无关文法能被有限自动机完全识别',NULL,'false','有限自动机只能识别正规语言，CFG需要下推自动机',3,'编译原理','形式语言与自动机',NULL,(SELECT id FROM users WHERE username='teacher5'),1,NOW()),
(3,'语义分析阶段通常会进行类型检查',NULL,'true','类型检查与作用域检查属于语义分析常见任务',2,'编译原理','语义分析',NULL,(SELECT id FROM users WHERE username='teacher1'),1,NOW()),
(4,'语法制导翻译中常用的中间代码是____',NULL,'[\"三址码\"]','三址码便于优化和生成目标代码',2,'编译原理','中间代码',NULL,(SELECT id FROM users WHERE username='teacher2'),1,NOW()),
(4,'寄存器分配常用的图着色方法基于____图',NULL,'[\"干涉\"]','寄存器分配使用干涉图着色',4,'编译原理','代码优化/寄存器分配',NULL,(SELECT id FROM users WHERE username='teacher3'),1,NOW()),
(5,'简述编译器前端与后端的主要职责',NULL,JSON_QUOTE('前端：词法/语法/语义分析与中间代码生成；后端：优化与目标代码生成'), '概念区分',2,'编译原理','编译器结构',NULL,(SELECT id FROM users WHERE username='teacher4'),1,NOW()),
(5,'简要说明静态单赋值(SSA)形式的特点及优势',NULL,JSON_QUOTE('SSA将每个变量在文本上只赋值一次，显式Phi函数，便于数据流分析与优化'), 'SSA优势',4,'编译原理','代码优化/SSA',NULL,(SELECT id FROM users WHERE username='teacher5'),1,NOW()),
(6,'实现一个递归下降解析器，支持加减乘除与括号，输入表达式输出计算结果',NULL,JSON_QUOTE('要求：给出核心解析与求值函数设计思路与关键伪代码/源码；可上传代码文件'), '表达式解析与求值',3,'编译原理','语法分析/表达式求值','prog-compiler-parser-basic',(SELECT id FROM users WHERE username='teacher1'),1,NOW()),
(6,'编写一个词法分析器，识别标识符、整数常量与基本运算符，输出Token序列',NULL,JSON_QUOTE('要求：说明正则/自动机设计与实现细节；可上传代码文件'), '词法分析实践',3,'编译原理','词法分析/DFA','prog-compiler-lexer-basic',(SELECT id FROM users WHERE username='teacher2'),1,NOW());

INSERT INTO biz_exam_question(type_id,content,options,answer,analysis,difficulty,subject,knowledge_points,file_id,creator_id,status,create_time)
VALUES
(1,'第三范式(3NF)主要消除哪类依赖？','[{\"key\":\"A\",\"value\":\"部分依赖\"},{\"key\":\"B\",\"value\":\"传递依赖\"},{\"key\":\"C\",\"value\":\"多值依赖\"},{\"key\":\"D\",\"value\":\"函数依赖\"}]','[\"B\"]','3NF在满足2NF基础上消除传递依赖',2,'数据库原理','范式理论',NULL,(SELECT id FROM users WHERE username='teacher1'),1,NOW()),
(1,'B+树索引的非叶子节点存储的是？','[{\"key\":\"A\",\"value\":\"完整数据行\"},{\"key\":\"B\",\"value\":\"键值与子指针\"},{\"key\":\"C\",\"value\":\"哈希桶\"},{\"key\":\"D\",\"value\":\"页校验码\"}]','[\"B\"]','B+树非叶节点保存键与指针，叶子链表便于范围查询',3,'数据库原理','索引/B+树',NULL,(SELECT id FROM users WHERE username='teacher2'),1,NOW()),
(2,'下列哪些属于事务的隔离级别？','[{\"key\":\"A\",\"value\":\"读未提交\"},{\"key\":\"B\",\"value\":\"读已提交\"},{\"key\":\"C\",\"value\":\"可重复读\"},{\"key\":\"D\",\"value\":\"串行化\"}]','[\"A\",\"B\",\"C\",\"D\"]','四级隔离避免不同并发异常',2,'数据库原理','事务/隔离级别',NULL,(SELECT id FROM users WHERE username='teacher3'),1,NOW()),
(2,'下列哪些属于常见的数据库范式？','[{\"key\":\"A\",\"value\":\"1NF\"},{\"key\":\"B\",\"value\":\"2NF\"},{\"key\":\"C\",\"value\":\"3NF\"},{\"key\":\"D\",\"value\":\"BCNF\"}]','[\"A\",\"B\",\"C\",\"D\"]','1NF/2NF/3NF/BCNF',2,'数据库原理','范式理论',NULL,(SELECT id FROM users WHERE username='teacher4'),1,NOW()),
(3,'创建索引通常会提升插入性能',NULL,'false','索引会带来写入开销，插入性能通常下降',2,'数据库原理','索引',NULL,(SELECT id FROM users WHERE username='teacher5'),1,NOW()),
(3,'可重复读级别可以避免不可重复读问题',NULL,'true','RR避免不可重复读，但可能存在幻读',3,'数据库原理','事务/隔离级别',NULL,(SELECT id FROM users WHERE username='teacher1'),1,NOW()),
(4,'关系代数中选择操作使用的符号是____',NULL,'[\"σ\"]','σ表示选择(筛选)操作',2,'数据库原理','关系代数',NULL,(SELECT id FROM users WHERE username='teacher2'),1,NOW()),
(4,'SQL中实现分组后的筛选应使用____子句',NULL,'[\"HAVING\"]','HAVING用于分组结果的条件过滤',2,'数据库原理','SQL/分组',NULL,(SELECT id FROM users WHERE username='teacher3'),1,NOW()),
(5,'简述数据库事务的ACID特性',NULL,JSON_QUOTE('原子性：要么全做要么全不做；一致性：状态转换合法；隔离性：并发互不干扰；持久性：结果持久保存'), '事务基础',2,'数据库原理','事务/ACID',NULL,(SELECT id FROM users WHERE username='teacher4'),1,NOW()),
(5,'简述B+树在范围查询中的优势',NULL,JSON_QUOTE('叶子节点链表有序，支持高效范围扫描；非叶子节点降低树高'), '索引优势',2,'数据库原理','索引/B+树',NULL,(SELECT id FROM users WHERE username='teacher5'),1,NOW()),
(6,'编写SQL：创建students表(包含id,name,age)并插入3条示例数据',NULL,JSON_QUOTE('要求：给出CREATE TABLE与INSERT语句；可上传SQL文件'), 'SQL基础实践',1,'数据库原理','SQL/DDL/DML','prog-db-sql-basics',(SELECT id FROM users WHERE username='teacher1'),1,NOW()),
(6,'实现一个简单的JDBC程序：连接数据库查询students表并打印结果',NULL,JSON_QUOTE('要求：给出核心代码与注意点(驱动、连接串、资源释放)；可上传源码文件'), '应用层访问',2,'数据库原理','JDBC/查询','prog-db-jdbc-basic',(SELECT id FROM users WHERE username='teacher2'),1,NOW());
