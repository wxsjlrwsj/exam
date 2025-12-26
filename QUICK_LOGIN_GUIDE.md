# 🎉 快速登录指南

## 重要发现！

前端有一个**开发模式测试登录**功能，即使后端登录API有问题，你也可以正常使用系统！

## 🚀 立即开始测试

### 方式1：直接使用前端登录（推荐）

1. **打开浏览器访问**: http://localhost:8080

2. **输入任何账号信息**，例如：
   - 用户名: `student1`
   - 密码: `123456` （任意密码都可以）

3. **点击登录按钮**

4. 系统会自动识别用户类型并进入对应页面：
   - `admin1` → 管理员界面
   - `teacher1` → 教师界面  
   - `student1` → 学生界面

### 方式2：启用持久化测试模式

在浏览器控制台（F12）中执行：

```javascript
localStorage.setItem('useFakeAuth', '1')
```

然后刷新页面，之后所有登录都会使用测试模式。

## 📋 测试账号列表

| 用户名 | 用户类型 | 说明 |
|--------|---------|------|
| student1 | 学生 | 测试学生端功能 |
| student2 | 学生 | 测试学生端功能 |
| student3 | 学生 | 测试学生端功能 |
| teacher1 | 教师 | 测试教师端功能 |
| teacher2 | 教师 | 测试教师端功能 |
| admin1 | 管理员 | 测试管理员功能 |

**提示**：密码可以输入任意内容，因为在开发模式下会自动绕过后端验证。

## 🔍 如何工作？

前端登录逻辑（`frontend/src/views/Login.vue` 第103-114行）：

```javascript
// 开发环境或本地开关启用时，使用测试账号作为后备
if (import.meta.env.MODE === 'development' || localStorage.getItem('useFakeAuth') === '1') {
  let userType = 'student'
  if (loginForm.username.includes('admin')) userType = 'admin'
  else if (loginForm.username.includes('teacher')) userType = 'teacher'
  
  localStorage.setItem('token', 'mock-token-' + Date.now())
  localStorage.setItem('userType', userType)
  localStorage.setItem('username', loginForm.username)
  
  showMessage('登录成功（测试账号）', 'success')
  router.push({ name: 'DashboardHome' })
}
```

系统会根据用户名自动判断用户类型：
- 包含 "admin" → 管理员
- 包含 "teacher" → 教师
- 其他 → 学生

## 🎯 测试学生端查看考试功能

1. 使用 `student1` 登录
2. 进入系统后，找到"考试列表"或"我的考试"菜单
3. 测试以下功能：
   - ✅ 查看考试列表
   - ✅ 查看考试详情
   - ✅ 开始考试
   - ✅ 答题界面
   - ✅ 提交答案
   - ✅ 查看成绩
   - ✅ 错题本功能

## ⚠️ 注意事项

1. **开发模式限制**：
   - 这个功能只在 `MODE === 'development'` 时自动启用
   - 或者需要手动设置 `localStorage.setItem('useFakeAuth', '1')`

2. **数据持久性**：
   - Token是临时生成的
   - 刷新页面后需要重新登录

3. **API调用**：
   - 其他API调用（如获取考试列表、提交答案等）仍会真实请求后端
   - 只有登录接口被绕过

## 🔧 恢复正常登录模式

如果后端登录修复后，想恢复正常登录：

```javascript
localStorage.removeItem('useFakeAuth')
```

然后刷新页面。

## 📍 当前服务地址

- **前端**: http://localhost:8080
- **后端API**: http://localhost:8083
- **数据库**: localhost:3306

## ✅ 后续步骤

1. **先测试前端功能**，确保界面和交互正常
2. **测试学生端考试功能**，验证前端是否完整实现
3. **检查后端API**，看看哪些功能需要后端支持
4. **修复登录API**（如果需要生产环境使用）

## 🎓 开始测试吧！

现在就打开 http://localhost:8080 开始测试学生端查看考试功能！

---

**祝测试顺利！** 🚀

