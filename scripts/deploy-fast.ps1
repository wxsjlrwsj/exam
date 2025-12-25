# 快速部署脚本 - 增量构建优化版
# 只重新构建真正需要的部分，大幅减少部署时间

Write-Host "========================================" -ForegroundColor Magenta
Write-Host "      快速部署模式（增量构建）" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta

# 获取项目根目录（scripts 的父目录）
$projectRoot = Split-Path -Parent $PSScriptRoot

# 检查Docker是否运行
Write-Host "`n[预检] 检查Docker状态..." -ForegroundColor Yellow
try {
    $null = docker ps 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "✖ Docker 未运行！请先启动 Docker Desktop。" -ForegroundColor Red
        Write-Host "`n启动方法：打开 Docker Desktop 应用程序`n" -ForegroundColor Yellow
        exit 1
    }
    Write-Host "✓ Docker 正在运行" -ForegroundColor Green
} catch {
    Write-Host "✖ Docker 未运行！请先启动 Docker Desktop。" -ForegroundColor Red
    exit 1
}

# 检查容器是否存在
$containers = docker ps -a --filter "name=chaoxing" --format "{{.Names}}" 2>&1
if ($LASTEXITCODE -ne 0 -or -not $containers) {
    Write-Host "✖ 未找到 chaoxing 容器！" -ForegroundColor Red
    Write-Host "请先运行: docker-compose up -d`n" -ForegroundColor Yellow
    exit 1
}
Write-Host "✓ 找到容器" -ForegroundColor Green

$startTime = Get-Date

# 询问部署选项
Write-Host "`n请选择部署模式:" -ForegroundColor Cyan
Write-Host "1. 仅部署前端（约 1-3 分钟）" -ForegroundColor Yellow
Write-Host "2. 仅部署后端（约 30 秒 - 5 分钟）" -ForegroundColor Yellow
Write-Host "3. 部署前端和后端（并行，约 2-5 分钟）" -ForegroundColor Yellow
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

# ==================== 并行部署 ====================
if ($deployFrontend -and $deployBackend) {
    Write-Host "`n========================================" -ForegroundColor Blue
    Write-Host "并行部署模式（前端+后端同时进行）" -ForegroundColor Blue
    Write-Host "========================================" -ForegroundColor Blue
    
    # 创建后端构建任务
    $backendJob = Start-Job -ScriptBlock {
        param($rootPath)
        Set-Location $rootPath
        
        Write-Output "[后端] 开始构建..."
        Set-Location backend
        
        # 检查是否安装了 Maven
        $mvnInstalled = $null -ne (Get-Command mvn -ErrorAction SilentlyContinue)
        
        if ($mvnInstalled) {
            Write-Output "[后端] 使用本地 Maven 构建..."
            $result = & mvn package -DskipTests 2>&1
        } else {
            Write-Output "[后端] 未找到 Maven，使用 Docker Maven 镜像构建..."
            # 使用 Docker Maven 镜像构建
            $result = docker run --rm -v "${rootPath}\backend:/app" -w /app maven:3.9-eclipse-temurin-17 mvn package -DskipTests 2>&1
        }
        
        if ($LASTEXITCODE -eq 0) {
            Write-Output "[后端] ✓ 构建成功！"
            
            # 复制 JAR 到容器
            $jarFile = Get-ChildItem -Path "target\*.jar" | Select-Object -First 1
            if ($jarFile) {
                Write-Output "[后端] 正在更新容器..."
                docker cp $jarFile.FullName chaoxing-backend:/app/app.jar
                
                # 重启容器
                docker restart chaoxing-backend | Out-Null
                Write-Output "[后端] ✓ 部署完成！"
                return $true
            }
        }
        
        Write-Output "[后端] ✖ 构建失败"
        return $false
    } -ArgumentList $projectRoot
    
    # 创建前端构建任务
    $frontendJob = Start-Job -ScriptBlock {
        param($rootPath)
        Set-Location $rootPath
        
        Write-Output "[前端] 开始构建..."
        Set-Location frontend
        
        $result = & npm run build 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Output "[前端] ✓ 构建成功！"
            
            # 重启容器
            Set-Location $rootPath
            docker restart chaoxing-frontend | Out-Null
            Write-Output "[前端] ✓ 部署完成！"
            return $true
        }
        
        Write-Output "[前端] ✖ 构建失败"
        return $false
    } -ArgumentList $projectRoot
    
    Write-Host "`n⏳ 正在并行构建，请稍候..." -ForegroundColor Yellow
    Write-Host "   （前端和后端同时进行，可以节省 30-50% 时间）`n" -ForegroundColor Gray
    
    # 等待任务完成并实时显示输出
    while ($backendJob.State -eq 'Running' -or $frontendJob.State -eq 'Running') {
        # 获取后端输出
        $backendOutput = Receive-Job -Job $backendJob
        if ($backendOutput) {
            $backendOutput | ForEach-Object { Write-Host $_ -ForegroundColor Cyan }
        }
        
        # 获取前端输出
        $frontendOutput = Receive-Job -Job $frontendJob
        if ($frontendOutput) {
            $frontendOutput | ForEach-Object { Write-Host $_ -ForegroundColor Green }
        }
        
        Start-Sleep -Milliseconds 500
    }
    
    # 获取剩余输出
    Receive-Job -Job $backendJob | ForEach-Object { Write-Host $_ -ForegroundColor Cyan }
    Receive-Job -Job $frontendJob | ForEach-Object { Write-Host $_ -ForegroundColor Green }
    
    # 检查结果
    $backendResult = Receive-Job -Job $backendJob -Wait
    $frontendResult = Receive-Job -Job $frontendJob -Wait
    
    Remove-Job -Job $backendJob
    Remove-Job -Job $frontendJob
    
    if (-not $backendResult -or -not $frontendResult) {
        Write-Host "`n✖ 部署失败！请查看上面的错误信息。" -ForegroundColor Red
        exit 1
    }
}
# ==================== 仅部署后端（快速模式）====================
elseif ($deployBackend) {
    Write-Host "`n========================================" -ForegroundColor Blue
    Write-Host "快速部署后端" -ForegroundColor Blue
    Write-Host "========================================" -ForegroundColor Blue
    
    Set-Location "$projectRoot\backend"
    
    Write-Host "`n[1/3] 增量构建（跳过 clean）..." -ForegroundColor Yellow
    
    # 检查是否安装了 Maven
    $mvnInstalled = $null -ne (Get-Command mvn -ErrorAction SilentlyContinue)
    
    if ($mvnInstalled) {
        Write-Host "使用本地 Maven..." -ForegroundColor Gray
        mvn package -DskipTests
    } else {
        Write-Host "未找到 Maven，使用 Docker Maven 镜像..." -ForegroundColor Yellow
        docker run --rm -v "${projectRoot}\backend:/app" -w /app maven:3.9-eclipse-temurin-17 mvn package -DskipTests
    }
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "`n✖ 构建失败！" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "✓ 构建完成！" -ForegroundColor Green
    
    Write-Host "`n[2/3] 更新容器..." -ForegroundColor Yellow
    $jarFile = Get-ChildItem -Path "$projectRoot\backend\target\*.jar" | Select-Object -First 1
    docker cp $jarFile.FullName chaoxing-backend:/app/app.jar
    
    Write-Host "`n[3/3] 重启后端..." -ForegroundColor Yellow
    Set-Location $projectRoot
    docker restart chaoxing-backend
    
    Start-Sleep -Seconds 3
    Write-Host "✓ 后端部署完成！" -ForegroundColor Green
}
# ==================== 仅部署前端 ====================
elseif ($deployFrontend) {
    Write-Host "`n========================================" -ForegroundColor Blue
    Write-Host "快速部署前端" -ForegroundColor Blue
    Write-Host "========================================" -ForegroundColor Blue
    
    Set-Location "$projectRoot\frontend"
    
    Write-Host "`n[1/2] 构建前端..." -ForegroundColor Yellow
    npm run build
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "`n✖ 构建失败！" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "✓ 构建完成！" -ForegroundColor Green
    
    Write-Host "`n[2/2] 重启前端..." -ForegroundColor Yellow
    Set-Location $projectRoot
    docker restart chaoxing-frontend
    
    Start-Sleep -Seconds 2
    Write-Host "✓ 前端部署完成！" -ForegroundColor Green
}

# ==================== 最终检查 ====================
Write-Host "`n========================================" -ForegroundColor Blue
Write-Host "最终检查" -ForegroundColor Blue
Write-Host "========================================" -ForegroundColor Blue

Write-Host "`n正在检查服务状态..." -ForegroundColor Yellow
docker ps --filter "name=chaoxing" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

$endTime = Get-Date
$duration = $endTime - $startTime

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "✓✓✓ 快速部署完成！✓✓✓" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "`n⚡ 总耗时: $([math]::Round($duration.TotalSeconds, 1)) 秒" -ForegroundColor Cyan
Write-Host "`n访问地址:" -ForegroundColor Yellow
Write-Host "  前端: http://localhost:8080" -ForegroundColor Cyan
Write-Host "  后端: http://localhost:8083" -ForegroundColor Cyan

Write-Host "`n💡 提示: 如果需要完全重新构建，请使用 .\deploy-all.ps1`n" -ForegroundColor Gray

