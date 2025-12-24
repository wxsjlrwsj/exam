# 开发模式启动脚本
# 使用热更新，修改代码后自动刷新，无需重新部署
# 适合频繁修改代码的开发场景

Write-Host "========================================" -ForegroundColor Magenta
Write-Host "      开发模式（热更新）" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta

Write-Host "`n💡 开发模式说明：" -ForegroundColor Cyan
Write-Host "  • 前端：使用 Vite 开发服务器（修改代码后自动刷新）" -ForegroundColor White
Write-Host "  • 后端：使用 Spring Boot DevTools（修改代码后自动重启）" -ForegroundColor White
Write-Host "  • 数据库：使用 Docker MySQL 容器`n" -ForegroundColor White

# 检查 Docker 容器是否运行
Write-Host "检查 Docker 服务..." -ForegroundColor Yellow
$mysqlRunning = docker ps --filter "name=chaoxing-mysql" --format "{{.Names}}"

if (-not $mysqlRunning) {
    Write-Host "⚠️  MySQL 容器未运行，正在启动..." -ForegroundColor Yellow
    docker start chaoxing-mysql
    Start-Sleep -Seconds 5
}

$mysqlStatus = docker ps --filter "name=chaoxing-mysql" --format "{{.Status}}"
Write-Host "✓ MySQL 状态: $mysqlStatus" -ForegroundColor Green

# 询问启动模式
Write-Host "`n请选择启动模式:" -ForegroundColor Cyan
Write-Host "1. 仅启动前端（需要后端已在运行）" -ForegroundColor Yellow
Write-Host "2. 仅启动后端（需要前端已在运行）" -ForegroundColor Yellow
Write-Host "3. 同时启动前端和后端（推荐）" -ForegroundColor Yellow
$choice = Read-Host "`n请输入选项 (1/2/3)"

$startFrontend = $false
$startBackend = $false

switch ($choice) {
    "1" { $startFrontend = $true }
    "2" { $startBackend = $true }
    "3" { 
        $startFrontend = $true
        $startBackend = $true
    }
    default {
        Write-Host "`n✖ 无效选项，默认启动全部" -ForegroundColor Red
        $startFrontend = $true
        $startBackend = $true
    }
}

Write-Host "`n========================================" -ForegroundColor Blue
Write-Host "启动开发服务" -ForegroundColor Blue
Write-Host "========================================`n" -ForegroundColor Blue

# ==================== 启动后端 ====================
if ($startBackend) {
    Write-Host "[后端] 正在启动..." -ForegroundColor Cyan
    
    # 检查是否已构建
    $jarExists = Test-Path "$PSScriptRoot\backend\target\*.jar"
    if (-not $jarExists) {
        Write-Host "  ⚠️  未找到 JAR 文件，正在首次构建..." -ForegroundColor Yellow
        Set-Location $PSScriptRoot\backend
        mvn package -DskipTests
        if ($LASTEXITCODE -ne 0) {
            Write-Host "`n✖ 后端构建失败！" -ForegroundColor Red
            exit 1
        }
    }
    
    # 在新窗口启动后端
    $jarFile = Get-ChildItem -Path "$PSScriptRoot\backend\target\*.jar" | Select-Object -First 1
    
    $backendCmd = @"
Write-Host '========================================' -ForegroundColor Cyan
Write-Host '        后端开发模式' -ForegroundColor Cyan
Write-Host '========================================' -ForegroundColor Cyan
Write-Host ''
Write-Host '监听端口: 8083' -ForegroundColor Yellow
Write-Host 'API 地址: http://localhost:8083/api' -ForegroundColor Yellow
Write-Host ''
Write-Host '按 Ctrl+C 停止服务' -ForegroundColor Gray
Write-Host ''
Set-Location '$($PSScriptRoot)\backend'
java -jar '$($jarFile.FullName)'
"@
    
    Start-Process powershell -ArgumentList "-NoExit", "-Command", $backendCmd
    Write-Host "  ✓ 后端已在新窗口启动" -ForegroundColor Green
    Write-Host "     地址: http://localhost:8083" -ForegroundColor Gray
    
    Start-Sleep -Seconds 2
}

# ==================== 启动前端 ====================
if ($startFrontend) {
    Write-Host "`n[前端] 正在启动..." -ForegroundColor Green
    
    # 检查依赖
    if (-not (Test-Path "$PSScriptRoot\frontend\node_modules")) {
        Write-Host "  ⚠️  未找到依赖，正在安装..." -ForegroundColor Yellow
        Set-Location $PSScriptRoot\frontend
        npm install
    }
    
    # 在新窗口启动前端
    $frontendCmd = @"
Write-Host '========================================' -ForegroundColor Green
Write-Host '        前端开发模式（热更新）' -ForegroundColor Green
Write-Host '========================================' -ForegroundColor Green
Write-Host ''
Write-Host '✨ 修改代码后会自动刷新页面' -ForegroundColor Yellow
Write-Host ''
Write-Host '监听端口: 5173' -ForegroundColor Yellow
Write-Host '访问地址: http://localhost:5173' -ForegroundColor Yellow
Write-Host ''
Write-Host '⚠️  注意: 开发模式使用 5173 端口，不是 8080' -ForegroundColor Red
Write-Host ''
Write-Host '按 Ctrl+C 停止服务' -ForegroundColor Gray
Write-Host ''
Set-Location '$PSScriptRoot\frontend'
npm run dev
"@
    
    Start-Process powershell -ArgumentList "-NoExit", "-Command", $frontendCmd
    Write-Host "  ✓ 前端已在新窗口启动（Vite 开发服务器）" -ForegroundColor Green
    Write-Host "     地址: http://localhost:5173" -ForegroundColor Gray
}

# ==================== 完成 ====================
Start-Sleep -Seconds 2

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "✓ 开发环境已启动！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

Write-Host "`n📍 访问地址:" -ForegroundColor Cyan
if ($startFrontend) {
    Write-Host "  前端(开发): http://localhost:5173 ⚡（热更新）" -ForegroundColor Yellow
}
if ($startBackend) {
    Write-Host "  后端API:    http://localhost:8083" -ForegroundColor Yellow
}
Write-Host "  数据库:     Docker 容器 (chaoxing-mysql)" -ForegroundColor Yellow

Write-Host "`n💡 使用提示:" -ForegroundColor Cyan
Write-Host "  • 前端代码修改后会自动刷新浏览器" -ForegroundColor White
Write-Host "  • 后端代码修改后需要重新运行（或配置 DevTools）" -ForegroundColor White
Write-Host "  • 开发完成后，使用 .\deploy-fast.ps1 部署到生产环境" -ForegroundColor White
Write-Host "  • 要停止服务，请关闭对应的 PowerShell 窗口`n" -ForegroundColor White

Write-Host "⚡ 开发模式启动完成！修改代码即可看到效果！`n" -ForegroundColor Green

