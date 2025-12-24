# 部署问题检查与解决方案

本文档记录了部署过程中遇到的问题及解决方案，以及潜在的问题和预防措施。

---

## ✅ 已解决的问题

### 问题1: SQL语法错误 - ALTER TABLE ADD COLUMN IF NOT EXISTS

**问题描述**:
```sql
ERROR 1064 (42000): You have an error in your SQL syntax
```

在执行数据库迁移脚本时，MySQL 8.0不支持`ALTER TABLE ... ADD COLUMN IF NOT EXISTS`语法。

**原始代码**:
```sql
ALTER TABLE biz_exam_record ADD COLUMN IF NOT EXISTS progress INT DEFAULT 0;
```

**错误原因**:
MySQL的`IF NOT EXISTS`语法只能用于`CREATE TABLE`，不能用于`ALTER TABLE ADD COLUMN`。

**解决方案**:
使用存储过程来实现条件性添加字段：

```sql
DELIMITER $$

DROP PROCEDURE IF EXISTS add_progress_column$$
CREATE PROCEDURE add_progress_column()
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = DATABASE() 
        AND table_name = 'biz_exam_record' 
        AND column_name = 'progress'
    ) THEN
        ALTER TABLE biz_exam_record ADD COLUMN progress INT DEFAULT 0 COMMENT '答题进度（百分比）';
    END IF;
END$$

DELIMITER ;

CALL add_progress_column();
DROP PROCEDURE IF EXISTS add_progress_column;
```

**修复文件**: `exam/backend/db_migration_teacher.sql`

**验证方法**:
```powershell
# 检查字段是否已添加
docker exec chaoxing-mysql mysql -uroot -proot chaoxing -e "DESC biz_exam_record;"
```

**状态**: ✅ 已解决并验证

---

### 问题2: API返回403 Forbidden

**问题描述**:
测试API时返回403状态码。

**现象**:
```powershell
Invoke-WebRequest : 远程服务器返回错误: (403) 已禁止。
```

**原因分析**:
1. 这是**正常现象**，不是问题
2. 大部分API需要用户认证（JWT令牌）
3. Spring Security配置要求用户必须登录才能访问这些接口

**解决方案**:
需要先登录获取令牌：

```http
POST http://localhost:8083/api/auth/login
Content-Type: application/json

{
  "username": "teacher",
  "password": "your_password"
}
```

然后在后续请求中携带令牌：

```http
GET http://localhost:8083/api/subjects
Authorization: Bearer {your_token}
```

**状态**: ℹ️ 正常现象，不需要修复

---

### 问题3: Docker容器未挂载迁移脚本

**问题描述**:
新的数据库迁移脚本未被自动执行。

**原因**:
原始`docker-compose.yml`中没有挂载`db_migration_teacher.sql`文件。

**解决方案**:
修改`docker-compose.yml`，添加迁移脚本挂载：

```yaml
volumes:
  - mysql_data:/var/lib/mysql
  - ./backend/src/main/resources/schema.sql:/docker-entrypoint-initdb.d/01-schema.sql:ro
  - ./backend/src/main/resources/seed.sql:/docker-entrypoint-initdb.d/02-seed.sql:ro
  - ./backend/db_migration_teacher.sql:/docker-entrypoint-initdb.d/03-teacher-migration.sql:ro  # 新增
```

**注意**:
- `/docker-entrypoint-initdb.d/`目录中的SQL脚本只在容器**首次启动**时执行
- 如果容器已经存在，需要手动执行迁移脚本或删除数据卷重新创建

**手动执行迁移**:
```powershell
Get-Content backend/db_migration_teacher.sql | docker exec -i chaoxing-mysql mysql -uroot -proot chaoxing
```

**状态**: ✅ 已解决

---

## ⚠️ 潜在问题与预防

### 问题4: 数据库字符集问题（中文乱码）

**可能现象**:
- 数据库中的中文显示为`???`
- 插入中文数据失败

**原因**:
数据库或表的字符集不是UTF-8。

**预防措施**:
1. 确认数据库字符集：
```sql
SHOW VARIABLES LIKE 'character_set%';
```

2. 确认表字符集：
```sql
SHOW CREATE TABLE biz_subject;
```

3. 如果需要，修改字符集：
```sql
ALTER DATABASE chaoxing CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE biz_subject CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

**当前状态**: 
- docker-compose.yml已配置: `--character-set-server=utf8mb4`
- 应该不会出现此问题

**验证方法**:
```powershell
docker exec chaoxing-mysql mysql -uroot -proot chaoxing -e "SELECT name FROM biz_subject LIMIT 1;"
```

---

### 问题5: 端口冲突

**可能现象**:
- Docker容器启动失败
- 错误信息：`bind: address already in use`

**原因**:
系统中已有程序占用了8080、8083或3306端口。

**检查方法**:
```powershell
# Windows
netstat -ano | findstr "8080"
netstat -ano | findstr "8083"
netstat -ano | findstr "3306"

# 查看占用端口的进程
tasklist | findstr "PID"
```

**解决方案**:
1. **方案A**: 停止占用端口的程序
2. **方案B**: 修改docker-compose.yml中的端口映射

```yaml
ports:
  - "8090:8080"  # 前端改为8090
  - "8093:8083"  # 后端改为8093
```

**当前状态**: ✅ 测试时未发现端口冲突

---

### 问题6: 内存不足

**可能现象**:
- Docker容器异常退出
- 后端服务启动缓慢或失败
- OOM (Out of Memory) 错误

**检查方法**:
```powershell
docker stats --no-stream
```

**解决方案**:
1. 增加Docker的内存限制（Docker Desktop设置）
2. 优化Java堆内存设置：

在`docker-compose.yml`中：
```yaml
backend:
  environment:
    JAVA_OPTS: "-Xms256m -Xmx512m"
```

**推荐配置**:
- 最小：4GB RAM
- 推荐：8GB RAM

**当前状态**: 需要根据实际情况监控

---

### 问题7: 数据库连接超时

**可能现象**:
- 后端启动失败
- 错误信息：`Could not open connection`

**原因**:
1. MySQL初始化需要时间
2. 后端启动太快，MySQL还未就绪

**解决方案**:
docker-compose.yml已配置健康检查：

```yaml
backend:
  depends_on:
    mysql:
      condition: service_healthy
```

MySQL健康检查配置：
```yaml
mysql:
  healthcheck:
    test: ["CMD", "mysqladmin", "ping", "-h", "localhost", "-proot"]
    interval: 10s
    timeout: 5s
    retries: 10
```

**如果仍然失败**:
1. 增加健康检查重试次数
2. 手动重启后端：
```powershell
docker-compose restart backend
```

**当前状态**: ✅ 已配置健康检查

---

### 问题8: 外键约束冲突

**可能现象**:
- 插入数据失败
- 错误信息：`Cannot add or update a child row: a foreign key constraint fails`

**原因**:
尝试插入的数据引用了不存在的外键值。

**示例**:
```sql
-- 尝试添加考生到不存在的考试
INSERT INTO biz_exam_student (exam_id, student_id) VALUES (999, 1);
-- 错误：exam_id=999 不存在
```

**预防措施**:
1. 在业务逻辑中先验证关联数据是否存在
2. 使用事务处理相关操作
3. 提供清晰的错误提示

**在代码中的实现**:
```java
@Transactional
public void addStudentsToExam(Long examId, List<Long> studentIds) {
    // 1. 验证考试是否存在
    Exam exam = examMapper.selectById(examId);
    if (exam == null) {
        throw new BusinessException("考试不存在");
    }
    
    // 2. 验证学生是否存在
    // ... 验证逻辑
    
    // 3. 添加关联
    // ... 添加逻辑
}
```

**当前状态**: ✅ 代码中已有基本验证

---

### 问题9: 缓存问题（前端）

**可能现象**:
- 修改代码后，浏览器看不到变化
- 前端显示旧版本内容

**原因**:
浏览器缓存了旧的静态文件。

**解决方案**:
1. **开发环境**: 强制刷新（Ctrl + F5）
2. **生产环境**: 在构建配置中添加版本号或哈希

vite.config.js:
```javascript
export default {
  build: {
    rollupOptions: {
      output: {
        entryFileNames: '[name].[hash].js',
        chunkFileNames: '[name].[hash].js',
        assetFileNames: '[name].[hash].[ext]'
      }
    }
  }
}
```

**当前状态**: Vite已自动处理文件哈希

---

### 问题10: CORS跨域问题

**可能现象**:
- 前端无法调用后端API
- 浏览器控制台错误：`CORS policy: No 'Access-Control-Allow-Origin' header`

**原因**:
后端未正确配置CORS。

**检查CORS配置**:
查看`docker-compose.yml`中的环境变量：

```yaml
SECURITY_CORS_ALLOWED_ORIGINS: http://localhost:8080,http://localhost:5173
```

**如果前端地址改变**:
需要更新此配置，例如：
```yaml
SECURITY_CORS_ALLOWED_ORIGINS: http://localhost:8090,http://192.168.1.100:8080
```

**开发环境临时解决**:
可以允许所有来源（不推荐用于生产）：
```yaml
SECURITY_CORS_ALLOWED_ORIGINS: "*"
```

**当前状态**: ✅ 已配置常用端口

---

## 🔍 问题诊断流程

### 步骤1: 检查服务状态

```powershell
# 查看所有容器
docker ps -a --filter "name=chaoxing"

# 检查容器日志
docker logs chaoxing-backend --tail 50
docker logs chaoxing-mysql --tail 50
docker logs chaoxing-frontend --tail 50
```

### 步骤2: 检查网络连接

```powershell
# 测试前端
Invoke-WebRequest http://localhost:8080

# 测试后端
Invoke-WebRequest http://localhost:8083/api/subjects
```

### 步骤3: 检查数据库

```powershell
# 连接数据库
docker exec -it chaoxing-mysql mysql -uroot -proot chaoxing

# 检查表
SHOW TABLES;

# 检查数据
SELECT COUNT(*) FROM biz_subject;
```

### 步骤4: 检查应用日志

```powershell
# 实时查看日志
docker logs -f chaoxing-backend

# 查找错误
docker logs chaoxing-backend 2>&1 | Select-String -Pattern "ERROR"
```

### 步骤5: 重启服务

```powershell
# 重启单个服务
docker-compose restart backend

# 重启所有服务
docker-compose restart

# 完全重建
docker-compose down
docker-compose up -d
```

---

## 📊 问题统计

### 问题严重程度分类

| 严重程度 | 数量 | 描述 |
|---------|------|------|
| 🔴 严重 | 1 | SQL语法错误（已解决） |
| 🟡 中等 | 0 | 无 |
| 🟢 轻微 | 2 | API认证、容器挂载（已解决） |
| ℹ️ 提示 | 7 | 潜在问题的预防措施 |

### 问题来源分析

| 来源 | 问题数 | 占比 |
|------|--------|------|
| 数据库 | 3 | 30% |
| 配置 | 3 | 30% |
| 网络 | 2 | 20% |
| 资源 | 1 | 10% |
| 前端 | 1 | 10% |

---

## ✅ 部署后检查清单

部署完成后，请逐项检查：

- [x] MySQL容器运行正常
- [x] 后端容器运行正常
- [x] 前端容器运行正常
- [x] 所有新表已创建
- [x] 初始数据已插入
- [x] 前端可以访问
- [x] 后端API可以响应
- [x] 无严重错误日志
- [ ] 教师可以登录
- [ ] 可以创建考试
- [ ] 可以查看班级
- [ ] 监考功能正常
- [ ] 成绩管理正常

---

## 📞 获取帮助

### 查看文档
1. `DEPLOYMENT_REPORT.md` - 部署报告
2. `DEPLOYMENT_CHECKLIST.md` - 部署检查清单
3. `ACCEPTANCE_TEST_GUIDE.md` - 验收测试指南
4. `TEACHER_API_IMPLEMENTATION.md` - API文档

### 查看日志
```powershell
# 后端日志
docker logs chaoxing-backend

# MySQL日志
docker logs chaoxing-mysql

# 前端日志（Nginx）
docker logs chaoxing-frontend
```

### 数据库调试
```powershell
# 连接数据库
docker exec -it chaoxing-mysql mysql -uroot -proot chaoxing

# 查看表结构
DESC biz_subject;

# 查看数据
SELECT * FROM biz_subject;

# 查看外键约束
SELECT * FROM information_schema.key_column_usage 
WHERE table_schema = 'chaoxing' AND table_name = 'biz_exam_student';
```

### 重置系统
如果遇到无法解决的问题，可以完全重置：

```powershell
# 停止所有服务
docker-compose down

# 删除数据卷（警告：会清除所有数据）
docker volume rm chaoxing-system_mysql_data

# 重新启动
docker-compose up -d

# 等待初始化完成（约50秒）
Start-Sleep -Seconds 50

# 手动执行迁移脚本
Get-Content backend/db_migration_teacher.sql | docker exec -i chaoxing-mysql mysql -uroot -proot chaoxing

# 重启后端
docker-compose restart backend
```

---

## 📝 问题反馈模板

如果遇到新问题，请按以下格式记录：

```markdown
### 问题标题

**问题描述**:
[详细描述问题现象]

**复现步骤**:
1. 步骤1
2. 步骤2
3. 步骤3

**期望结果**:
[应该发生什么]

**实际结果**:
[实际发生了什么]

**错误信息**:
```
[错误日志或截图]
```

**环境信息**:
- 操作系统: Windows/Linux/Mac
- Docker版本: 
- 浏览器: 

**已尝试的解决方案**:
1. 尝试1：结果
2. 尝试2：结果
```

---

**文档版本**: v1.0  
**最后更新**: 2024年12月24日  
**维护者**: 开发团队

