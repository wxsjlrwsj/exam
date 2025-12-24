# 🎓 超星考试系统

一个功能完善的在线考试管理系统，支持学生、教师、管理员三种角色。

## ✨ 主要功能

### 👨‍🎓 学生端
- 在线考试
- 成绩查询
- 错题集
- 个性化题库
- 练习模式

### 👨‍🏫 教师端
- 考试管理
- 试卷管理
- 题库管理
- 成绩录入与查询
- 数据统计分析

### 👨‍💼 管理员端
- 用户管理
- 角色权限管理
- 组织架构管理
- 系统功能模块管理
- 操作日志审计

---

## 🏗️ 技术栈

### 后端
- **框架：** Spring Boot 3.3.4
- **数据库：** MySQL 8.0
- **ORM：** MyBatis
- **构建工具：** Maven
- **认证：** JWT Token
- **邮件：** Spring Mail (QQ邮箱)

### 前端
- **框架：** Vue.js 3
- **构建工具：** Vite
- **UI组件：** Element Plus
- **HTTP客户端：** Axios
- **路由：** Vue Router

### 部署
- **容器化：** Docker + Docker Compose
- **Web服务器：** Nginx
- **JDK：** Eclipse Temurin 17

---

## 🚀 快速开始

### 前置要求

- **Docker Desktop** - 已安装并运行
- **Git** - 版本控制
- **PowerShell** - Windows 脚本执行（Windows 自带）

### 一键启动

```powershell
# 1. 克隆项目
git clone https://github.com/wxsjlrwsj/exam.git
cd exam

# 2. 解除脚本执行限制（仅首次需要）
.\scripts\fix-script-permission.ps1

# 3. 启动开发环境（推荐）
.\scripts\start-dev.ps1

# 或完整部署
.\scripts\deploy-fast.ps1
```

### 访问地址

- **前端界面：** http://localhost:8080
- **后端API：** http://localhost:8083

### 测试账号

#### 学生账号
- 用户名：`student1` / 密码：`123456`
- 用户名：`student2` / 密码：`123456`

#### 教师账号
- 用户名：`teacher1` / 密码：`123456`
- 用户名：`teacher2` / 密码：`123456`

#### 管理员账号
- 用户名：`admin1` / 密码：`123456`

---

## 📁 项目结构

```
exam/
├── backend/                    # 后端项目
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/
│   │   │   │   └── org/example/chaoxingsystem/
│   │   │   │       ├── common/           # 通用模块（班级、学科）
│   │   │   │       ├── config/           # 配置类
│   │   │   │       ├── security/         # 安全认证
│   │   │   │       ├── user/             # 用户模块
│   │   │   │       ├── teacher/          # 教师模块
│   │   │   │       │   ├── exam/         # 考试管理
│   │   │   │       │   ├── paper/        # 试卷管理
│   │   │   │       │   └── score/        # 成绩管理
│   │   │   │       ├── student/          # 学生模块
│   │   │   │       └── admin/            # 管理员模块
│   │   │   └── resources/
│   │   │       ├── mapper/               # MyBatis XML
│   │   │       ├── application.yml       # 主配置文件
│   │   │       ├── schema.sql            # 数据库结构
│   │   │       └── seed.sql              # 初始数据
│   │   └── test/                         # 测试代码
│   ├── pom.xml                           # Maven配置
│   └── Dockerfile                        # 后端Docker构建
│
├── frontend/                   # 前端项目
│   ├── src/
│   │   ├── api/                # API接口
│   │   ├── components/         # 公共组件
│   │   ├── router/             # 路由配置
│   │   ├── utils/              # 工具函数
│   │   ├── views/              # 页面组件
│   │   │   ├── admin/          # 管理员页面
│   │   │   ├── teacher/        # 教师页面
│   │   │   ├── student/        # 学生页面
│   │   │   └── common/         # 公共页面
│   │   ├── App.vue             # 根组件
│   │   └── main.js             # 入口文件
│   ├── public/                 # 静态资源
│   ├── package.json            # npm配置
│   ├── vite.config.js          # Vite配置
│   ├── nginx.conf              # Nginx配置
│   └── Dockerfile              # 前端Docker构建
│
├── scripts/                    # 部署脚本
│   ├── start-dev.ps1           # 开发模式（< 20秒）
│   ├── deploy-fast.ps1         # 快速部署（1-4分钟）
│   ├── deploy-all.ps1          # 完整部署（3-13分钟）
│   ├── deploy-frontend.ps1     # 前端独立部署
│   ├── deploy-backend.ps1      # 后端独立部署
│   ├── deploy-and-test.ps1     # 部署并测试
│   ├── test-deployment.ps1     # 部署验证
│   ├── fix-script-permission.ps1  # 权限修复
│   └── README.md               # 脚本使用指南
│
├── docs/                       # 项目文档
│   ├── deployment/             # 部署相关
│   │   ├── DEPLOYMENT.md       # 完整部署指南
│   │   ├── DEPLOYMENT_CHECKLIST.md
│   │   ├── DEPLOYMENT_REPORT.md
│   │   └── ...
│   ├── api/                    # API文档
│   │   └── API_SPECS.md        # API规范
│   └── guides/                 # 使用指南
│       ├── QUICK-START.md      # 快速参考
│       ├── PERFORMANCE-GUIDE.md # 性能优化
│       ├── MAVEN-SETUP.md      # Maven配置
│       └── ...
│
├── docker-compose.yml          # Docker编排配置
└── README.md                   # 本文件
```

---

## 📖 详细文档

### 部署文档
- 📘 [完整部署指南](docs/deployment/DEPLOYMENT.md)
- ✅ [部署检查清单](docs/deployment/DEPLOYMENT_CHECKLIST.md)
- 🔧 [问题排查指南](docs/deployment/DEPLOYMENT_ISSUES_AND_SOLUTIONS.md)

### 使用指南
- ⚡ [快速开始](docs/guides/QUICK-START.md)
- 🚀 [性能优化指南](docs/guides/PERFORMANCE-GUIDE.md)
- 🔧 [Maven 安装配置](docs/guides/MAVEN-SETUP.md)
- 🐳 [无Docker部署方案](docs/guides/deploy-without-docker.md)
- 📝 [验收测试指南](docs/guides/ACCEPTANCE_TEST_GUIDE.md)

### API文档
- 📚 [API 接口规范](docs/api/API_SPECS.md)

### 脚本文档
- 🚀 [脚本使用指南](scripts/README.md)

---

## 🛠️ 开发指南

### 修改代码后的部署流程

#### 1. 开发阶段（推荐）
```powershell
# 启动开发模式，支持热更新
.\scripts\start-dev.ps1
```

#### 2. 测试阶段
```powershell
# 快速部署验证
.\scripts\deploy-fast.ps1
```

#### 3. 生产部署
```powershell
# 完整部署并测试
.\scripts\deploy-and-test.ps1
```

### 常用命令

```powershell
# 查看所有容器状态
docker ps

# 查看容器日志
docker-compose logs -f [service_name]
# 例如: docker-compose logs -f backend

# 停止所有服务
docker-compose down

# 重启单个服务
docker-compose restart [service_name]
# 例如: docker-compose restart frontend

# 进入容器内部
docker exec -it [container_name] /bin/bash
```

---

## 🎯 部署速度对比

| 场景 | 脚本 | 耗时 | 提升 |
|------|------|------|------|
| 开发调试 | `start-dev.ps1` | < 20秒 | 🚀 **99%** |
| 日常部署 | `deploy-fast.ps1` | 1-4分钟 | ⚡ **60-70%** |
| 完整部署 | `deploy-all.ps1` | 3-13分钟 | ✅ 稳定性保证 |

---

## 🔧 配置说明

### 数据库配置
在 `docker-compose.yml` 中修改：
```yaml
environment:
  MYSQL_ROOT_PASSWORD: root
  MYSQL_DATABASE: chaoxing
```

### 后端配置
在 `backend/src/main/resources/application.yml` 中修改：
```yaml
spring:
  datasource:
    url: jdbc:mysql://mysql:3306/chaoxing
    username: root
    password: root
  
  mail:
    username: your_qq_email@qq.com
    password: your_authorization_code
```

### 前端配置
在 `frontend/vite.config.js` 中修改：
```javascript
server: {
  host: '0.0.0.0',
  port: 5173
}
```

---

## 🐛 常见问题

### 1. 脚本无法执行
**错误：** `无法加载文件，因为在此系统上禁止运行脚本`

**解决方案：**
```powershell
.\scripts\fix-script-permission.ps1
```

### 2. Maven 命令未找到
**错误：** `mvn: 无法识别为 cmdlet、函数、脚本文件或可运行程序`

**解决方案：**
- 使用 `deploy-fast.ps1`（自动使用 Docker Maven）
- 或参考 [Maven安装指南](docs/guides/MAVEN-SETUP.md)

### 3. 端口被占用
**错误：** `Bind for 0.0.0.0:8080 failed: port is already allocated`

**解决方案：**
```powershell
# 停止所有容器
docker-compose down

# 检查端口占用
netstat -ano | findstr "8080"

# 重新启动
.\scripts\deploy-fast.ps1
```

### 4. 前端白屏
**可能原因：**
- 后端服务未启动
- API 请求跨域
- 路由配置错误

**解决方案：**
```powershell
# 查看容器日志
docker-compose logs -f frontend
docker-compose logs -f backend

# 重新部署
.\scripts\deploy-all.ps1
```

---

## 🤝 贡献指南

欢迎提交 Issue 和 Pull Request！

### 提交代码流程
1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

---

## 📝 更新日志

### v2.0.0 (2024-12-24)
- ✅ 新增教师功能模块（考试、试卷、成绩管理）
- ✅ 新增班级和学科管理
- ✅ 优化部署流程，提升 60-99% 速度
- ✅ 完善文档系统
- ✅ 新增自动化测试脚本

### v1.0.0 (2024-12)
- ✅ 基础功能实现
- ✅ 用户认证与授权
- ✅ QQ邮箱验证注册
- ✅ Docker 容器化部署

---

## 📄 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件

---

## 👥 联系方式

- **GitHub仓库：** https://github.com/wxsjlrwsj/exam
- **问题反馈：** 请在 GitHub Issues 中提交

---

## 🙏 致谢

感谢所有为这个项目做出贡献的开发者！

---

<div align="center">

**⭐ 如果这个项目对您有帮助，请给一个 Star！⭐**

Made with ❤️ by ChaoxingTeam

</div>


