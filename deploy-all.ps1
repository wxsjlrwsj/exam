# 一键部署脚本
# 同时部署前端和后端

Write-Host "========================================" -ForegroundColor Magenta
Write-Host "      开始部署完整应用系统" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta

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

