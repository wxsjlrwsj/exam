USE chaoxing;

INSERT INTO biz_exam_question(type_id,content,options,answer,analysis,difficulty,subject,knowledge_points,file_id,creator_id,status,create_time)
VALUES
(1,'Exam-only: What is String property in Java?',
 JSON_ARRAY(
   JSON_OBJECT('key','A','value','mutable'),
   JSON_OBJECT('key','B','value','immutable'),
   JSON_OBJECT('key','C','value','not thread-safe')
 ),
 JSON_ARRAY('B'),'String is immutable',1,'Java Programming','String',NULL,(SELECT id FROM users WHERE username='teacher1'),1,NOW()),
(2,'Exam-only: Which are sorting algorithms?',
 JSON_ARRAY(
   JSON_OBJECT('key','A','value','Bubble sort'),
   JSON_OBJECT('key','B','value','Binary search'),
   JSON_OBJECT('key','C','value','Quick sort'),
   JSON_OBJECT('key','D','value','Hash search')
 ),
 JSON_ARRAY('A','C'),'Bubble and Quick are sorting',2,'Data Structures','Sorting',NULL,(SELECT id FROM users WHERE username='teacher2'),1,NOW()),
(3,'Exam-only: TCP is connection-oriented, right?',
 NULL, JSON_ARRAY(TRUE),'TCP is connection-oriented',1,'Computer Networks','TCP',NULL,(SELECT id FROM users WHERE username='teacher3'),1,NOW()),
(4,'Exam-only: OS five functions include process mgmt, ____, ____, file mgmt, job mgmt',
 NULL, JSON_ARRAY('memory mgmt','device mgmt'),NULL,2,'Operating Systems','OS functions',NULL,(SELECT id FROM users WHERE username='teacher4'),1,NOW()),
(5,'Exam-only: Briefly describe OOP three features',
 NULL, JSON_ARRAY('encapsulation, inheritance, polymorphism'),NULL,3,'Software Engineering','OOP',NULL,(SELECT id FROM users WHERE username='teacher5'),1,NOW());
