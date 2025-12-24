# 教师端功能验收测试指南

本文档提供了详细的手动测试步骤，用于验证教师端所有新功能是否正常工作。

---

## 📋 测试前准备

### 1. 确认服务运行

```powershell
# 检查所有服务状态
docker ps --filter "name=chaoxing"

# 应该看到3个服务都在运行：
# - chaoxing-mysql
# - chaoxing-backend  
# - chaoxing-frontend
```

### 2. 访问系统

- **前端地址**: http://localhost:8080
- **后端地址**: http://localhost:8083

### 3. 测试账号

根据种子数据，应该有以下测试账号：

**教师账号**:
- 用户名: `teacher` 或 `teacher1`
- 密码: 查看数据库 `biz_teacher` 表

**管理员账号**:
- 用户名: `admin`
- 密码: 查看数据库或配置文件

> **提示**: 如果不知道密码，可以通过以下命令查看：
> ```powershell
> docker exec chaoxing-mysql mysql -uroot -proot chaoxing -e "SELECT username, password FROM biz_teacher LIMIT 5;"
> ```

---

## 🧪 功能测试

### 模块1: 用户登录与认证

#### 测试1.1: 教师登录

**测试步骤**:
1. 打开浏览器访问 http://localhost:8080
2. 输入教师账号和密码
3. 点击登录按钮

**预期结果**:
- ✅ 成功跳转到教师端主页
- ✅ 顶部显示用户信息
- ✅ 左侧显示教师端菜单

**实际结果**: [ ] 通过 / [ ] 失败

**备注**: _______________

---

### 模块2: 科目管理

#### 测试2.1: 查看科目列表

**测试步骤**:
1. 登录系统
2. 访问科目管理页面（如果有）
3. 或通过API测试: `GET /api/subjects`

**使用Postman测试**:
```http
GET http://localhost:8083/api/subjects
Authorization: Bearer {your_token}
```

**预期结果**:
- ✅ 返回科目列表
- ✅ 包含以下科目：Java程序设计、数据结构、计算机网络、操作系统、数据库原理等
- ✅ 每个科目包含：id, name, code, description

**实际结果**: [ ] 通过 / [ ] 失败

**备注**: _______________

#### 测试2.2: 查看科目详情

**API测试**:
```http
GET http://localhost:8083/api/subjects/1
Authorization: Bearer {your_token}
```

**预期结果**:
- ✅ 返回科目详细信息
- ✅ 包含科目的所有字段

**实际结果**: [ ] 通过 / [ ] 失败

---

### 模块3: 班级管理

#### 测试3.1: 查看班级列表

**测试步骤**:
1. 访问班级管理页面
2. 或使用API: `GET /api/classes?all=true`

**API测试**:
```http
GET http://localhost:8083/api/classes?all=true
Authorization: Bearer {your_token}
```

**预期结果**:
- ✅ 返回班级列表
- ✅ 包含：计算机科学1班、计算机科学2班、软件工程1班等
- ✅ 每个班级包含：id, class_name, class_code, grade, major

**实际结果**: [ ] 通过 / [ ] 失败

#### 测试3.2: 查看班级详情

**API测试**:
```http
GET http://localhost:8083/api/classes/1
Authorization: Bearer {your_token}
```

**预期结果**:
- ✅ 返回班级详细信息

**实际结果**: [ ] 通过 / [ ] 失败

#### 测试3.3: 查看班级学生

**API测试**:
```http
GET http://localhost:8083/api/classes/1/students?page=1&size=20
Authorization: Bearer {your_token}
```

**预期结果**:
- ✅ 返回该班级的学生列表
- ✅ 包含分页信息

**实际结果**: [ ] 通过 / [ ] 失败

---

### 模块4: 题库管理

#### 测试4.1: 查看题目列表

**前端测试步骤**:
1. 点击左侧菜单"题库管理"
2. 查看题目列表

**预期结果**:
- ✅ 显示题目列表
- ✅ 支持分页
- ✅ 支持筛选（按科目、类型、难度）
- ✅ 每个题目显示：题目内容、类型、难度、创建时间

**实际结果**: [ ] 通过 / [ ] 失败

#### 测试4.2: 创建题目

**测试步骤**:
1. 点击"创建题目"按钮
2. 填写题目信息：
   - 题目内容
   - 题目类型（单选/多选/判断/填空/简答）
   - 选项（如果是选择题）
   - 答案
   - 难度
   - 科目
   - 分值
3. 点击提交

**预期结果**:
- ✅ 成功创建题目
- ✅ 列表中显示新题目

**实际结果**: [ ] 通过 / [ ] 失败

#### 测试4.3: 编辑题目

**测试步骤**:
1. 在题目列表中点击"编辑"按钮
2. 修改题目信息
3. 保存

**预期结果**:
- ✅ 成功更新题目
- ✅ 列表中显示更新后的内容

**实际结果**: [ ] 通过 / [ ] 失败

#### 测试4.4: 删除题目

**测试步骤**:
1. 在题目列表中点击"删除"按钮
2. 确认删除

**预期结果**:
- ✅ 成功删除题目
- ✅ 列表中不再显示该题目

**实际结果**: [ ] 通过 / [ ] 失败

#### 测试4.5: 导入题目（新功能）

**API测试**:
```http
POST http://localhost:8083/api/questions/import
Authorization: Bearer {your_token}
Content-Type: application/json

{
  "questions": [
    {
      "content": "Java是面向对象的编程语言吗？",
      "type": "判断",
      "answer": "正确",
      "difficulty": 1,
      "subject": "Java程序设计",
      "score": 5
    }
  ]
}
```

**预期结果**:
- ✅ 成功导入题目
- ✅ 返回导入成功的数量

**实际结果**: [ ] 通过 / [ ] 失败

#### 测试4.6: 审核题目（新功能）

**API测试**:
```http
POST http://localhost:8083/api/questions/1/audit
Authorization: Bearer {your_token}
Content-Type: application/json

{
  "status": "approved",
  "comment": "题目质量良好"
}
```

**预期结果**:
- ✅ 成功审核题目
- ✅ 题目状态更新

**实际结果**: [ ] 通过 / [ ] 失败

---

### 模块5: 试卷管理

#### 测试5.1: 查看试卷列表

**前端测试步骤**:
1. 点击"试卷管理"
2. 查看试卷列表

**预期结果**:
- ✅ 显示试卷列表
- ✅ 支持分页
- ✅ 显示试卷名称、科目、总分、及格分、创建时间

**实际结果**: [ ] 通过 / [ ] 失败

#### 测试5.2: 创建试卷（手动组卷）

**测试步骤**:
1. 点击"创建试卷"
2. 填写试卷名称、科目
3. 从题库中选择题目
4. 设置每道题的分值
5. 设置及格分
6. 保存

**预期结果**:
- ✅ 成功创建试卷
- ✅ 列表中显示新试卷

**实际结果**: [ ] 通过 / [ ] 失败

#### 测试5.3: 智能组卷

**API测试**:
```http
POST http://localhost:8083/api/papers/auto-generate
Authorization: Bearer {your_token}
Content-Type: application/json

{
  "subject": "Java程序设计",
  "difficulty": 2,
  "totalScore": 100,
  "typeDistribution": {
    "单选题": 30,
    "多选题": 20,
    "判断题": 20,
    "填空题": 15,
    "简答题": 15
  }
}
```

**预期结果**:
- ✅ 成功生成试卷
- ✅ 返回试卷ID
- ✅ 试卷符合设定的要求

**实际结果**: [ ] 通过 / [ ] 失败

#### 测试5.4: 查看试卷详情（新功能）

**API测试**:
```http
GET http://localhost:8083/api/papers/1
Authorization: Bearer {your_token}
```

**预期结果**:
- ✅ 返回试卷完整信息
- ✅ 包含所有题目
- ✅ 包含每题分值

**实际结果**: [ ] 通过 / [ ] 失败

#### 测试5.5: 更新试卷（新功能）

**API测试**:
```http
PUT http://localhost:8083/api/papers/1
Authorization: Bearer {your_token}
Content-Type: application/json

{
  "name": "Java期末考试（修订版）",
  "passScore": 65
}
```

**预期结果**:
- ✅ 成功更新试卷
- ✅ 信息已修改

**实际结果**: [ ] 通过 / [ ] 失败

#### 测试5.6: 删除试卷（新功能）

**API测试**:
```http
DELETE http://localhost:8083/api/papers/999
Authorization: Bearer {your_token}
```

**预期结果**:
- ✅ 成功删除试卷（如果试卷未被使用）
- ✅ 或返回错误（如果试卷已被使用）

**实际结果**: [ ] 通过 / [ ] 失败

---

### 模块6: 考试管理

#### 测试6.1: 查看考试列表

**测试步骤**:
1. 点击"考试管理"
2. 切换不同状态标签（未开始/进行中/已结束）

**预期结果**:
- ✅ 显示考试列表
- ✅ 按状态分类显示
- ✅ 显示考试名称、时间、状态

**实际结果**: [ ] 通过 / [ ] 失败

#### 测试6.2: 创建考试

**测试步骤**:
1. 点击"创建考试"
2. 填写考试信息：
   - 考试名称
   - 选择试卷
   - 开始时间
   - 考试时长
3. 保存

**预期结果**:
- ✅ 成功创建考试
- ✅ 列表中显示新考试

**实际结果**: [ ] 通过 / [ ] 失败

#### 测试6.3: 查看考试详情（新功能）

**API测试**:
```http
GET http://localhost:8083/api/exams/1
Authorization: Bearer {your_token}
```

**预期结果**:
- ✅ 返回考试完整信息
- ✅ 包含试卷信息
- ✅ 包含考生信息
- ✅ 包含考试统计

**实际结果**: [ ] 通过 / [ ] 失败

#### 测试6.4: 添加考生（新功能）

**API测试**:
```http
POST http://localhost:8083/api/exams/1/students
Authorization: Bearer {your_token}
Content-Type: application/json

{
  "studentIds": [1, 2, 3],
  "classIds": [1]
}
```

**预期结果**:
- ✅ 成功添加考生
- ✅ 返回添加数量

**实际结果**: [ ] 通过 / [ ] 失败

#### 测试6.5: 移除考生（新功能）

**API测试**:
```http
DELETE http://localhost:8083/api/exams/1/students
Authorization: Bearer {your_token}
Content-Type: application/json

{
  "studentIds": [1, 2]
}
```

**预期结果**:
- ✅ 成功移除考生
- ✅ 返回移除数量

**实际结果**: [ ] 通过 / [ ] 失败

#### 测试6.6: 删除考试（新功能）

**API测试**:
```http
DELETE http://localhost:8083/api/exams/999
Authorization: Bearer {your_token}
```

**预期结果**:
- ✅ 成功删除考试（如果考试未开始）
- ✅ 或返回错误（如果考试已开始或有学生作答）

**实际结果**: [ ] 通过 / [ ] 失败

---

### 模块7: 监考功能（新功能）

#### 测试7.1: 查看监考数据

**测试步骤**:
1. 创建一个考试并开始
2. 点击"监考"按钮
3. 查看实时监考数据

**预期结果**:
- ✅ 显示在线人数
- ✅ 显示已提交人数
- ✅ 显示学生列表
- ✅ 每个学生显示：
  - 姓名
  - 答题进度
  - 切屏次数
  - 最后活跃时间
  - 状态（正常/异常）

**实际结果**: [ ] 通过 / [ ] 失败

#### 测试7.2: 发送警告（新功能）

**API测试**:
```http
POST http://localhost:8083/api/monitor/1/warning
Authorization: Bearer {your_token}
Content-Type: application/json

{
  "studentId": 1,
  "reason": "切屏次数过多",
  "message": "请专注考试，不要切换屏幕"
}
```

**预期结果**:
- ✅ 成功发送警告
- ✅ 学生端收到警告消息
- ✅ 警告记录保存到数据库

**实际结果**: [ ] 通过 / [ ] 失败

#### 测试7.3: 强制收卷（新功能）

**API测试**:
```http
POST http://localhost:8083/api/monitor/1/force-submit
Authorization: Bearer {your_token}
Content-Type: application/json

{
  "studentIds": [1, 2]
}
```

**预期结果**:
- ✅ 成功强制收卷
- ✅ 学生答题被提交
- ✅ 学生无法再继续答题

**实际结果**: [ ] 通过 / [ ] 失败

---

### 模块8: 成绩管理

#### 测试8.1: 查看成绩列表

**测试步骤**:
1. 点击"成绩管理"
2. 选择某个考试
3. 查看成绩列表

**预期结果**:
- ✅ 显示学生成绩列表
- ✅ 包含：学号、姓名、成绩、状态
- ✅ 支持筛选（按班级、按学号/姓名搜索）
- ✅ 支持分页

**实际结果**: [ ] 通过 / [ ] 失败

#### 测试8.2: 人工阅卷

**测试步骤**:
1. 点击某个学生的"阅卷"按钮
2. 查看学生答卷
3. 对主观题打分
4. 填写评语
5. 提交

**预期结果**:
- ✅ 显示学生的答题详情
- ✅ 可以对每道题打分
- ✅ 可以填写评语
- ✅ 成功提交后，成绩更新

**实际结果**: [ ] 通过 / [ ] 失败

#### 测试8.3: 调整成绩（新功能）

**API测试**:
```http
POST http://localhost:8083/api/scores/1/adjust
Authorization: Bearer {your_token}
Content-Type: application/json

{
  "recordId": 1,
  "originalScore": 85,
  "adjustedScore": 90,
  "reason": "主观题复议加分",
  "comment": "答题思路清晰，酌情加分"
}
```

**预期结果**:
- ✅ 成功调整成绩
- ✅ 成绩列表中显示新成绩
- ✅ 调整记录保存到数据库

**实际结果**: [ ] 通过 / [ ] 失败

#### 测试8.4: 批量发布成绩（新功能）

**API测试**:
```http
POST http://localhost:8083/api/scores/batch/publish
Authorization: Bearer {your_token}
Content-Type: application/json

{
  "recordIds": [1, 2, 3, 4, 5]
}
```

**预期结果**:
- ✅ 成功发布成绩
- ✅ 学生可以查看成绩
- ✅ 返回发布数量

**实际结果**: [ ] 通过 / [ ] 失败

#### 测试8.5: 批量取消发布（新功能）

**API测试**:
```http
POST http://localhost:8083/api/scores/batch/unpublish
Authorization: Bearer {your_token}
Content-Type: application/json

{
  "recordIds": [1, 2, 3]
}
```

**预期结果**:
- ✅ 成功取消发布
- ✅ 学生无法查看成绩
- ✅ 返回取消数量

**实际结果**: [ ] 通过 / [ ] 失败

#### 测试8.6: 导出成绩（新功能）

**API测试**:
```http
GET http://localhost:8083/api/scores/1/export?format=excel
Authorization: Bearer {your_token}
```

**预期结果**:
- ✅ 成功下载Excel文件
- ✅ 文件包含所有学生成绩
- ✅ 格式正确

**实际结果**: [ ] 通过 / [ ] 失败

#### 测试8.7: 成绩统计

**测试步骤**:
1. 在成绩管理页面切换到"成绩分析"标签
2. 查看统计数据

**预期结果**:
- ✅ 显示平均分
- ✅ 显示最高分
- ✅ 显示最低分
- ✅ 显示及格率
- ✅ 显示成绩分布图（如果有）

**实际结果**: [ ] 通过 / [ ] 失败

---

## 🔍 集成测试

### 场景1: 完整的考试流程

**测试步骤**:
1. 创建题目
2. 创建试卷
3. 创建考试
4. 添加考生
5. 开始考试
6. 监考
7. 收卷
8. 阅卷
9. 发布成绩
10. 导出成绩

**预期结果**:
- ✅ 所有步骤都能顺利完成
- ✅ 数据正确传递
- ✅ 学生能看到最终成绩

**实际结果**: [ ] 通过 / [ ] 失败

---

## 📊 测试总结

### 测试统计

| 模块 | 总测试数 | 通过数 | 失败数 | 通过率 |
|------|---------|--------|--------|--------|
| 用户登录 | 1 | _ | _ | _% |
| 科目管理 | 2 | _ | _ | _% |
| 班级管理 | 3 | _ | _ | _% |
| 题库管理 | 6 | _ | _ | _% |
| 试卷管理 | 6 | _ | _ | _% |
| 考试管理 | 6 | _ | _ | _% |
| 监考功能 | 3 | _ | _ | _% |
| 成绩管理 | 7 | _ | _ | _% |
| 集成测试 | 1 | _ | _ | _% |
| **总计** | **35** | **_** | **_** | **_%** |

### 问题记录

| 问题编号 | 问题描述 | 严重程度 | 状态 | 备注 |
|---------|---------|---------|------|------|
| 1 | | | | |
| 2 | | | | |
| 3 | | | | |

### 测试结论

- [ ] ✅ 所有功能测试通过，系统可以上线
- [ ] ⚠️ 部分功能有小问题，需要修复后才能上线
- [ ] ❌ 存在严重问题，需要全面返工

### 测试人员签名

**测试人**: _______________  
**测试日期**: _______________  
**签名**: _______________

---

## 💡 测试技巧

### 获取认证令牌

1. 打开浏览器开发者工具（F12）
2. 切换到"Network"标签
3. 在网页中登录
4. 找到登录请求，查看响应中的`token`字段
5. 复制该token
6. 在API测试工具中设置请求头：
   ```
   Authorization: Bearer {token}
   ```

### 使用Postman测试

1. 创建新的Collection
2. 添加环境变量：
   - `baseUrl`: http://localhost:8083
   - `token`: {your_token}
3. 在请求中使用 `{{baseUrl}}` 和 `{{token}}`

### 查看数据库数据

```powershell
# 连接数据库
docker exec -it chaoxing-mysql mysql -uroot -proot chaoxing

# 查看科目
SELECT * FROM biz_subject;

# 查看班级
SELECT * FROM biz_class;

# 查看考试考生
SELECT * FROM biz_exam_student;

# 查看监考警告
SELECT * FROM biz_monitor_warning;

# 查看成绩调整记录
SELECT * FROM biz_score_adjustment;
```

---

**文档版本**: v1.0  
**最后更新**: 2024年12月24日

