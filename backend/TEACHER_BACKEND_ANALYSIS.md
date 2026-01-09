# 教师端功能与后端API对比分析报告

## 一、现状总结

### 已实现的后端API

#### 1. 题库管理 (QuestionBankController) ✅
- `GET /api/questions` - 题目列表查询
- `POST /api/questions` - 创建题目
- `PUT /api/questions/{id}` - 更新题目
- `DELETE /api/questions/{id}` - 删除题目
- `POST /api/questions/import` - 批量导入题目

#### 2. 试卷管理 (PaperController) ⚠️ 部分缺失
- `GET /api/papers` - 试卷列表
- `POST /api/papers` - 创建试卷
- `POST /api/papers/auto-generate` - 智能组卷

#### 3. 考试管理 (ExamController) ⚠️ 部分缺失
- `GET /api/exams` - 考试列表
- `POST /api/exams` - 创建考试
- `GET /api/monitor/{examId}` - 监考数据

#### 4. 成绩管理 (ScoreController) ⚠️ 部分缺失
- `GET /api/scores` - 成绩列表
- `GET /api/scores/{examId}/student/{studentId}` - 学生答卷详情
- `POST /api/scores/{examId}/student/{studentId}` - 提交评分
- `GET /api/scores/stats` - 成绩统计

#### 5. 题目审核 (AuditController) ✅
- `GET /api/audit/question/list` - 审核列表
- `PUT /api/audit/question/process` - 审核处理
- `GET /api/audit/question/{id}` - 审核详情

---

## 二、缺失的后端API列表

### 1. 试卷管理模块缺失

#### 1.1 删除试卷
**前端调用**: `deletePaper(id)` in `teacher.js:69`  
**使用场景**: ExamManagement.vue - 试卷管理tab，删除未使用的试卷  
**缺失API**: `DELETE /api/papers/{id}`

#### 1.2 试卷详情
**前端调用**: 预览试卷功能 `handlePreviewPaper(row)`  
**使用场景**: ExamManagement.vue - 查看试卷详细内容  
**缺失API**: `GET /api/papers/{id}`

#### 1.3 更新试卷
**前端调用**: 编辑试卷功能 `handleEditPaper(row)`  
**使用场景**: ExamManagement.vue - 编辑未使用的试卷  
**缺失API**: `PUT /api/papers/{id}`

---

### 2. 考试管理模块缺失

#### 2.1 考试详情
**前端调用**: `getExamDetail(id)` in `teacher.js:100`  
**使用场景**: 
- ScoreManagement.vue - 加载考试信息
- ExamManagement.vue - 查看考试详情
**缺失API**: `GET /api/exams/{id}`

#### 2.2 删除考试
**前端调用**: `deleteExam(id)` in `teacher.js:93`  
**使用场景**: ExamManagement.vue - 删除未开始的考试  
**缺失API**: `DELETE /api/exams/{id}`

#### 2.3 更新考试
**使用场景**: 修改考试时间、参考人员等信息  
**缺失API**: `PUT /api/exams/{id}`

---

### 3. 监考功能模块缺失

#### 3.1 发送警告
**前端调用**: `sendWarning(examId, data)` in `teacher.js:155`  
**使用场景**: ExamManagement.vue - 监考看板，向作弊学生发送警告  
**缺失API**: `POST /api/monitor/{examId}/warning`

**请求参数**:
```json
{
  "studentId": 123,
  "message": "警告内容"
}
```

#### 3.2 强制收卷
**前端调用**: `forceSubmit(examId, data)` in `teacher.js:163`  
**使用场景**: 
- ExamManagement.vue - 监考看板，强制收取学生试卷
- 一键收卷功能
**缺失API**: `POST /api/monitor/{examId}/force-submit`

**请求参数**:
```json
{
  "studentIds": [123, 456, 789]
}
```

#### 3.3 完整监考数据
**前端需求**: 需要更详细的监考数据
**当前API**: `GET /api/monitor/{examId}` 仅返回基本统计
**需要增强**: 返回学生列表、切屏次数、答题进度等

---

### 4. 成绩管理模块缺失

#### 4.1 调整成绩
**前端调用**: `adjustScore(id, data)` in `teacher.js:124`  
**使用场景**: ScoreManagement.vue - 调整学生成绩  
**当前问题**: 前端传的是成绩记录ID，但后端评分API使用的是examId+studentId组合
**建议方案**:
- 方案A: 新增 `PUT /api/scores/{scoreId}` 接口
- 方案B: 修改前端适配现有API `POST /api/scores/{examId}/student/{studentId}`

**推荐方案A** - 新增独立调整接口:
```
PUT /api/scores/{scoreId}
```

**请求参数**:
```json
{
  "newScore": 85,
  "reason": "答案评判有误，给予额外分数"
}
```

#### 4.2 批量发布/撤回成绩
**前端调用**: `batchPublish(publish)` in ScoreManagement.vue:758  
**使用场景**: 成绩管理tab - 批量操作学生成绩的发布状态  
**缺失API**: `POST /api/scores/batch-publish`

**请求参数**:
```json
{
  "scoreIds": [1, 2, 3, 4, 5],
  "published": true
}
```

#### 4.3 导入成绩
**前端调用**: `importScores()` in ScoreManagement.vue:762  
**使用场景**: 批量导入成绩数据  
**缺失API**: `POST /api/scores/import`

#### 4.4 导出成绩单
**前端调用**: `exportResults()` in ScoreManagement.vue:766  
**使用场景**: 导出Excel成绩单  
**缺失API**: `GET /api/scores/export`

---

### 5. 考生管理模块 (完全缺失)

#### 5.1 获取考试的考生列表
**前端调用**: `handleManageStudents(row)` in ExamManagement.vue:657  
**使用场景**: 管理考试的参考学生  
**缺失API**: `GET /api/exams/{examId}/students`

**返回数据**:
```json
{
  "code": 200,
  "message": "获取成功",
  "data": {
    "list": [
      {
        "id": 1,
        "studentId": "2021001",
        "name": "张三",
        "className": "计科1班",
        "status": "normal"
      }
    ],
    "total": 50
  }
}
```

#### 5.2 添加考生
**前端调用**: `handleAddStudent()` in ExamManagement.vue:663  
**使用场景**: 向考试添加学生  
**缺失API**: `POST /api/exams/{examId}/students`

**请求参数**:
```json
{
  "studentIds": [123, 456],
  "classIds": [1, 2]
}
```

#### 5.3 移除考生
**前端调用**: `handleRemoveStudent(row)` in ExamManagement.vue:671  
**使用场景**: 从考试中移除学生  
**缺失API**: `DELETE /api/exams/{examId}/students/{studentId}`

#### 5.4 批量移除考生
**前端调用**: `handleBatchDeleteStudent()` in ExamManagement.vue:680  
**缺失API**: `POST /api/exams/{examId}/students/batch-delete`

**请求参数**:
```json
{
  "studentIds": [123, 456, 789]
}
```

---

### 6. 班级管理模块 (完全缺失)

#### 6.1 获取班级列表
**前端需求**: ScoreManagement.vue 和 ExamManagement.vue 都需要班级选项  
**缺失API**: `GET /api/classes`

**返回数据**:
```json
{
  "code": 200,
  "message": "获取成功",
  "data": {
    "list": [
      {
        "id": 1,
        "name": "计算机科学与技术1班",
        "code": "cs1",
        "grade": "2021",
        "major": "计算机科学与技术",
        "studentCount": 45
      }
    ]
  }
}
```

#### 6.2 获取班级学生
**使用场景**: 添加考生时选择班级的所有学生  
**缺失API**: `GET /api/classes/{classId}/students`

---

### 7. 练题题库审核功能

#### 7.1 练题题库题目审核
**前端调用**: `auditQuestion(id, data)` in `teacher.js:44`  
**使用场景**: PracticeBank.vue - 审核学生上传的练习题目  
**当前状态**: 
- 前端有完整的审核UI (待审核tab、通过/驳回按钮)
- API调用路径: `POST /questions/{id}/audit`
- **但这个API在后端不存在**

**缺失API**: `POST /api/questions/{id}/audit`

**请求参数**:
```json
{
  "status": "approved",  // approved | rejected
  "comment": "审核意见"
}
```

**说明**: 这个功能与AuditController中的题目审核是重复的，建议：
- 方案A: 前端统一使用 `/api/audit/question/process` 接口
- 方案B: 保留简化版的审核接口 `POST /api/questions/{id}/audit`

---

### 8. 学科/科目管理 (可选)

#### 8.1 获取科目列表
**使用场景**: 
- QuestionBank.vue - 筛选科目
- ExamManagement.vue - 选择考试科目
**建议API**: `GET /api/subjects`

**返回数据**:
```json
{
  "code": 200,
  "data": [
    {"id": 1, "name": "Java程序设计", "code": "java"},
    {"id": 2, "name": "数据结构", "code": "ds"},
    {"id": 3, "name": "计算机网络", "code": "network"}
  ]
}
```

---

## 三、优先级评估

### 🔴 高优先级 (核心功能，必须实现)

1. **考试详情** - `GET /api/exams/{id}`
2. **删除考试** - `DELETE /api/exams/{id}`
3. **发送警告** - `POST /api/monitor/{examId}/warning`
4. **强制收卷** - `POST /api/monitor/{examId}/force-submit`
5. **调整成绩** - `PUT /api/scores/{scoreId}` 或调整现有接口
6. **考生管理** - 获取、添加、移除考生的全套API

### 🟡 中优先级 (影响用户体验)

7. **试卷详情** - `GET /api/papers/{id}`
8. **删除试卷** - `DELETE /api/papers/{id}`
9. **班级列表** - `GET /api/classes`
10. **导出成绩** - `GET /api/scores/export`
11. **完整监考数据** - 增强 `GET /api/monitor/{examId}`

### 🟢 低优先级 (锦上添花)

12. **更新试卷** - `PUT /api/papers/{id}`
13. **更新考试** - `PUT /api/exams/{id}`
14. **批量发布成绩** - `POST /api/scores/batch-publish`
15. **导入成绩** - `POST /api/scores/import`
16. **科目管理** - `GET /api/subjects`

---

## 四、详细API设计方案

### 4.1 考试管理增强

#### API 1: 获取考试详情
```
GET /api/exams/{id}
```

**响应示例**:
```json
{
  "code": 200,
  "message": "获取成功",
  "data": {
    "id": 1,
    "name": "Java期末考试",
    "subject": "Java",
    "paperId": 10,
    "paperName": "Java综合试卷",
    "startTime": "2024-01-15 14:00:00",
    "endTime": "2024-01-15 16:00:00",
    "duration": 120,
    "totalScore": 100,
    "status": "upcoming",
    "studentCount": 45,
    "submittedCount": 0,
    "gradedCount": 0,
    "creatorId": 5,
    "creatorName": "李老师",
    "createTime": "2024-01-10 10:00:00"
  }
}
```

#### API 2: 删除考试
```
DELETE /api/exams/{id}
```

**业务规则**:
- 只能删除未开始的考试
- 已有学生参加的考试不能删除

**响应示例**:
```json
{
  "code": 200,
  "message": "删除成功"
}
```

**错误响应**:
```json
{
  "code": 400,
  "message": "考试已开始，无法删除"
}
```

#### API 3: 更新考试
```
PUT /api/exams/{id}
```

**请求参数**:
```json
{
  "name": "Java期末考试(修改)",
  "startTime": "2024-01-16 14:00:00",
  "duration": 150,
  "description": "考试说明"
}
```

---

### 4.2 监考功能完善

#### API 4: 获取监考数据 (增强版)
```
GET /api/monitor/{examId}
```

**响应示例**:
```json
{
  "code": 200,
  "message": "获取成功",
  "data": {
    "examId": 1,
    "examName": "Java期末考试",
    "total": 45,
    "online": 42,
    "submitted": 3,
    "abnormal": 5,
    "students": [
      {
        "id": 1,
        "studentId": "2021001",
        "name": "张三",
        "className": "计科1班",
        "status": "online",
        "progress": 65,
        "switchCount": 8,
        "lastActiveTime": "2024-01-15 15:23:45",
        "submitTime": null,
        "ipAddress": "192.168.1.100"
      },
      {
        "id": 2,
        "studentId": "2021002",
        "name": "李四",
        "className": "计科1班",
        "status": "submitted",
        "progress": 100,
        "switchCount": 2,
        "lastActiveTime": "2024-01-15 15:30:00",
        "submitTime": "2024-01-15 15:30:00",
        "ipAddress": "192.168.1.101"
      }
    ]
  }
}
```

#### API 5: 发送警告
```
POST /api/monitor/{examId}/warning
```

**请求参数**:
```json
{
  "studentId": 1,
  "message": "检测到多次切屏行为，请专注考试！",
  "type": "switch_screen"
}
```

**响应示例**:
```json
{
  "code": 200,
  "message": "警告已发送",
  "data": {
    "warningId": 123,
    "sentTime": "2024-01-15 15:25:00"
  }
}
```

#### API 6: 强制收卷
```
POST /api/monitor/{examId}/force-submit
```

**请求参数**:
```json
{
  "studentIds": [1, 2, 3],
  "reason": "考试时间已到"
}
```

**响应示例**:
```json
{
  "code": 200,
  "message": "强制收卷成功",
  "data": {
    "successCount": 3,
    "failedCount": 0,
    "details": [
      {"studentId": 1, "success": true},
      {"studentId": 2, "success": true},
      {"studentId": 3, "success": true}
    ]
  }
}
```

---

### 4.3 成绩管理增强

#### API 7: 调整成绩
```
PUT /api/scores/{scoreId}
```

**请求参数**:
```json
{
  "newScore": 85,
  "reason": "答案评判有误，额外给分",
  "adjustItems": [
    {
      "questionId": 5,
      "originalScore": 8,
      "newScore": 10,
      "reason": "答案部分正确，应给满分"
    }
  ]
}
```

**响应示例**:
```json
{
  "code": 200,
  "message": "调整成功",
  "data": {
    "scoreId": 123,
    "originalScore": 83,
    "newScore": 85,
    "adjustTime": "2024-01-16 10:00:00"
  }
}
```

#### API 8: 批量发布成绩
```
POST /api/scores/batch-publish
```

**请求参数**:
```json
{
  "examId": 1,
  "scoreIds": [1, 2, 3, 4, 5],
  "published": true
}
```

#### API 9: 导出成绩单
```
GET /api/scores/export?examId={examId}&format=excel
```

**响应**: Excel文件流

---

### 4.4 考生管理

#### API 10: 获取考试的考生列表
```
GET /api/exams/{examId}/students?page=1&size=10&keyword=张三
```

**响应示例**:
```json
{
  "code": 200,
  "data": {
    "list": [
      {
        "id": 1,
        "userId": 101,
        "studentId": "2021001",
        "name": "张三",
        "className": "计科1班",
        "classId": 1,
        "status": "normal",
        "addTime": "2024-01-10 10:00:00"
      }
    ],
    "total": 45
  }
}
```

#### API 11: 添加考生
```
POST /api/exams/{examId}/students
```

**请求参数**:
```json
{
  "studentIds": [101, 102, 103],
  "classIds": [1, 2]
}
```

**说明**: studentIds 和 classIds 二选一，如果提供 classIds，则添加整个班级的所有学生

#### API 12: 移除考生
```
DELETE /api/exams/{examId}/students/{studentId}
```

#### API 13: 批量移除考生
```
POST /api/exams/{examId}/students/batch-delete
```

**请求参数**:
```json
{
  "studentIds": [101, 102, 103]
}
```

---

### 4.5 试卷管理增强

#### API 14: 获取试卷详情
```
GET /api/papers/{id}
```

**响应示例**:
```json
{
  "code": 200,
  "data": {
    "id": 10,
    "name": "Java综合试卷",
    "subject": "Java",
    "totalScore": 100,
    "passScore": 60,
    "questionCount": 30,
    "questions": [
      {
        "questionId": 1,
        "questionType": "single_choice",
        "content": "下列哪个是Java关键字？",
        "score": 2,
        "order": 1
      }
    ],
    "status": "draft",
    "createTime": "2024-01-10 10:00:00",
    "creatorName": "李老师"
  }
}
```

#### API 15: 删除试卷
```
DELETE /api/papers/{id}
```

**业务规则**:
- 只能删除未被使用的试卷
- 已发布考试的试卷不能删除

#### API 16: 更新试卷
```
PUT /api/papers/{id}
```

**请求参数**:
```json
{
  "name": "Java综合试卷(修改版)",
  "questions": [
    {"id": 1, "score": 3},
    {"id": 2, "score": 5}
  ],
  "passScore": 65
}
```

---

### 4.6 班级管理

#### API 17: 获取班级列表
```
GET /api/classes?page=1&size=20&keyword=计科
```

**响应示例**:
```json
{
  "code": 200,
  "data": {
    "list": [
      {
        "id": 1,
        "name": "计算机科学与技术1班",
        "code": "cs1",
        "grade": "2021",
        "major": "计算机科学与技术",
        "studentCount": 45,
        "advisorName": "张老师"
      }
    ],
    "total": 8
  }
}
```

#### API 18: 获取班级学生
```
GET /api/classes/{classId}/students
```

---

### 4.7 题目审核简化接口

#### API 19: 审核单个题目
```
POST /api/questions/{id}/audit
```

**请求参数**:
```json
{
  "status": "approved",
  "comment": "题目质量良好，通过审核"
}
```

**说明**: 这是一个简化版本，实际可以调用 AuditController 的批量处理接口

---

### 4.8 科目管理

#### API 20: 获取科目列表
```
GET /api/subjects
```

**响应示例**:
```json
{
  "code": 200,
  "data": [
    {"id": 1, "name": "Java程序设计", "code": "java"},
    {"id": 2, "name": "数据结构", "code": "ds"},
    {"id": 3, "name": "计算机网络", "code": "network"},
    {"id": 4, "name": "操作系统", "code": "os"}
  ]
}
```

---

## 五、数据库设计建议

### 5.1 考生关联表
```sql
CREATE TABLE exam_student (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  exam_id BIGINT NOT NULL,
  user_id BIGINT NOT NULL,
  status VARCHAR(20) DEFAULT 'normal',
  add_time DATETIME DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_exam (exam_id),
  INDEX idx_user (user_id),
  UNIQUE KEY uk_exam_user (exam_id, user_id)
);
```

### 5.2 班级表
```sql
CREATE TABLE class (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  code VARCHAR(50),
  grade VARCHAR(10),
  major VARCHAR(100),
  advisor_id BIGINT,
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

### 5.3 学生班级关联表
```sql
CREATE TABLE class_student (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  class_id BIGINT NOT NULL,
  user_id BIGINT NOT NULL,
  join_time DATETIME DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_class_user (class_id, user_id)
);
```

### 5.4 监考警告记录表
```sql
CREATE TABLE monitor_warning (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  exam_id BIGINT NOT NULL,
  student_id BIGINT NOT NULL,
  message TEXT,
  type VARCHAR(50),
  teacher_id BIGINT,
  send_time DATETIME DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_exam_student (exam_id, student_id)
);
```

### 5.5 成绩调整记录表
```sql
CREATE TABLE score_adjustment (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  score_id BIGINT NOT NULL,
  original_score DECIMAL(5,2),
  new_score DECIMAL(5,2),
  reason TEXT,
  adjuster_id BIGINT,
  adjust_time DATETIME DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_score (score_id)
);
```

### 5.6 科目表
```sql
CREATE TABLE subject (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  code VARCHAR(50) UNIQUE,
  description TEXT,
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

---

## 六、实施建议

### 阶段一：核心功能补全 (1-2周)
1. 实现考试详情和删除接口
2. 实现监考功能的警告和强制收卷
3. 实现基础的考生管理功能
4. 调整成绩接口

### 阶段二：体验优化 (1周)
5. 实现试卷详情和删除
6. 实现班级管理接口
7. 完善监考数据接口

### 阶段三：高级功能 (1-2周)
8. 导出成绩功能
9. 批量操作功能
10. 科目管理系统

---

## 七、总结

### 统计
- ✅ **已实现**: 15个API
- ❌ **缺失**: 20个API
- 📊 **完成度**: 约43%

### 建议
1. **优先实现高优先级API**，保证核心功能可用
2. **数据库设计先行**，避免后期大量重构
3. **接口设计统一**，遵循RESTful规范
4. **增加接口文档**，方便前后端协作
5. **错误处理规范**，提供友好的错误提示


