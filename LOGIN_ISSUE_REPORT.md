# 登录401问题诊断报告

## 问题现状

尽管完成了以下工作，登录仍然返回401未授权错误：

### ✅ 已完成的工作

1. **数据库完全重新初始化**
   - 创建了 `backend/complete-init.sql` 整合脚本
   - 删除并重建了所有表
   - 插入了初始数据

2. **多次尝试更新密码哈希**
   - 使用了不同的BCrypt哈希值
   - 验证了哈希长度（60字符，正确）
   - 最新使用的哈希：`$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYzQziBn4g2`

3. **服务状态正常**
   - MySQL: ✅ 运行正常
   - Backend: ✅ 运行正常 (端口8083)
   - Frontend: ✅ 运行正常 (端口8080)

### ❌ 问题症状

- 所有登录请求返回 `401 Unauthorized`
- 响应内容: `{"code":401,"message":"用户名或密码错误","data":null}`
- 已测试账号: student1, teacher1, admin1 - 全部失败

## 可能的原因分析

### 1. BCrypt版本不匹配
- Java BCrypt实现可能与数据库中的哈希格式不兼容
- $2a (Blowfish "a" version) vs $2b/$2y 版本差异

### 2. 密码编码问题
- 前端可能对密码进行了额外的编码或转换
- UTF-8编码问题

### 3. 后端认证逻辑问题
- `UserService.authenticate()` 方法可能有bug
- `passwordEncoder.matches()` 调用可能失败
- 数据库查询可能返回null

### 4. Spring Security配置问题
- 认证过滤器可能拦截了登录请求
- CORS配置可能有问题

## 建议的下一步

### 方案1：使用前端界面测试（推荐）

打开浏览器访问: http://localhost:8080

尝试使用以下账号登录：
- 用户名: `student1` 密码: `123456`
- 用户名: `teacher1` 密码: `123456`  
- 用户名: `admin1` 密码: `123456`

前端可能包含更详细的错误信息。

###方案2：使用测试页面

打开浏览器，访问文件: `file:///D:/exam1224/login-test.html`

这个页面会显示完整的API响应，包括状态码和错误详情。

### 方案3：查看后端日志

```powershell
docker-compose logs backend --tail=100 | Select-String -Pattern "auth|login|password|401"
```

### 方案4：重新构建后端（需要网络）

如果网络稳定，可以尝试重新构建后端镜像：

```powershell
docker-compose down
docker-compose build --no-cache backend
docker-compose up -d
```

## 测试脚本

### PowerShell测试

```powershell
# 测试登录API
$body = '{"username":"student1","password":"123456"}'
try {
    $response = Invoke-WebRequest -Uri 'http://localhost:8083/api/auth/login' `
        -Method POST -Body $body -ContentType 'application/json'
    Write-Host "成功: $($response.StatusCode)"
    Write-Host $response.Content
} catch {
    $stream = $_.Exception.Response.GetResponseStream()
    $reader = New-Object System.IO.StreamReader($stream)
    $responseBody = $reader.ReadToEnd()
    Write-Host "失败: $($_.Exception.Response.StatusCode.value__)"
    Write-Host $responseBody
}
```

### curl测试

```bash
curl -X POST http://localhost:8083/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"student1","password":"123456"}' \
  -v
```

## 数据库验证

验证用户数据：

```sql
USE chaoxing;
SELECT 
    username, 
    user_type, 
    real_name,
    LENGTH(password_hash) as hash_len,
    LEFT(password_hash, 10) as hash_prefix
FROM users
WHERE username IN ('student1', 'teacher1', 'admin1');
```

## 临时解决方案

如果无法解决登录问题，可以考虑：

1. **绕过密码验证**（仅开发环境）
   - 修改 `UserService.authenticate()` 暂时返回用户对象
   - 用于测试其他功能

2. **使用固定Token**
   - 生成一个测试Token
   - 直接在请求头中使用

3. **检查前端代码**
   - 查看前端如何发送登录请求
   - 是否有密码加密或额外处理

## 相关文件

- `backend/complete-init.sql` - 完整数据库初始化脚本
- `login-test.html` - 浏览器登录测试页面
- `test_bcrypt.py` - BCrypt哈希验证脚本（需安装bcrypt）
- `test-bcrypt.js` - Node.js BCrypt测试（需安装bcrypt）

## 联系信息

如果问题持续存在，建议：
1. 检查Spring Boot应用日志
2. 使用调试器逐步跟踪认证流程
3. 验证BCrypt库版本兼容性
4. 检查数据库字符集设置

