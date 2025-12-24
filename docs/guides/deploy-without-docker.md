# 不依赖 Docker 的部署方案

如果您希望完全脱离 Docker 运行应用，可以按照以下方案部署。

---

## 📋 前提条件

### 必须安装：
1. ✅ **Node.js 20+** - 用于前端构建和运行
2. ✅ **JDK 17** - 用于后端运行
3. ✅ **Maven 3.8+** - 用于后端构建
4. ✅ **MySQL 8.0** - 数据库服务器

### 可选安装：
- ✅ **Nginx** - 前端部署（或使用其他 Web 服务器）

---

## 🚀 部署步骤

### 第一步：安装 MySQL

#### Windows:
1. 下载 MySQL 8.0: https://dev.mysql.com/downloads/mysql/
2. 安装并启动 MySQL 服务
3. 创建数据库：
```sql
CREATE DATABASE chaoxing CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

4. 导入数据：
```bash
mysql -u root -p chaoxing < backend/src/main/resources/schema.sql
mysql -u root -p chaoxing < backend/src/main/resources/seed.sql
```

---

### 第二步：配置后端

1. 修改 `backend/src/main/resources/application.yml`：

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/chaoxing?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true&useUnicode=true&characterEncoding=UTF-8
    username: root
    password: 你的MySQL密码
    driver-class-name: com.mysql.cj.jdbc.Driver
  
  mail:
    host: smtp.qq.com
    port: 587
    username: 3444505236@qq.com
    password: jxtzdnobgylpchhc

server:
  port: 8083

security:
  token:
    secret: change-me-prod
  cors:
    allowed-origins: http://localhost:8080,http://localhost:5173
```

2. 构建后端：
```powershell
cd backend
mvn clean package -DskipTests
```

3. 运行后端：
```powershell
java -jar target/backend.jar
```

或者创建启动脚本 `start-backend.ps1`：
```powershell
cd backend
java -jar target/backend.jar
```

---

### 第三步：部署前端

#### 方案 A：使用 Nginx（推荐）

1. 安装 Nginx: http://nginx.org/en/download.html

2. 构建前端：
```powershell
cd frontend
npm install
npm run build
```

3. 配置 Nginx（`nginx.conf`）：
```nginx
server {
    listen 8080;
    server_name localhost;
    root C:/Users/34445/Desktop/chaoxin/exam/frontend/dist;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /api/ {
        proxy_pass http://localhost:8083/api/;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

4. 启动 Nginx

---

#### 方案 B：使用 Node.js 服务器（开发用）

1. 安装 `serve`：
```powershell
npm install -g serve
```

2. 运行：
```powershell
cd frontend
npm run build
serve -s dist -l 8080
```

**⚠️ 注意：** 需要另外配置 API 代理

---

#### 方案 C：使用 Vite 开发服务器

1. 修改 `frontend/vite.config.js` 添加代理：
```javascript
export default defineConfig({
  plugins: [vue()],
  server: {
    port: 8080,
    proxy: {
      '/api': {
        target: 'http://localhost:8083',
        changeOrigin: true
      }
    }
  }
})
```

2. 运行：
```powershell
cd frontend
npm run dev
```

---

## 📜 创建启动脚本

### start-backend.ps1
```powershell
# 启动后端
Write-Host "启动后端服务..." -ForegroundColor Cyan
cd backend
java -jar target/backend.jar
```

### start-frontend.ps1
```powershell
# 启动前端（开发模式）
Write-Host "启动前端服务..." -ForegroundColor Cyan
cd frontend
npm run dev
```

### start-all.ps1
```powershell
# 同时启动前后端
Write-Host "启动所有服务..." -ForegroundColor Cyan

# 启动后端（后台运行）
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd backend; java -jar target/backend.jar"

# 等待后端启动
Start-Sleep -Seconds 5

# 启动前端
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd frontend; npm run dev"

Write-Host "`n✓ 所有服务已启动！" -ForegroundColor Green
Write-Host "前端: http://localhost:8080" -ForegroundColor Yellow
Write-Host "后端: http://localhost:8083" -ForegroundColor Yellow
```

---

## 🔄 日常开发流程

### 修改前端代码后：
```powershell
cd frontend
npm run build  # 如果用生产模式
# 或
npm run dev    # 如果用开发模式（自动热更新）
```

### 修改后端代码后：
```powershell
cd backend
mvn clean package -DskipTests
# 停止之前的 Java 进程
java -jar target/backend.jar
```

---

## 📊 两种方案对比

| 特性 | Docker 方案 | 无 Docker 方案 |
|------|-------------|----------------|
| **环境一致性** | ✅ 优秀 | ⚠️ 依赖本地环境 |
| **部署复杂度** | ✅ 简单（一条命令） | ⚠️ 需要多步配置 |
| **资源占用** | ⚠️ 较高 | ✅ 较低 |
| **启动速度** | ⚠️ 较慢 | ✅ 快速 |
| **跨平台** | ✅ 完美 | ⚠️ 需要分别配置 |
| **开发热更新** | ⚠️ 需要重启容器 | ✅ 支持（开发模式） |
| **生产部署** | ✅ 推荐 | ⚠️ 不推荐 |
| **学习成本** | ⚠️ 需要学习 Docker | ✅ 传统方式 |

---

## 💡 建议

### 推荐使用 Docker 的场景：
- ✅ 生产环境部署
- ✅ 团队协作（环境一致）
- ✅ 快速部署
- ✅ 多服务管理

### 推荐不用 Docker 的场景：
- ✅ 开发调试（需要热更新）
- ✅ 资源受限的机器
- ✅ 学习阶段
- ✅ 简单的单机部署

---

## 🎯 混合方案（推荐）

最佳实践是**混合使用**：

```
开发阶段：
  - 数据库：Docker（方便管理）
  - 后端：本地运行（方便调试）
  - 前端：npm run dev（热更新）

生产部署：
  - 全部使用 Docker（一键部署）
```

---

**总结：** Docker 主要用于**运行环境**，构建可以在本地完成。完全不用 Docker 也可以，但会增加配置复杂度。

