# 🚀 部署脚本使用指南

本目录包含所有用于部署和管理应用的 PowerShell 脚本。

## 📋 脚本列表

### 核心部署脚本

#### 🔄 `deploy-all.ps1` - 完整部署（推荐首次使用）
**功能：** 完整的部署流程，包含Docker检查
- ✅ 自动检查Docker状态
- ✅ 自动启动Docker（如果未运行）
- ✅ 自动创建容器（如果不存在）
- ✅ 支持选择性部署（前端/后端/全部）

**使用场景：** 首次部署、环境重置、故障排查

```powershell
.\scripts\deploy-all.ps1
```

---

#### ⚡ `deploy-fast.ps1` - 快速部署（推荐日常使用）
**功能：** 增量构建 + 并行执行，速度提升 60-70%
- ✅ 自动检测 Docker 状态
- ✅ 自动检测 Maven（未安装时使用 Docker Maven）
- ✅ 只重新构建修改的部分
- ✅ 前后端并行构建

**使用场景：** 代码修改后的快速部署

**耗时：**
- 有本地 Maven：1-2 分钟
- 无本地 Maven：3-5 分钟（首次 7-10 分钟）

```powershell
.\scripts\deploy-fast.ps1
```

---

### 独立模块部署

#### 📦 `deploy-frontend.ps1` - 前端独立部署
**功能：** 只构建和部署前端
- ✅ Docker 状态检查
- ✅ npm install & build
- ✅ 重启前端容器

```powershell
.\scripts\deploy-frontend.ps1
```

---

#### 📦 `deploy-backend.ps1` - 后端独立部署
**功能：** 只构建和部署后端
- ✅ Docker 状态检查
- ✅ Maven 构建（支持 Docker Maven）
- ✅ 重启后端容器

```powershell
.\scripts\deploy-backend.ps1
```

---

### 测试脚本

#### 🧪 `deploy-and-test.ps1` - 部署并测试
**功能：** 自动部署后运行完整测试
- ✅ 完整部署流程
- ✅ 健康检查
- ✅ API 接口测试
- ✅ 生成测试报告

```powershell
.\scripts\deploy-and-test.ps1
```

---

## 🎯 快速选择指南

| 场景 | 推荐脚本 | 耗时 |
|------|---------|------|
| 🆕 **首次部署** | `deploy-all.ps1` | 5-15分钟 |
| 📝 **修改代码后部署** | `deploy-fast.ps1` | 1-4分钟 |
| 🐛 **出现问题** | `deploy-all.ps1` | 3-13分钟 |
| 🎨 **只改前端** | `deploy-frontend.ps1` | 1-3分钟 |
| ⚙️ **只改后端** | `deploy-backend.ps1` | 2-5分钟 |
| ✅ **部署并测试** | `deploy-and-test.ps1` | 5-20分钟 |

---

## ⚠️ 常见问题

### 问题1：Docker 未运行
**错误信息：** "Docker 未运行！请先启动 Docker Desktop"

**解决方案：**
1. 打开 Docker Desktop 应用程序
2. 等待 Docker 引擎启动（约 30-60 秒）
3. 重新运行脚本

`deploy-all.ps1` 会自动尝试启动 Docker

---

### 问题2：容器不存在
**错误信息：** "未找到 chaoxing 容器"

**解决方案：**
```powershell
# 使用 deploy-all.ps1（推荐，会自动创建）
.\scripts\deploy-all.ps1

# 或手动创建容器
docker-compose up -d --build
```

---

### 问题3：mvn 命令未找到
**解决方案：**
- 使用 `deploy-fast.ps1`（自动使用 Docker Maven）
- 或者参考文档安装 Maven

---

### 问题4：端口被占用
**解决方案：**
```powershell
# 停止所有容器
docker-compose stop

# 重新启动
.\scripts\deploy-fast.ps1
```

---

### 问题5：服务无法访问
**解决方案：**
1. 等待 1-2 分钟让服务完全启动
2. 查看日志：`docker-compose logs -f`
3. 检查容器状态：`docker ps`
4. 重启服务：`docker-compose restart`

---

## 💡 最佳实践

1. **首次使用：** `deploy-all.ps1` → 完整部署，自动检查环境
2. **日常开发：** `deploy-fast.ps1` → 快速增量部署
3. **代码提交前：** `deploy-and-test.ps1` → 自动化测试保证质量
4. **遇到问题：** `deploy-all.ps1` → 完整重新构建

## 🔄 典型工作流程

```powershell
# 1. 首次部署
.\scripts\deploy-all.ps1

# 2. 修改代码后快速部署
.\scripts\deploy-fast.ps1

# 3. 提交前测试
.\scripts\deploy-and-test.ps1

# 4. 停止系统
docker-compose stop
```

---

## 📚 更多文档

- 📖 [项目README](../README.md)
- 🎯 [部署和测试指南](../DEPLOYMENT_AND_TEST_GUIDE.md)

---

🎉 **祝您开发愉快！**




