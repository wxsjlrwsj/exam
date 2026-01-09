# 后端部署脚本
# 用于在修改后端代码后重新部署

param(
    [switch]$NonInteractive
)
# 错误处理函数 - 防止闪退
function Exit-WithMessage {
    param(
        [string]$Message,
        [int]$ExitCode = 1
    )
    Write-Host "`n$Message" -ForegroundColor Red
    if (-not $NonInteractive) {
        Write-Host "`n按任意键退出..." -ForegroundColor Yellow
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
    exit $ExitCode
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "开始部署后端..." -ForegroundColor Cyan
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
$containerExists = docker ps -a --filter "name=chaoxing-backend" --format "{{.Names}}" 2>&1
if ($LASTEXITCODE -ne 0 -or -not $containerExists) {
    Exit-WithMessage "✖ 未找到 chaoxing-backend 容器！请先运行: docker-compose up -d"
}
Write-Host "✓ 找到后端容器" -ForegroundColor Green

# 1. 进入后端目录
Set-Location "$projectRoot\backend"

# 2. 使用 Maven 构建项目
Write-Host "`n[1/4] 正在使用 Maven 构建后端项目..." -ForegroundColor Yellow
Write-Host "这可能需要几分钟，请稍候..." -ForegroundColor Gray

# 检查是否安装了 Maven
$mvnVersion = mvn -v 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "`n✖ 未找到 Maven！正在尝试使用容器构建..." -ForegroundColor Yellow
    
    # 使用 Maven Docker 镜像构建
    docker run --rm -v "${projectRoot}\backend:/app" -w /app maven:3.9-eclipse-temurin-17 mvn clean package -DskipTests
    
    if ($LASTEXITCODE -ne 0) {
        Exit-WithMessage "✖ 构建失败！请检查上面的错误信息。"
    }
} else {
    # 使用本地 Maven 构建
    mvn clean package -DskipTests
    
    if ($LASTEXITCODE -ne 0) {
        Exit-WithMessage "✖ 构建失败！请检查上面的错误信息。"
    }
}

Write-Host "✓ 后端构建完成！" -ForegroundColor Green

# 3. 将新的 JAR 文件复制到容器中
Write-Host "`n[2/4] 正在更新容器中的应用..." -ForegroundColor Yellow
$jarFile = Get-ChildItem -Path "$projectRoot\backend\target\*.jar" | Select-Object -First 1

if (-not $jarFile) {
    Exit-WithMessage "✖ 未找到构建的 JAR 文件！请检查构建过程。"
}

Write-Host "找到 JAR 文件: $($jarFile.Name)" -ForegroundColor Gray
docker cp $jarFile.FullName chaoxing-backend:/app/app.jar

if ($LASTEXITCODE -ne 0) {
    Exit-WithMessage "✖ 文件复制失败！请检查容器状态。"
}

Write-Host "✓ JAR 文件已更新！" -ForegroundColor Green

# 4. 重启后端容器
Write-Host "`n[3/4] 正在重启后端容器..." -ForegroundColor Yellow
Set-Location $projectRoot
docker restart chaoxing-backend

if ($LASTEXITCODE -ne 0) {
    Exit-WithMessage "✖ 容器重启失败！请检查容器状态。"
}

# 5. 等待容器启动并检查日志
Write-Host "`n[4/4] 等待应用启动（约10秒）..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

Write-Host "`n最近的日志:" -ForegroundColor Cyan
docker logs chaoxing-backend --tail 20

# 6. 检查容器状态
$status = docker ps --filter "name=chaoxing-backend" --format "{{.Status}}"
Write-Host "`n容器状态: $status" -ForegroundColor Cyan

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "✓ 后端部署完成！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "`n后端API地址: http://localhost:8083/api`n" -ForegroundColor Yellow

# 防止窗口闪退
if (-not $NonInteractive) {
    Write-Host "按任意键退出..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
