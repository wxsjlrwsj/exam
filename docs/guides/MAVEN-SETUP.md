# Maven 安装和配置指南

## 问题说明

如果您看到 `The term 'mvn' is not recognized` 错误，说明系统没有安装 Maven 或 Maven 未添加到环境变量。

---

## 🎯 三种解决方案

### 方案一：使用 Docker Maven（推荐，已自动集成）

**优点：** ✅ 无需安装，脚本会自动使用  
**缺点：** ⚠️ 首次使用需要下载镜像（约 5 分钟）

**操作：** 无需任何操作！脚本已经自动集成此功能。

当检测到没有 Maven 时，会自动使用：
```powershell
docker run --rm -v ".\backend:/app" -w /app maven:3.9-eclipse-temurin-17 mvn package
```

---

### 方案二：安装 Maven（推荐长期开发）

#### Windows 安装步骤：

1. **下载 Maven**
   - 访问：https://maven.apache.org/download.cgi
   - 下载：`apache-maven-3.9.x-bin.zip`

2. **解压到本地**
   ```
   解压到：C:\Program Files\Apache\maven
   ```

3. **配置环境变量**
   
   **步骤 A：设置 MAVEN_HOME**
   - 右键 "此电脑" → "属性"
   - 点击 "高级系统设置"
   - 点击 "环境变量"
   - 在 "系统变量" 中点击 "新建"
   - 变量名：`MAVEN_HOME`
   - 变量值：`C:\Program Files\Apache\maven`

   **步骤 B：添加到 PATH**
   - 在 "系统变量" 中找到 `Path`
   - 点击 "编辑"
   - 点击 "新建"
   - 添加：`%MAVEN_HOME%\bin`
   - 点击 "确定"

4. **验证安装**
   ```powershell
   # 重启 PowerShell
   mvn -version
   ```

   应该看到类似输出：
   ```
   Apache Maven 3.9.x
   Maven home: C:\Program Files\Apache\maven
   Java version: 17.0.x
   ```

---

### 方案三：使用 Chocolatey（最简单）

如果您安装了 Chocolatey 包管理器：

```powershell
# 以管理员身份运行 PowerShell
choco install maven

# 验证
mvn -version
```

---

## 📊 性能对比

| 方式 | 首次构建 | 后续构建 | 优点 | 缺点 |
|------|---------|---------|------|------|
| **本地 Maven** | 2-5分钟 | 30秒-2分钟 | 快速 | 需要安装 |
| **Docker Maven** | 7-10分钟 | 3-5分钟 | 无需安装 | 较慢 |

---

## 🚀 推荐方案

### 临时开发（1-2天）
→ **使用 Docker Maven**（无需安装）

### 长期开发（1周+）
→ **安装本地 Maven**（速度更快）

---

## ⚡ 快速验证

检查 Maven 是否可用：

```powershell
# 检查是否安装
mvn -version

# 如果没安装，脚本会自动使用 Docker Maven
# 您无需担心！
```

---

## 🔧 故障排除

### Q: Docker Maven 很慢怎么办？

**A:** 首次使用需要下载镜像（约 200MB），需要 5-10 分钟。后续会快很多。

如果网络很慢，建议安装本地 Maven（方案二）。

---

### Q: 安装了 Maven 但还是提示未找到？

**A:** 检查以下几点：

1. **重启 PowerShell**
   ```powershell
   # 关闭所有 PowerShell 窗口
   # 重新打开
   mvn -version
   ```

2. **检查环境变量**
   ```powershell
   $env:MAVEN_HOME
   $env:Path -split ';' | Select-String maven
   ```

3. **手动指定路径**
   ```powershell
   & "C:\Program Files\Apache\maven\bin\mvn.cmd" -version
   ```

---

### Q: Docker Maven 失败怎么办？

**可能原因：**
1. Docker Desktop 未启动
2. 网络无法访问 Docker Hub
3. 磁盘空间不足

**解决：**
```powershell
# 检查 Docker
docker --version

# 启动 Docker Desktop
# 然后重试部署
```

---

## 💡 当前脚本已自动处理

✅ **deploy-fast.ps1** - 已集成 Maven 检测  
✅ **deploy-backend.ps1** - 已集成 Maven 检测  
✅ **deploy-all.ps1** - 使用上述脚本

**您无需担心 Maven 问题，脚本会自动选择最佳方案！**

---

## 📞 仍然有问题？

如果遇到其他问题，请提供错误信息：

```powershell
# 运行部署脚本时的完整错误输出
.\deploy-fast.ps1 2>&1 | Out-File deploy-error.log

# 然后查看 deploy-error.log
```

---

**建议：** 如果您打算长期开发此项目，花 5 分钟安装本地 Maven 会让后续开发更快！

