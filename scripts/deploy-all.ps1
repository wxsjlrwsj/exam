# 一键部署脚本
# 同时部署前端和后端

Write-Host "========================================" -ForegroundColor Magenta
Write-Host "      开始部署完整应用系统" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta

# 获取项目根目录
$projectRoot = Split-Path -Parent $PSScriptRoot

# 检查Docker是否运行
Write-Host "`n[预检] 检查Docker状态..." -ForegroundColor Yellow
$dockerRunning = $false
try {
    $null = docker ps 2>&1
    if ($LASTEXITCODE -eq 0) {
        $dockerRunning = $true
        Write-Host "✓ Docker 正在运行" -ForegroundColor Green
    }
} catch {
    $dockerRunning = $false
}

if (-not $dockerRunning) {
    Write-Host "✖ Docker 未运行！" -ForegroundColor Red
    Write-Host "`n请先启动 Docker Desktop，然后重新运行此脚本。" -ForegroundColor Yellow
    Write-Host "启动方法：" -ForegroundColor Cyan
    Write-Host "  1. 打开 Docker Desktop 应用程序" -ForegroundColor White
    Write-Host "  2. 等待 Docker 引擎启动（约 30-60 秒）" -ForegroundColor White
    Write-Host "  3. 重新运行此脚本`n" -ForegroundColor White
    
    $startDocker = Read-Host "是否尝试自动启动 Docker Desktop? (y/n)"
    if ($startDocker -eq 'y') {
        Write-Host "`n正在启动 Docker Desktop..." -ForegroundColor Yellow
        Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe" -ErrorAction SilentlyContinue
        
        Write-Host "等待 Docker 引擎启动（最多等待 60 秒）..." -ForegroundColor Yellow
        $timeout = 60
        $elapsed = 0
        while ($elapsed -lt $timeout) {
            Start-Sleep -Seconds 5
            $elapsed += 5
            try {
                $null = docker ps 2>&1
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "✓ Docker 已启动！" -ForegroundColor Green
                    $dockerRunning = $true
                    break
                }
            } catch {
                Write-Host "." -NoNewline -ForegroundColor Gray
            }
        }
        
        if (-not $dockerRunning) {
            Write-Host "`n✖ Docker 启动超时，请手动启动后重试。" -ForegroundColor Red
            exit 1
        }
    } else {
        exit 1
    }
}

# 检查容器是否存在
Write-Host "`n[预检] 检查容器状态..." -ForegroundColor Yellow
$containers = docker ps -a --filter "name=chaoxing" --format "{{.Names}}" 2>&1
if ($LASTEXITCODE -ne 0 -or -not $containers) {
    Write-Host "✖ 未找到 chaoxing 容器！" -ForegroundColor Red
    Write-Host "`n请先运行以下命令创建容器：" -ForegroundColor Yellow
    Write-Host "  cd $projectRoot" -ForegroundColor Cyan
    Write-Host "  docker-compose up -d`n" -ForegroundColor Cyan
    
    $createContainers = Read-Host "是否现在创建容器? (y/n)"
    if ($createContainers -eq 'y') {
        Write-Host "`n正在创建容器..." -ForegroundColor Yellow
        Set-Location $projectRoot
        docker-compose up -d --build
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "`n✖ 容器创建失败！" -ForegroundColor Red
            exit 1
        }
        
        Write-Host "✓ 容器创建成功！" -ForegroundColor Green
        Write-Host "`n等待服务启动（约 30 秒）..." -ForegroundColor Yellow
        Start-Sleep -Seconds 30
    } else {
        exit 1
    }
} else {
    Write-Host "✓ 找到以下容器：" -ForegroundColor Green
    $containers | ForEach-Object { Write-Host "  - $_" -ForegroundColor Cyan }
}

$startTime = Get-Date

# 询问部署选项
Write-Host "`n请选择部署模式:" -ForegroundColor Cyan
Write-Host "1. 仅部署前端" -ForegroundColor Yellow
Write-Host "2. 仅部署后端" -ForegroundColor Yellow
Write-Host "3. 部署前端和后端（推荐）" -ForegroundColor Yellow
$choice = Read-Host "`n请输入选项 (1/2/3)"

$deployFrontend = $false
$deployBackend = $false

switch ($choice) {
    "1" { $deployFrontend = $true }
    "2" { $deployBackend = $true }
    "3" { 
        $deployFrontend = $true
        $deployBackend = $true
    }
    default {
        Write-Host "`n✖ 无效选项，默认部署全部" -ForegroundColor Red
        $deployFrontend = $true
        $deployBackend = $true
    }
}

# ==================== 部署后端 ====================
if ($deployBackend) {
    Write-Host "`n" -NoNewline
    Write-Host "========================================" -ForegroundColor Blue
    Write-Host "第一步: 部署后端" -ForegroundColor Blue
    Write-Host "========================================" -ForegroundColor Blue
    
    & "$PSScriptRoot\deploy-backend.ps1"
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "`n✖ 后端部署失败！停止部署流程。" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "`n✓ 后端部署成功！" -ForegroundColor Green
}

# ==================== 部署前端 ====================
if ($deployFrontend) {
    Write-Host "`n" -NoNewline
    Write-Host "========================================" -ForegroundColor Blue
    Write-Host "第二步: 部署前端" -ForegroundColor Blue
    Write-Host "========================================" -ForegroundColor Blue
    
    & "$PSScriptRoot\deploy-frontend.ps1"
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "`n✖ 前端部署失败！" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "`n✓ 前端部署成功！" -ForegroundColor Green
}

# ==================== 最终检查 ====================
Write-Host "`n" -NoNewline
Write-Host "========================================" -ForegroundColor Blue
Write-Host "最终检查" -ForegroundColor Blue
Write-Host "========================================" -ForegroundColor Blue

Write-Host "`n正在检查所有服务状态..." -ForegroundColor Yellow
docker ps --filter "name=chaoxing" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

$endTime = Get-Date
$duration = $endTime - $startTime

Write-Host "`n" -NoNewline
Write-Host "========================================" -ForegroundColor Green
Write-Host "✓✓✓ 部署全部完成！✓✓✓" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "`n总耗时: $($duration.TotalSeconds) 秒" -ForegroundColor Cyan
Write-Host "`n访问地址:" -ForegroundColor Yellow
Write-Host "  前端: http://localhost:8080" -ForegroundColor Cyan
Write-Host "  后端: http://localhost:8083" -ForegroundColor Cyan
Write-Host ""

