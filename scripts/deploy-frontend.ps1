# 前端部署脚本
# 用于在修改前端代码后重新部署

# 错误处理函数 - 防止闪退
function Exit-WithMessage {
    param(
        [string]$Message,
        [int]$ExitCode = 1
    )
    Write-Host "`n$Message" -ForegroundColor Red
    Write-Host "`n按任意键退出..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit $ExitCode
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "开始部署前端..." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# 获取项目根目录（scripts 的父目录）
$projectRoot = Split-Path -Parent $PSScriptRoot

# 检查Docker是否运行
Write-Host "`n[预检] 检查Docker状态..." -ForegroundColor Yellow
try {
    $null = docker ps 2>&1
    if ($LASTEXITCODE -ne 0) {
        Exit-WithMessage "✖ Docker 未运行！请先启动 Docker Desktop 后重新运行此脚本。"
    }
    Write-Host "✓ Docker 正在运行" -ForegroundColor Green
} catch {
    Exit-WithMessage "✖ Docker 未运行！请先启动 Docker Desktop 后重新运行此脚本。"
}

# 检查容器是否存在
$containerExists = docker ps -a --filter "name=chaoxing-frontend" --format "{{.Names}}" 2>&1
if ($LASTEXITCODE -ne 0 -or -not $containerExists) {
    Exit-WithMessage "✖ 未找到 chaoxing-frontend 容器！请先运行: docker-compose up -d"
}
Write-Host "✓ 找到前端容器" -ForegroundColor Green

# 检查npm是否安装
$npmInstalled = $null -ne (Get-Command npm -ErrorAction SilentlyContinue)
if (-not $npmInstalled) {
    Exit-WithMessage "✖ 未找到 npm！请先安装 Node.js：https://nodejs.org/"
}
Write-Host "✓ npm 已安装" -ForegroundColor Green

# 1. 进入前端目录
Set-Location "$projectRoot\frontend"

# 2. 构建前端项目
Write-Host "`n[1/3] 正在构建前端项目..." -ForegroundColor Yellow
npm run build

if ($LASTEXITCODE -ne 0) {
    Exit-WithMessage "✖ 构建失败！请检查上面的错误信息。"
}

Write-Host "✓ 前端构建完成！" -ForegroundColor Green

# 3. 重启前端容器（重新加载 dist 目录）
Write-Host "`n[2/3] 正在重启前端容器..." -ForegroundColor Yellow
Set-Location $projectRoot
docker restart chaoxing-frontend

if ($LASTEXITCODE -ne 0) {
    Exit-WithMessage "✖ 容器重启失败！请检查容器状态。"
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

# 防止窗口闪退
Write-Host "`n按任意键退出..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
