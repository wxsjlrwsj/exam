# 🚀 部署脚本使用指南

本目录包含所有用于部署和管理应用的 PowerShell 脚本。

## 📋 脚本列表

### 开发和部署脚本

#### ⚡ `start-dev.ps1` - 开发模式（推荐开发时使用）
**功能：** 启动热更新开发环境，无需重新构建
- ✅ 前端自动热更新（< 20秒启动）
- ✅ 后端使用已构建的 jar 包
- ✅ 最快的开发体验

**使用场景：** 日常开发、前端调试、快速预览

```powershell
.\scripts\start-dev.ps1
```

---

#### 🚀 `deploy-fast.ps1` - 快速部署（推荐日常使用）
**功能：** 增量构建 + 并行执行，速度提升 60-70%
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

#### 🔄 `deploy-all.ps1` - 完整部署（推荐首次或出问题时使用）
**功能：** 完整的部署流程，支持选择性部署
- ✅ 完整重新构建
- ✅ 清理旧的构建缓存
- ✅ 交互式选择部署模块

**使用场景：** 首次部署、环境重置、故障排查

**选项：**
1. 仅部署前端
2. 仅部署后端
3. 部署前端和后端（推荐）

**耗时：** 3-13 分钟

```powershell
.\scripts\deploy-all.ps1
```

---

### 独立模块部署

#### 📦 `deploy-frontend.ps1` - 前端独立部署
**功能：** 只构建和部署前端
- ✅ npm install
- ✅ npm run build
- ✅ 重启前端容器

```powershell
.\scripts\deploy-frontend.ps1
```

---

#### 📦 `deploy-backend.ps1` - 后端独立部署
**功能：** 只构建和部署后端
- ✅ mvn clean package
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

#### ✅ `test-deployment.ps1` - 部署验证
**功能：** 验证当前部署状态
- ✅ 检查所有服务是否运行
- ✅ 测试数据库连接
- ✅ 测试 API 可访问性

```powershell
.\scripts\test-deployment.ps1
```

---

### 工具脚本

#### 🔧 `fix-script-permission.ps1` - 修复脚本权限
**功能：** 解决 Windows PowerShell 脚本执行权限问题
- ✅ 自动解除所有脚本的执行限制

**使用场景：** 首次使用或遇到权限错误时

```powershell
.\scripts\fix-script-permission.ps1
```

---

## 🎯 快速选择指南

| 场景 | 推荐脚本 | 耗时 |
|------|---------|------|
| 🔥 **开发调试** | `start-dev.ps1` | < 20秒 |
| 📝 **修改代码后部署** | `deploy-fast.ps1` | 1-4分钟 |
| 🆕 **首次部署** | `deploy-all.ps1` | 3-13分钟 |
| 🐛 **出现问题** | `deploy-all.ps1` | 3-13分钟 |
| ✅ **验证部署** | `test-deployment.ps1` | < 1分钟 |
| 🎨 **只改前端** | `deploy-frontend.ps1` | 1-3分钟 |
| ⚙️ **只改后端** | `deploy-backend.ps1` | 2-5分钟 |

---

## ⚠️ 常见问题

### 问题1：脚本无法执行，提示权限错误
**解决方案：**
```powershell
.\scripts\fix-script-permission.ps1
```

### 问题2：mvn 命令未找到
**解决方案：**
- 使用 `deploy-fast.ps1`（自动使用 Docker Maven）
- 或者参考 `docs/guides/MAVEN-SETUP.md` 安装 Maven

### 问题3：Docker 容器启动失败
**解决方案：**
1. 检查 Docker Desktop 是否运行
2. 运行 `docker ps` 查看容器状态
3. 运行 `docker-compose logs` 查看日志

### 问题4：端口被占用
**解决方案：**
```powershell
# 停止所有容器
docker-compose down

# 重新启动
.\scripts\deploy-fast.ps1
```

---

## 📚 更多文档

- 📖 [完整部署指南](../docs/deployment/DEPLOYMENT.md)
- ⚡ [性能优化指南](../docs/guides/PERFORMANCE-GUIDE.md)
- 📋 [快速参考卡片](../docs/guides/QUICK-START.md)
- 🔧 [Maven 安装配置](../docs/guides/MAVEN-SETUP.md)

---

## 💡 提示

1. **开发时始终使用 `start-dev.ps1`** - 最快的开发体验
2. **代码提交前使用 `deploy-fast.ps1`** - 确保完整构建通过
3. **部署到生产前使用 `deploy-and-test.ps1`** - 自动化测试保证质量
4. **遇到问题时使用 `deploy-all.ps1`** - 完整重新构建解决大部分问题

---

🎉 **祝您开发愉快！**


