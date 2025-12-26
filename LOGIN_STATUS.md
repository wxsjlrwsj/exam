# 登录问题状态

## 当前状态

✅ **数据库已重新初始化完成**
- 创建了完整的初始化SQL文件: `backend/complete-init.sql`
- 所有表结构已创建
- 初始数据已导入

✅ **后端服务已启动**
- 端口: 8083
- 状态: 正常运行

✅ **前端服务已启动**
- 端口: 8080
- 状态: 正常运行

## 测试账号

所有账号的密码都是: `123456`

### 学生账号
- 用户名: `student1`, `student2`, `student3`, `student4`
- 密码: `123456`

### 教师账号
- 用户名: `teacher1`, `teacher2`, `teacher3`
- 密码: `123456`

### 管理员账号
- 用户名: `admin1`
- 密码: `123456`

## 测试方式

### 方式1: 浏览器测试页面
打开项目根目录下的 `login-test.html` 文件，直接在浏览器中测试登录功能。

### 方式2: 前端应用
访问: http://localhost:8080

### 方式3: PowerShell命令
```powershell
$body = '{"username":"student1","password":"123456"}'
Invoke-RestMethod -Uri 'http://localhost:8083/api/auth/login' -Method POST -Body $body -ContentType 'application/json'
```

## 当前问题

登录API返回401错误（未授权）。可能的原因：
1. BCrypt密码验证失败
2. 数据库连接问题
3. 后端认证逻辑问题

## 后续步骤

建议使用浏览器测试页面（login-test.html）来获取更详细的错误信息。

## 访问地址

- **前端应用**: http://localhost:8080
- **后端API**: http://localhost:8083
- **登录API**: http://localhost:8083/api/auth/login

