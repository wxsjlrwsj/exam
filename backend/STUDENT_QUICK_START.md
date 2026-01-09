# 学生端后端快速开始指南

## 🚀 5分钟快速部署

### 步骤1: 数据库迁移（1分钟）

```bash
# 连接到MySQL数据库
mysql -u root -p

# 选择数据库
USE chaoxing_exam;

# 执行迁移脚本
SOURCE /path/to/exam/backend/db_migration_student.sql;

# 验证表创建
SHOW TABLES LIKE 'biz_student%';
SHOW TABLES LIKE 'biz_collection%';
SHOW TABLES LIKE 'biz_quiz%';
```

**预期输出**:
```
+----------------------------------+
| Tables_in_chaoxing_exam          |
+----------------------------------+
| biz_collection_question          |
| biz_exam_monitor_event           |
| biz_face_verification            |
| biz_quiz_answer                  |
| biz_student_collection           |
| biz_student_error                |
| biz_student_quiz                 |
+----------------------------------+
```

---

### 步骤2: 编译项目（2分钟）

```bash
cd exam/backend

# 清理并编译
mvn clean package -DskipTests

# 或者如果已经编译过
mvn compile
```

**预期输出**:
```
[INFO] BUILD SUCCESS
[INFO] Total time: 45.123 s
```

---

### 步骤3: 启动服务（1分钟）

```bash
# 使用学生端配置启动
java -jar target/backend.jar --spring.profiles.active=student

# 或者使用完整配置（包含所有端）
java -jar target/backend.jar
```

**预期输出**:
```
  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/
 :: Spring Boot ::                (v3.x.x)

...
Started ChaoxingSystemApplication in 12.345 seconds
```

---

### 步骤4: 验证API（1分钟）

#### 4.1 健康检查
```bash
curl http://localhost:8083/actuator/health
```

#### 4.2 测试学生端API（需要先登录获取token）

**登录获取Token**:
```bash
curl -X POST http://localhost:8083/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "student01",
    "password": "password123"
  }'
```

**使用Token访问API**:
```bash
# 获取考试列表
curl -X GET "http://localhost:8083/api/student/exams" \
  -H "Authorization: Bearer {your_token_here}"

# 获取题集列表
curl -X GET "http://localhost:8083/api/student/collections" \
  -H "Authorization: Bearer {your_token_here}"

# 获取错题统计
curl -X GET "http://localhost:8083/api/student/errors/stats" \
  -H "Authorization: Bearer {your_token_here}"
```

---

## 📋 常见问题

### Q1: 数据库连接失败？
**A**: 检查 `application.yml` 中的数据库配置：
```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/chaoxing_exam
    username: root
    password: your_password
```

### Q2: 端口被占用？
**A**: 修改 `application.yml` 中的端口：
```yaml
server:
  port: 8083  # 改为其他端口，如 8084
```

### Q3: 找不到某个Mapper？
**A**: 确保在Application类中配置了MapperScan：
```java
@MapperScan({
  "org.example.chaoxingsystem.user",
  "org.example.chaoxingsystem.teacher",
  "org.example.chaoxingsystem.student",  // 确保包含student
  "org.example.chaoxingsystem.admin"
})
```

### Q4: API返回403 Forbidden？
**A**: 检查：
1. 是否正确传递了Authorization header
2. Token是否有效
3. 用户是否具有STUDENT角色

---

## 🧪 快速测试

### 测试脚本（PowerShell）

```powershell
# 保存为 test-student-api.ps1

$baseUrl = "http://localhost:8083"

# 1. 登录
Write-Host "1. 登录..." -ForegroundColor Cyan
$loginResponse = Invoke-RestMethod -Uri "$baseUrl/api/auth/login" `
  -Method POST `
  -ContentType "application/json" `
  -Body '{"username":"student01","password":"password123"}'

$token = $loginResponse.data.token
Write-Host "✅ 登录成功，Token: $($token.Substring(0,20))..." -ForegroundColor Green

# 2. 测试考试列表
Write-Host "`n2. 获取考试列表..." -ForegroundColor Cyan
$exams = Invoke-RestMethod -Uri "$baseUrl/api/student/exams" `
  -Method GET `
  -Headers @{Authorization="Bearer $token"}
Write-Host "✅ 找到 $($exams.data.total) 个考试" -ForegroundColor Green

# 3. 测试题集列表
Write-Host "`n3. 获取题集列表..." -ForegroundColor Cyan
$collections = Invoke-RestMethod -Uri "$baseUrl/api/student/collections" `
  -Method GET `
  -Headers @{Authorization="Bearer $token"}
Write-Host "✅ 找到 $($collections.data.Count) 个题集" -ForegroundColor Green

# 4. 测试错题统计
Write-Host "`n4. 获取错题统计..." -ForegroundColor Cyan
$errorStats = Invoke-RestMethod -Uri "$baseUrl/api/student/errors/stats" `
  -Method GET `
  -Headers @{Authorization="Bearer $token"}
Write-Host "✅ 错题总数: $($errorStats.data.total)" -ForegroundColor Green

Write-Host "`n🎉 所有测试通过！" -ForegroundColor Magenta
```

**运行测试**:
```bash
powershell -ExecutionPolicy Bypass -File test-student-api.ps1
```

---

## 📚 API使用示例

### 示例1: 创建题集并添加题目

```javascript
// 1. 创建题集
const createCollection = async () => {
  const response = await fetch('http://localhost:8083/api/student/collections', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      name: '数学专题',
      description: '高等数学重点题目'
    })
  });
  const data = await response.json();
  return data.data; // 返回题集ID
};

// 2. 添加题目到题集
const addQuestion = async (collectionId, questionId) => {
  await fetch(`http://localhost:8083/api/student/collections/${collectionId}/questions`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ questionId })
  });
};

// 使用
const collectionId = await createCollection();
await addQuestion(collectionId, 1);
await addQuestion(collectionId, 2);
```

### 示例2: 开始自测并提交

```javascript
// 1. 开始自测
const startQuiz = async (collectionId, questions) => {
  const response = await fetch('http://localhost:8083/api/student/quiz/start', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      collectionId,
      name: '错题本自测',
      questions
    })
  });
  const data = await response.json();
  return data.data; // 返回quizId
};

// 2. 提交自测
const submitQuiz = async (quizId, answers, duration) => {
  const response = await fetch(`http://localhost:8083/api/student/quiz/${quizId}/submit`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ answers, duration })
  });
  const data = await response.json();
  return data.data; // 返回成绩和统计
};

// 使用
const quizId = await startQuiz(1, questions);
const result = await submitQuiz(quizId, {
  '1': 'A',
  '2': 'B',
  '3': ['A', 'C']
}, 300);
console.log(`得分: ${result.score}/${result.totalScore}`);
console.log(`正确率: ${result.accuracy}%`);
```

### 示例3: 错题本管理

```javascript
// 1. 添加错题
const addError = async (questionId, examId, studentAnswer, correctAnswer) => {
  await fetch('http://localhost:8083/api/student/errors', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      questionId,
      examId,
      studentAnswer,
      correctAnswer
    })
  });
};

// 2. 获取错题列表
const getErrors = async (page = 1, size = 10) => {
  const response = await fetch(
    `http://localhost:8083/api/student/errors?page=${page}&size=${size}`,
    {
      headers: { 'Authorization': `Bearer ${token}` }
    }
  );
  const data = await response.json();
  return data.data;
};

// 3. 标记已攻克
const markSolved = async (errorId) => {
  await fetch(`http://localhost:8083/api/student/errors/${errorId}/solve`, {
    method: 'PUT',
    headers: { 'Authorization': `Bearer ${token}` }
  });
};

// 使用
await addError(123, 456, 'B', 'A');
const errors = await getErrors();
await markSolved(errors.list[0].id);
```

---

## 🔧 开发调试

### 启用调试日志

在 `application.yml` 中添加：

```yaml
logging:
  level:
    org.example.chaoxingsystem.student: DEBUG
    org.springframework.web: DEBUG
```

### 使用IDE调试

**IntelliJ IDEA**:
1. 打开 `Run` → `Edit Configurations`
2. 添加 `Spring Boot` 配置
3. Main class: `org.example.chaoxingsystem.ChaoxingSystemApplication`
4. Active profiles: `student`
5. 点击 Debug 按钮

**VS Code**:
```json
{
  "type": "java",
  "name": "Debug Student Backend",
  "request": "launch",
  "mainClass": "org.example.chaoxingsystem.ChaoxingSystemApplication",
  "args": "--spring.profiles.active=student"
}
```

---

## 📖 下一步

1. **阅读详细文档**:
   - `STUDENT_BACKEND_IMPLEMENTATION.md` - 实现详情
   - `STUDENT_API_LIST.md` - 完整API清单

2. **前端对接**:
   - 参考 `exam/frontend/src/api/student.js`
   - 使用提供的API端点

3. **功能测试**:
   - 参考 `ACCEPTANCE_TEST_GUIDE.md`
   - 执行35个测试用例

4. **性能优化**:
   - 添加Redis缓存
   - 优化数据库查询
   - 配置连接池

---

## 💡 提示

- 🔐 所有API都需要认证，记得传递Token
- 📄 响应格式统一为 `{code, message, data}`
- 🔢 分页参数：page从1开始，size默认10
- ⚠️ 错误码：200成功，400参数错误，403权限不足，404资源不存在

---

**祝您使用愉快！** 🎉

如有问题，请查看详细文档或联系开发团队。

