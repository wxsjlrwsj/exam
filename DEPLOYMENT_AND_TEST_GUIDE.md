# 超星考试系统 - 部署与测试指南

## 🚀 快速部署（5分钟）

### 前置条件检查

```powershell
# 1. 检查Java版本（需要Java 17+）
java -version

# 2. 检查MySQL服务
Get-Service -Name "MySQL*"

# 3. 检查端口占用
Get-NetTCPConnection -LocalPort 8083 -State Listen
Get-NetTCPConnection -LocalPort 5173 -State Listen
```

---

## 📦 步骤1: 数据库准备

### 方式A: 使用SQL脚本（推荐）

```bash
# 连接MySQL
mysql -u root -p

# 创建数据库（如果不存在）
CREATE DATABASE IF NOT EXISTS chaoxing CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

# 使用数据库
USE chaoxing;

# 执行基础架构脚本
SOURCE C:/Users/34445/Desktop/chaoxin/exam/backend/src/main/resources/schema.sql;

# 执行初始数据脚本
SOURCE C:/Users/34445/Desktop/chaoxin/exam/backend/src/main/resources/seed.sql;

# 执行学生端迁移脚本
SOURCE C:/Users/34445/Desktop/chaoxin/exam/backend/db_migration_student.sql;

# 验证表创建
SHOW TABLES;
```

### 方式B: 自动初始化

后端启动时会自动执行 `schema.sql` 和 `seed.sql`，但学生端的表需要手动执行迁移脚本。

---

## 🔧 步骤2: 配置文件检查

### 检查 `application.yml`

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/chaoxing?useSSL=false&serverTimezone=UTC
    username: root
    password: ""  # 修改为你的MySQL密码
```

**重要**：如果MySQL有密码，必须修改 `password` 字段！

---

## 🚀 步骤3: 启动后端

### 方式A: 使用测试脚本（推荐）

```powershell
cd C:\Users\34445\Desktop\chaoxin\exam
.\start-backend-test.ps1
```

这个脚本会：
- 检查JAR文件
- 显示配置信息
- 启动后端并显示日志

### 方式B: 手动启动

```powershell
cd C:\Users\34445\Desktop\chaoxin\exam\backend
java -jar target/backend.jar
```

### 启动成功标志

看到以下日志表示启动成功：

```
Started ChaoxingSystemApplication in X.XXX seconds
```

---

## 🌐 步骤4: 启动前端

### 方式A: 开发模式

```powershell
cd C:\Users\34445\Desktop\chaoxin\exam\frontend
npm run dev
```

访问: http://localhost:5173

### 方式B: 生产模式

```powershell
cd C:\Users\34445\Desktop\chaoxin\exam\frontend
npm run build
# 使用nginx或其他服务器托管dist目录
```

---

## ✅ 步骤5: 功能测试

### 自动化测试

```powershell
cd C:\Users\34445\Desktop\chaoxin\exam
.\test-api-comprehensive.ps1
```

这个脚本会测试：
1. ✅ 健康检查
2. ✅ 用户认证
3. ✅ 学生端API（10+个端点）
4. ✅ 权限控制

### 手动测试清单

#### 1. 后端健康检查

```powershell
# 测试健康端点
Invoke-WebRequest -Uri "http://localhost:8083/actuator/health"
```

**期望结果**: 返回 `{"status":"UP"}`

#### 2. 用户登录测试

```powershell
$loginBody = @{
    username = "student01"
    password = "password123"
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri "http://localhost:8083/api/auth/login" `
    -Method POST `
    -ContentType "application/json" `
    -Body $loginBody

$token = $response.data.token
Write-Host "Token: $token"
```

**期望结果**: 返回有效的JWT Token

#### 3. 学生端API测试

```powershell
# 使用上面获取的token
$headers = @{ Authorization = "Bearer $token" }

# 测试考试列表
Invoke-RestMethod -Uri "http://localhost:8083/api/student/exams" -Headers $headers

# 测试题集列表
Invoke-RestMethod -Uri "http://localhost:8083/api/student/collections" -Headers $headers

# 测试错题统计
Invoke-RestMethod -Uri "http://localhost:8083/api/student/errors/stats" -Headers $headers

# 测试个人信息
Invoke-RestMethod -Uri "http://localhost:8083/api/student/profile" -Headers $headers
```

**期望结果**: 所有请求返回 `code: 200`

---

## 🔍 常见问题排查

### 问题1: 后端启动失败

**症状**: Java进程启动但没有监听端口

**可能原因**:
1. 数据库连接失败
2. 端口被占用
3. 配置文件错误

**排查步骤**:

```powershell
# 1. 检查MySQL是否运行
Get-Service -Name "MySQL*"

# 2. 测试数据库连接
mysql -u root -p -e "SELECT 1"

# 3. 检查端口占用
Get-NetTCPConnection -LocalPort 8083

# 4. 查看后端日志
# 在后端启动窗口查看错误信息
```

**解决方案**:
- 确保MySQL服务运行
- 修改 `application.yml` 中的数据库密码
- 关闭占用8083端口的进程

### 问题2: 前端无法连接后端

**症状**: 前端显示网络错误

**排查步骤**:

```powershell
# 1. 测试后端是否可访问
Invoke-WebRequest -Uri "http://localhost:8083/actuator/health"

# 2. 检查CORS配置
# 查看 application.yml 中的 allowed-origins
```

**解决方案**:
- 确保后端已启动
- 检查防火墙设置
- 验证CORS配置包含前端地址

### 问题3: 登录失败

**症状**: 返回401或用户不存在

**排查步骤**:

```sql
-- 检查用户是否存在
USE chaoxing;
SELECT * FROM sys_user WHERE username = 'student01';

-- 检查角色分配
SELECT u.username, r.role_key 
FROM sys_user u
LEFT JOIN sys_user_role ur ON u.id = ur.user_id
LEFT JOIN sys_role r ON ur.role_id = r.id
WHERE u.username = 'student01';
```

**解决方案**:
- 确保执行了 `seed.sql` 初始化数据
- 检查密码是否正确（默认: password123）
- 验证用户角色分配

### 问题4: API返回403 Forbidden

**症状**: 已登录但API返回403

**可能原因**:
1. Token过期
2. 角色权限不足
3. Token格式错误

**排查步骤**:

```powershell
# 检查Token格式
# Token应该是: Bearer eyJhbGciOiJIUzI1NiIs...

# 测试无需认证的端点
Invoke-WebRequest -Uri "http://localhost:8083/actuator/health"
```

**解决方案**:
- 重新登录获取新Token
- 确保使用正确的角色账号
- 检查Authorization header格式

---

## 📊 功能测试矩阵

### 学生端功能测试

| 功能模块 | 测试项 | 端点 | 状态 |
|---------|--------|------|------|
| 考试管理 | 获取考试列表 | GET /api/student/exams | ⬜ |
| 考试管理 | 获取试卷 | GET /api/student/exams/{id}/paper | ⬜ |
| 考试管理 | 提交答案 | POST /api/student/exams/{id}/submit | ⬜ |
| 考试管理 | 查看成绩 | GET /api/student/exams/{id}/result | ⬜ |
| 考试管理 | 回顾试卷 | GET /api/student/exams/{id}/review | ⬜ |
| 题集管理 | 获取题集列表 | GET /api/student/collections | ⬜ |
| 题集管理 | 创建题集 | POST /api/student/collections | ⬜ |
| 题集管理 | 添加题目 | POST /api/student/collections/{id}/questions | ⬜ |
| 错题本 | 获取错题列表 | GET /api/student/errors | ⬜ |
| 错题本 | 获取统计 | GET /api/student/errors/stats | ⬜ |
| 错题本 | 标记已攻克 | PUT /api/student/errors/{id}/solve | ⬜ |
| 自测 | 开始自测 | POST /api/student/quiz/start | ⬜ |
| 自测 | 提交自测 | POST /api/student/quiz/{id}/submit | ⬜ |
| 自测 | 查看结果 | GET /api/student/quiz/{id}/result | ⬜ |
| 题库 | 浏览题库 | GET /api/student/practice/questions | ⬜ |
| 题库 | 题目详情 | GET /api/student/practice/questions/{id} | ⬜ |
| 用户中心 | 个人信息 | GET /api/student/profile | ⬜ |
| 用户中心 | 更新信息 | PUT /api/student/profile | ⬜ |
| 用户中心 | 修改密码 | PUT /api/student/profile/password | ⬜ |
| 用户中心 | 学习统计 | GET /api/student/profile/stats | ⬜ |

### 教师端功能测试

| 功能模块 | 测试项 | 端点 | 状态 |
|---------|--------|------|------|
| 题库管理 | 题目列表 | GET /api/teacher/questions | ⬜ |
| 题库管理 | 创建题目 | POST /api/teacher/questions | ⬜ |
| 试卷管理 | 试卷列表 | GET /api/teacher/papers | ⬜ |
| 试卷管理 | 创建试卷 | POST /api/teacher/papers | ⬜ |
| 考试管理 | 考试列表 | GET /api/teacher/exams | ⬜ |
| 考试管理 | 创建考试 | POST /api/teacher/exams | ⬜ |
| 成绩管理 | 成绩列表 | GET /api/teacher/scores | ⬜ |
| 成绩管理 | 批改试卷 | PUT /api/teacher/scores/{id} | ⬜ |

### 管理员端功能测试

| 功能模块 | 测试项 | 端点 | 状态 |
|---------|--------|------|------|
| 用户管理 | 用户列表 | GET /api/admin/users | ⬜ |
| 角色管理 | 角色列表 | GET /api/admin/roles | ⬜ |
| 权限管理 | 菜单列表 | GET /api/admin/menus | ⬜ |

---

## 🎯 性能测试

### 并发测试

```powershell
# 使用Apache Bench进行并发测试
ab -n 1000 -c 10 http://localhost:8083/actuator/health
```

### 响应时间测试

```powershell
Measure-Command {
    Invoke-WebRequest -Uri "http://localhost:8083/api/student/exams"
}
```

---

## 📝 测试报告模板

```markdown
# 测试报告

**测试日期**: 2024-12-25
**测试人员**: XXX
**版本**: v1.0

## 测试环境
- OS: Windows 11
- Java: 17.0.x
- MySQL: 8.0.x
- Node.js: 18.x

## 测试结果
- 总测试数: XX
- 通过: XX
- 失败: XX
- 成功率: XX%

## 问题列表
1. [问题描述]
   - 严重程度: 高/中/低
   - 复现步骤: ...
   - 期望结果: ...
   - 实际结果: ...

## 建议
1. ...
2. ...
```

---

## 🎉 验收标准

系统可以验收的条件：

- ✅ 后端服务正常启动，健康检查通过
- ✅ 前端服务正常启动，页面可访问
- ✅ 用户可以正常登录（学生、教师、管理员）
- ✅ 学生端核心功能可用（考试、题集、错题本）
- ✅ 教师端核心功能可用（题库、试卷、考试、成绩）
- ✅ 管理员端核心功能可用（用户、角色、权限）
- ✅ API响应时间 < 1秒
- ✅ 无严重bug或错误
- ✅ 数据持久化正常

---

## 📞 技术支持

如遇到问题，请：

1. 查看后端日志窗口的错误信息
2. 检查数据库连接和数据
3. 参考本文档的"常见问题排查"
4. 查阅详细文档：
   - `STUDENT_BACKEND_IMPLEMENTATION.md`
   - `STUDENT_API_LIST.md`
   - `STUDENT_QUICK_START.md`

---

**祝您测试顺利！** 🎊






