# 部署指南

本文档说明如何在修改代码后重新部署前后端应用。

## 📋 前提条件

- ✅ Docker Desktop 已启动
- ✅ 已成功运行过 `docker-compose up -d`
- ✅ Node.js 已安装（前端部署需要）
- ⚠️ Maven 已安装（后端部署可选，未安装会自动使用 Docker 构建）

---

## 🚀 快速开始

### 方案一：一键部署（推荐）

```powershell
# 在 exam 目录下执行
.\deploy-all.ps1
```

然后根据提示选择：
- `1` - 仅部署前端
- `2` - 仅部署后端
- `3` - 同时部署前后端（推荐）

### 方案二：分别部署

#### 仅部署前端
```powershell
.\deploy-frontend.ps1
```

#### 仅部署后端
```powershell
.\deploy-backend.ps1
```

---

## 📝 详细说明

### 前端部署流程

**何时使用：** 修改了 `frontend/src/` 下的任何文件

**执行步骤：**
```powershell
cd C:\Users\34445\Desktop\chaoxin\exam
.\deploy-frontend.ps1
```

**流程说明：**
1. 运行 `npm run build` 构建前端项目
2. 生成新的 `dist` 目录
3. 重启 `chaoxing-frontend` 容器
4. 容器会自动加载新的 `dist` 内容（因为已挂载）

**预计耗时：** 1-3 分钟

---

### 后端部署流程

**何时使用：** 修改了 `backend/src/` 下的任何文件

**执行步骤：**
```powershell
cd C:\Users\34445\Desktop\chaoxin\exam
.\deploy-backend.ps1
```

**流程说明：**
1. 使用 Maven 构建项目（生成 `.jar` 文件）
2. 将新的 JAR 文件复制到容器内
3. 重启 `chaoxing-backend` 容器
4. 等待 Spring Boot 应用启动（约10秒）

**预计耗时：** 2-5 分钟（首次构建可能更久）

---

## ⚠️ 常见问题

### Q0: 运行脚本时提示 "cannot be loaded because running scripts is disabled"
**原因：** Windows 安全策略阻止了脚本执行  
**解决方案：**
```powershell
# 方法1：运行修复脚本（最简单）
.\fix-script-permission.ps1

# 方法2：手动解除阻止
Unblock-File -Path .\deploy-all.ps1
Unblock-File -Path .\deploy-frontend.ps1
Unblock-File -Path .\deploy-backend.ps1

# 方法3：临时绕过（每次都需要）
powershell -ExecutionPolicy Bypass -File .\deploy-all.ps1
```

### Q1: 前端部署失败，提示 `npm` 命令找不到
**解决：** 确保已安装 Node.js，并将其添加到系统环境变量

### Q2: 后端构建时间很长
**原因：** Maven 首次下载依赖需要时间  
**解决：** 耐心等待，后续构建会快很多

### Q3: 修改了配置文件（如 application.yml）需要重新部署吗？
**回答：** 
- 如果只修改了配置值，运行 `.\deploy-backend.ps1` 即可
- 如果修改了 `docker-compose.yml`，需要运行 `docker-compose up -d`

### Q4: 如何查看部署日志？
```powershell
# 查看前端日志
docker logs chaoxing-frontend

# 查看后端日志
docker logs chaoxing-backend -f

# 查看所有服务状态
docker ps
```

### Q5: 部署后访问页面显示 404 或旧内容
**解决：**
1. 清除浏览器缓存（Ctrl + Shift + Delete）
2. 硬刷新页面（Ctrl + F5）
3. 检查容器是否正常运行：`docker ps`

---

## 🔍 验证部署

### 检查服务状态
```powershell
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

### 访问测试
- **前端：** http://localhost:8080
- **后端健康检查：** http://localhost:8083/actuator/health（如果配置了）
- **后端API：** http://localhost:8083/api/

### 查看实时日志
```powershell
# 前端日志
docker logs -f chaoxing-frontend

# 后端日志（查看启动信息）
docker logs -f chaoxing-backend
```

---

## 🛠️ 高级操作

### 完全重建（网络正常时）
如果网络恢复正常，可以完全重建镜像：
```powershell
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### 清理旧数据
```powershell
# 停止所有容器
docker-compose down

# 删除数据库数据（谨慎使用！）
docker volume rm chaoxing-system_mysql_data

# 重新启动
docker-compose up -d
```

### 导出/导入镜像（离线部署）
```powershell
# 导出镜像
docker save chaoxing-system-frontend:latest -o frontend-image.tar
docker save chaoxing-system-backend:latest -o backend-image.tar

# 在另一台机器上导入
docker load -i frontend-image.tar
docker load -i backend-image.tar
```

---

## 📊 部署流程图

```
修改代码
    ↓
确定修改的部分
    ↓
    ├─ 前端代码？ → 运行 deploy-frontend.ps1 → 访问 localhost:8080 测试
    ├─ 后端代码？ → 运行 deploy-backend.ps1 → 访问 localhost:8083 测试
    └─ 前端+后端？→ 运行 deploy-all.ps1 → 完整测试
```

---

## 🎯 最佳实践

1. ✅ **每次修改后都要测试** - 在本地测试通过后再部署
2. ✅ **查看日志** - 部署后检查日志确保无错误
3. ✅ **增量部署** - 前端和后端分开部署，减少部署时间
4. ✅ **版本控制** - 每次部署前提交代码到 Git
5. ✅ **备份数据** - 重要操作前备份数据库

---

## 📞 获取帮助

如果遇到问题：
1. 查看容器日志：`docker logs <container-name>`
2. 检查容器状态：`docker ps -a`
3. 重启 Docker Desktop
4. 查看本文档的"常见问题"部分

---

**最后更新：** 2025-12-24
**版本：** 1.0.0

