USE chaoxing;

INSERT INTO biz_exam_question(type_id,content,options,answer,analysis,difficulty,subject,knowledge_points,file_id,creator_id,status,create_time)
VALUES
(1,'考试专用：Java中String类的特性是？',
 JSON_ARRAY(
   JSON_OBJECT('key','A','value','可变'),
   JSON_OBJECT('key','B','value','不可变'),
   JSON_OBJECT('key','C','value','线程不安全')
 ),
 JSON_ARRAY('B'),'String类是不可变的',1,'Java程序设计','String类',NULL,(SELECT id FROM users WHERE username='teacher1'),1,NOW()),
(2,'考试专用：下列哪些属于排序算法？',
 JSON_ARRAY(
   JSON_OBJECT('key','A','value','冒泡排序'),
   JSON_OBJECT('key','B','value','二分查找'),
   JSON_OBJECT('key','C','value','快速排序'),
   JSON_OBJECT('key','D','value','哈希查找')
 ),
 JSON_ARRAY('A','C'),'排序算法包括冒泡和快速排序',2,'数据结构','排序算法',NULL,(SELECT id FROM users WHERE username='teacher2'),1,NOW()),
(3,'考试专用：TCP是面向连接的协议，对吗？',
 NULL, JSON_ARRAY(TRUE),'TCP是面向连接的协议',1,'计算机网络','TCP',NULL,(SELECT id FROM users WHERE username='teacher3'),1,NOW()),
(4,'考试专用：操作系统的五大功能是：进程管理、____、____、文件管理、作业管理',
 NULL, JSON_ARRAY('内存管理','设备管理'),NULL,2,'操作系统','操作系统功能',NULL,(SELECT id FROM users WHERE username='teacher4'),1,NOW()),
(5,'考试专用：简述面向对象编程的三大特性',
 NULL, JSON_ARRAY('封装、继承、多态'),NULL,3,'软件工程','面向对象',NULL,(SELECT id FROM users WHERE username='teacher5'),1,NOW());
