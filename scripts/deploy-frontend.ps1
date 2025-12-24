# 前端部署脚本
# 用于在修改前端代码后重新部署

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "开始部署前端..." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# 获取项目根目录（scripts 的父目录）
$projectRoot = Split-Path -Parent $PSScriptRoot

# 1. 进入前端目录
Set-Location "$projectRoot\frontend"

# 2. 构建前端项目
Write-Host "`n[1/3] 正在构建前端项目..." -ForegroundColor Yellow
npm run build

if ($LASTEXITCODE -ne 0) {
    Write-Host "`n✖ 构建失败！请检查错误信息。" -ForegroundColor Red
    exit 1
}

Write-Host "✓ 前端构建完成！" -ForegroundColor Green

# 3. 重启前端容器（重新加载 dist 目录）
Write-Host "`n[2/3] 正在重启前端容器..." -ForegroundColor Yellow
Set-Location $projectRoot
docker restart chaoxing-frontend

if ($LASTEXITCODE -ne 0) {
    Write-Host "`n✖ 容器重启失败！" -ForegroundColor Red
    exit 1
}

# 4. 等待容器启动
Write-Host "`n[3/3] 等待容器启动..." -ForegroundColor Yellow
Start-Sleep -Seconds 3

# 5. 检查容器状态
$status = docker ps --filter "name=chaoxing-frontend" --format "{{.Status}}"
Write-Host "`n容器状态: $status" -ForegroundColor Cyan

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "✓ 前端部署完成！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "`n访问地址: http://localhost:8080`n" -ForegroundColor Yellow

# 可选：自动打开浏览器
$openBrowser = Read-Host "是否在浏览器中打开？(y/n)"
if ($openBrowser -eq 'y') {
    Start-Process "http://localhost:8080"
}

