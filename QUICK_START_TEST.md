# 🚀 快速开始测试指南

## ✅ 服务状态

所有服务已成功启动：

| 服务 | 状态 | 地址 |
|------|------|------|
| 前端 | ✅ Running | http://localhost:8080 |
| 后端 | ✅ Running | http://localhost:8083 |
| MySQL | ✅ Healthy | localhost:3306 |

---

## 📋 测试账号

由于发现数据库seed.sql未正确执行，请先初始化数据：

### 方法1：使用Docker Compose重新构建（推荐）

```bash
# 停止并删除所有容器和卷
docker-compose down -v

# 重新构建并启动
docker-compose up -d --build

# 等待30秒让MySQL完成初始化
timeout /t 30

# 检查用户数据
docker exec -i chaoxing-mysql mysql -uroot -proot -e "USE chaoxing; SELECT username, user_type, real_name FROM users LIMIT 5;"
```

### 方法2：手动创建测试用户

如果自动初始化失败，可以手动创建测试用户：

```sql
-- 连接到MySQL
docker exec -it chaoxing-mysql mysql -uroot -proot chaoxing

-- 创建学生用户（密码: 123456）
INSERT INTO users(username,email,password_hash,user_type,real_name) VALUES
('student1','student1@test.com','$2a$10$zJpIYkPp7OLoOqMZ9o4m3uQV1YVQdGmJ8VxgQf3o3PzF8q6QJk7uS','student','测试学生1'),
('student2','student2@test.com','$2a$10$zJpIYkPp7OLoOqMZ9o4m3uQV1YVQdGmJ8VxgQf3o3PzF8q6QJk7uS','student','测试学生2');

-- 创建教师用户（密码: 123456）
INSERT INTO users(username,email,password_hash,user_type,real_name) VALUES
('teacher1','teacher1@test.com','$2a$10$zJpIYkPp7OLoOqMZ9o4m3uQV1YVQdGmJ8VxgQf3o3PzF8q6QJk7uS','teacher','测试教师1');

-- 创建管理员用户（密码: 123456）
INSERT INTO users(username,email,password_hash,user_type,real_name) VALUES
('admin','admin@test.com','$2a$10$zJpIYkPp7OLoOqMZ9o4m3uQV1YVQdGmJ8VxgQf3o3PzF8q6QJk7uS','admin','系统管理员');
```

---

## 🎯 开始测试

### 1. 访问前端页面

打开浏览器访问：http://localhost:8080

### 2. 登录系统

使用学生账号登录：
- 用户名：`student1`
- 密码：`123456`

### 3. 测试学生端考试功能

#### 步骤1：查看考试列表
- 登录后点击左侧菜单 **"我的考试"**
- 查看考试列表是否正确显示

#### 步骤2：测试筛选功能
- 按学科筛选
- 按学期筛选
- 按考试状态筛选

#### 步骤3：查看考试详情
- 点击任意考试行
- 查看考试详情弹窗

#### 步骤4：参加考试（如果有进行中的考试）
- 点击"参加考试"按钮
- 完成考前检查（摄像头测试）
- 进入考试界面
- 测试答题功能

#### 步骤5：查看成绩（如果有已完成的考试）
- 点击"查看成绩"按钮
- 查看得分和试卷详情

---

## 🔍 后端API测试

### 使用Postman或curl测试

#### 1. 登录获取Token

```bash
curl -X POST http://localhost:8083/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"student1","password":"123456"}'
```

成功响应示例：
```json
{
  "code": 200,
  "message": "登录成功",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": 1,
      "username": "student1",
      "userType": "student"
    }
  }
}
```

#### 2. 获取考试列表

```bash
curl -X GET "http://localhost:8083/api/student/exams?page=1&size=10" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

#### 3. 获取试卷题目

```bash
curl -X GET "http://localhost:8083/api/student/exams/1/paper" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

#### 4. 提交试卷

```bash
curl -X POST http://localhost:8083/api/student/exams/1/submit \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "answers": {
      "1": "A",
      "2": ["A","C"],
      "3": "我的答案"
    },
    "durationUsed": 1800
  }'
```

#### 5. 查看考试结果

```bash
curl -X GET "http://localhost:8083/api/student/exams/1/result" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## 📊 功能验证清单

### 前端功能

- [ ] 登录功能正常
- [ ] 考试列表正确显示
- [ ] 筛选功能工作正常
- [ ] 分页功能正常
- [ ] 考试详情弹窗显示正确
- [ ] 考前检查界面正常
- [ ] 考试界面布局正确
- [ ] 答题功能正常
- [ ] 导航切换正常
- [ ] 倒计时正常
- [ ] 交卷功能正常
- [ ] 成绩查看正常
- [ ] 试卷回顾正常

### 后端API

- [ ] 登录接口返回200
- [ ] Token生成正确
- [ ] 考试列表接口返回数据
- [ ] 试卷接口返回题目
- [ ] 提交接口工作正常
- [ ] 结果接口返回成绩

---

## 🐛 常见问题

### 问题1：无法登录

**解决方案：**
1. 检查用户是否已创建
2. 确认密码是否正确（默认：123456）
3. 查看后端日志：`docker-compose logs backend`

### 问题2：考试列表为空

**解决方案：**
1. 确认数据库已初始化
2. 使用教师账号创建考试
3. 分配学生到考试

### 问题3：无法参加考试

**解决方案：**
1. 确认考试时间是否在进行中
2. 确认学生是否被分配到该考试
3. 检查试卷是否有题目

---

## 📝 创建测试数据

如果数据库为空，可以按以下顺序创建测试数据：

### 1. 创建题目

登录教师账号 → 题库管理 → 添加题目

### 2. 创建试卷

题库管理 → 试卷管理 → 创建试卷 → 添加题目

### 3. 创建考试

考试管理 → 创建考试 → 设置时间 → 选择试卷

### 4. 分配学生

考试详情 → 考生管理 → 添加学生

---

## 🔧 有用的命令

```bash
# 查看所有容器状态
docker-compose ps

# 查看后端日志
docker-compose logs -f backend

# 查看MySQL日志
docker-compose logs -f mysql

# 重启服务
docker-compose restart

# 停止所有服务
docker-compose down

# 停止并清理所有数据
docker-compose down -v

# 进入MySQL容器
docker exec -it chaoxing-mysql mysql -uroot -proot chaoxing

# 查看数据库表
docker exec -i chaoxing-mysql mysql -uroot -proot -e "USE chaoxing; SHOW TABLES;"

# 查看用户数据
docker exec -i chaoxing-mysql mysql -uroot -proot -e "USE chaoxing; SELECT * FROM users;"
```

---

## 📚 相关文档

- **详细测试指南**：`docs/EXAM_FEATURE_TEST_GUIDE.md`
- **功能改进说明**：`docs/STUDENT_EXAM_IMPROVEMENTS.md`
- **完整实现总结**：`docs/EXAM_FEATURE_COMPLETE_SUMMARY.md`
- **API文档**：`docs/api/API_SPECS.md`

---

## ⚡ 快速验证命令

```powershell
# 一键检查服务状态
docker-compose ps

# 检查数据库是否有用户
docker exec -i chaoxing-mysql mysql -uroot -proot -e "USE chaoxing; SELECT COUNT(*) as user_count FROM users;"

# 检查是否有考试数据
docker exec -i chaoxing-mysql mysql -uroot -proot -e "USE chaoxing; SELECT COUNT(*) as exam_count FROM biz_exam;"
```

---

**祝测试顺利！** 🎉

如有问题，请查看日志或联系开发团队。

