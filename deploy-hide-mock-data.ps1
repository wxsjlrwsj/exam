# 部署隐藏模拟数据的前端更新
# 此脚本用于快速部署前端的数据验证功能

Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                            ║" -ForegroundColor Cyan
Write-Host "║          🚀 部署前端数据验证功能                          ║" -ForegroundColor Cyan
Write-Host "║                                                            ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

Write-Host "`n📋 任务清单：" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host "  1. 检查前端构建文件" -ForegroundColor White
Write-Host "  2. 停止现有前端服务" -ForegroundColor White
Write-Host "  3. 部署新的前端文件" -ForegroundColor White
Write-Host "  4. 重启前端服务" -ForegroundColor White
Write-Host "  5. 验证部署结果" -ForegroundColor White
Write-Host ""

# 设置路径
$frontendPath = "C:\Users\34445\Desktop\chaoxin\exam\frontend"
$distPath = "$frontendPath\dist"
$nginxPath = "C:\nginx"  # 根据实际情况修改

# 1. 检查构建文件
Write-Host "📦 步骤 1/5: 检查前端构建文件..." -ForegroundColor Cyan
if (Test-Path $distPath) {
    $fileCount = (Get-ChildItem -Path $distPath -Recurse -File).Count
    Write-Host "  ✅ 构建文件存在 (共 $fileCount 个文件)" -ForegroundColor Green
} else {
    Write-Host "  ❌ 构建文件不存在，需要先构建" -ForegroundColor Red
    Write-Host "  正在构建前端..." -ForegroundColor Yellow
    Set-Location $frontendPath
    npm run build
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  ❌ 前端构建失败" -ForegroundColor Red
        exit 1
    }
    Write-Host "  ✅ 前端构建成功" -ForegroundColor Green
}

# 2. 停止现有前端服务（如果使用Docker）
Write-Host "`n🛑 步骤 2/5: 停止现有前端服务..." -ForegroundColor Cyan
Set-Location "C:\Users\34445\Desktop\chaoxin\exam"
$frontendContainer = docker ps -q -f name=exam-frontend
if ($frontendContainer) {
    Write-Host "  正在停止前端容器..." -ForegroundColor Yellow
    docker stop exam-frontend
    Write-Host "  ✅ 前端容器已停止" -ForegroundColor Green
} else {
    Write-Host "  ℹ️  未检测到运行中的前端容器" -ForegroundColor Gray
}

# 3. 部署新的前端文件
Write-Host "`n📂 步骤 3/5: 部署新的前端文件..." -ForegroundColor Cyan

# 检查是否使用Docker部署
if (Test-Path ".\docker-compose.yml") {
    Write-Host "  使用 Docker Compose 部署..." -ForegroundColor Yellow
    
    # 重新构建前端镜像
    docker-compose build frontend
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ 前端镜像构建成功" -ForegroundColor Green
    } else {
        Write-Host "  ❌ 前端镜像构建失败" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "  ℹ️  未找到 docker-compose.yml，跳过Docker部署" -ForegroundColor Gray
}

# 4. 重启前端服务
Write-Host "`n🔄 步骤 4/5: 重启前端服务..." -ForegroundColor Cyan
if (Test-Path ".\docker-compose.yml") {
    Write-Host "  正在启动前端容器..." -ForegroundColor Yellow
    docker-compose up -d frontend
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ 前端服务已启动" -ForegroundColor Green
    } else {
        Write-Host "  ❌ 前端服务启动失败" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "  ℹ️  请手动启动前端服务" -ForegroundColor Gray
}

# 5. 验证部署结果
Write-Host "`n✅ 步骤 5/5: 验证部署结果..." -ForegroundColor Cyan
Start-Sleep -Seconds 3

# 检查前端容器状态
$frontendStatus = docker ps -f name=exam-frontend --format "{{.Status}}"
if ($frontendStatus) {
    Write-Host "  ✅ 前端容器运行状态: $frontendStatus" -ForegroundColor Green
} else {
    Write-Host "  ⚠️  前端容器未运行" -ForegroundColor Yellow
}

# 测试前端访问
Write-Host "`n  正在测试前端访问..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080" -Method GET -TimeoutSec 5 -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        Write-Host "  ✅ 前端页面可访问 (状态码: 200)" -ForegroundColor Green
    }
} catch {
    Write-Host "  ⚠️  前端页面暂时无法访问: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host "     请稍后手动访问 http://localhost:8080 验证" -ForegroundColor Gray
}

# 显示总结
Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                                                            ║" -ForegroundColor Green
Write-Host "║          ✅ 部署完成！                                     ║" -ForegroundColor Green
Write-Host "║                                                            ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Green

Write-Host "`n📝 更新内容：" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host "  ✅ 隐藏所有前端硬编码的模拟数据" -ForegroundColor White
Write-Host "  ✅ 添加数据验证和过滤机制" -ForegroundColor White
Write-Host "  ✅ 创建学生端API接口文件" -ForegroundColor White
Write-Host "  ✅ 更新教师端和学生端组件" -ForegroundColor White
Write-Host "  ✅ 只显示数据库中的真实数据" -ForegroundColor White
Write-Host ""

Write-Host "🌐 访问地址：" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host "  前端: http://localhost:8080" -ForegroundColor White
Write-Host "  后端: http://localhost:8083" -ForegroundColor White
Write-Host ""

Write-Host "📖 相关文档：" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host "  • HIDE_MOCK_DATA_SUMMARY.md - 完成总结" -ForegroundColor White
Write-Host "  • frontend/DATA_VALIDATION_GUIDE.md - 数据验证说明" -ForegroundColor White
Write-Host ""

Write-Host "⚠️  注意事项：" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host "  • 确保后端服务正常运行" -ForegroundColor White
Write-Host "  • 数据库中需要有测试数据" -ForegroundColor White
Write-Host "  • 如果列表为空，说明数据库中暂无数据" -ForegroundColor White
Write-Host "  • 查看浏览器控制台可以看到数据过滤日志" -ForegroundColor White
Write-Host ""

Write-Host "✨ 完成！" -ForegroundColor Green


