# 🚀 快速部署参考卡片

> 打印或保存此文档，方便随时查看！

---

## 💡 修改代码后的部署命令

### ⚡ 方式一：开发模式（最快 - 热更新）
```powershell
# 开发调试时使用
.\start-dev.ps1
```
- ⚡ 启动时间：< 20 秒
- 🔥 修改代码自动刷新
- 💡 适合：频繁修改 UI

### 🚀 方式二：快速部署（推荐）
```powershell
# 日常开发时使用（推荐）
.\deploy-fast.ps1
```
- 🚀 部署时间：1-4 分钟
- 📈 速度提升 50-70%
- 💡 适合：测试功能

### 🔄 方式三：完整部署（需要时使用）
```powershell
# 首次部署或出现问题时使用
.\deploy-all.ps1
```
- 🔄 部署时间：3-13 分钟
- ✅ 完全重建
- 💡 适合：生产发布

### 对比表格

| 修改内容 | 开发模式 | 快速部署 | 完整部署 |
|---------|---------|---------|---------|
| **前端代码** | `.\start-dev.ps1` | `.\deploy-fast.ps1` | `.\deploy-all.ps1` |
| **耗时** | < 20秒 | 1-3分钟 | 1-3分钟 |
| **特点** | 热更新 | 增量构建 | 完全重建 |

---

## 📍 访问地址

- 🌐 **前端界面：** http://localhost:8080
- ⚙️ **后端API：** http://localhost:8083/api
- 🗄️ **数据库：** localhost:3306（容器内部）

---

## 🔧 常用命令

### 查看运行状态
```powershell
docker ps
```

### 查看日志
```powershell
# 前端
docker logs chaoxing-frontend

# 后端  
docker logs chaoxing-backend -f

# 数据库
docker logs chaoxing-mysql
```

### 重启服务
```powershell
# 重启前端
docker restart chaoxing-frontend

# 重启后端
docker restart chaoxing-backend

# 重启所有
docker-compose restart
```

### 停止/启动所有服务
```powershell
# 停止
docker-compose down

# 启动
docker-compose up -d
```

---

## ⚠️ 故障排查

| 问题 | 解决方案 |
|-----|---------|
| 页面显示旧内容 | 清除浏览器缓存（Ctrl+Shift+Delete）+ 硬刷新（Ctrl+F5） |
| 容器无法启动 | 查看日志：`docker logs <容器名>` |
| 端口被占用 | 修改 `docker-compose.yml` 中的端口映射 |
| 构建失败 | 检查网络连接，查看错误日志 |
| Maven构建慢 | 首次下载依赖需要时间，等待即可 |

---

## 📋 部署前检查清单

- [ ] Docker Desktop 已启动
- [ ] 已修改并保存代码文件
- [ ] 代码已在本地测试通过
- [ ] 已提交代码到 Git（可选）

---

## 🎯 快速决策树

```
我修改了什么？
├─ frontend/src/ 下的文件
│   └─ 运行：.\deploy-frontend.ps1
│
├─ backend/src/ 下的文件  
│   └─ 运行：.\deploy-backend.ps1
│
└─ 前端和后端都修改了
    └─ 运行：.\deploy-all.ps1
```

---

## 📞 紧急情况

### 所有服务都挂了？
```powershell
docker-compose down
docker-compose up -d
```

### 需要完全重置？
```powershell
# ⚠️ 警告：会删除所有数据！
docker-compose down -v
docker-compose up -d
```

---

**提示：** 将此文件保存在桌面，需要时随时查看！

**详细文档：** 查看 `DEPLOYMENT.md`

