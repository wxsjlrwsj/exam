# 完整部署和测试脚本
# 部署前后端并进行全面测试

Write-Host "========================================" -ForegroundColor Magenta
Write-Host "   教师端功能完整部署与测试" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta

$ErrorActionPreference = "Continue"
$startTime = Get-Date

# ==================== 步骤1: 停止现有服务 ====================
Write-Host "`n[步骤1] 停止现有Docker服务..." -ForegroundColor Yellow
docker-compose down 2>$null
Start-Sleep -Seconds 2

# ==================== 步骤2: 清理并重新构建 ====================
Write-Host "`n[步骤2] 清理并重新构建..." -ForegroundColor Yellow

# 2.1 检查后端JAR包
if (Test-Path "backend/target/backend.jar") {
    Write-Host "  ✓ 后端JAR包已存在" -ForegroundColor Green
} else {
    Write-Host "  ✖ 后端JAR包不存在，需要编译" -ForegroundColor Red
    Write-Host "  提示: 请先运行 mvn clean package" -ForegroundColor Yellow
    exit 1
}

# 2.2 检查前端构建
if (Test-Path "frontend/dist") {
    Write-Host "  ✓ 前端构建产物已存在" -ForegroundColor Green
} else {
    Write-Host "  ✖ 前端构建产物不存在" -ForegroundColor Red
    Write-Host "  提示: 请先运行 npm run build" -ForegroundColor Yellow
    exit 1
}

# 2.3 检查数据库迁移脚本
if (Test-Path "backend/db_migration_teacher.sql") {
    Write-Host "  ✓ 数据库迁移脚本已存在" -ForegroundColor Green
} else {
    Write-Host "  ✖ 数据库迁移脚本不存在" -ForegroundColor Red
    exit 1
}

# ==================== 步骤3: 启动服务 ====================
Write-Host "`n[步骤3] 启动Docker服务..." -ForegroundColor Yellow
docker-compose up -d

if ($LASTEXITCODE -ne 0) {
    Write-Host "  ✖ Docker服务启动失败" -ForegroundColor Red
    exit 1
}

Write-Host "  ✓ Docker服务启动命令已执行" -ForegroundColor Green

# ==================== 步骤4: 等待服务就绪 ====================
Write-Host "`n[步骤4] 等待服务就绪..." -ForegroundColor Yellow

Write-Host "  等待MySQL初始化 (30秒)..." -ForegroundColor Cyan
Start-Sleep -Seconds 30

Write-Host "  等待后端服务启动 (20秒)..." -ForegroundColor Cyan
Start-Sleep -Seconds 20

# ==================== 步骤5: 检查服务状态 ====================
Write-Host "`n[步骤5] 检查服务状态..." -ForegroundColor Yellow

$services = docker ps --filter "name=chaoxing" --format "{{.Names}}"
$expectedServices = @("chaoxing-mysql", "chaoxing-backend", "chaoxing-frontend")
$runningServices = @()

foreach ($service in $services) {
    if ($service -in $expectedServices) {
        $runningServices += $service
        Write-Host "  ✓ $service 运行中" -ForegroundColor Green
    }
}

if ($runningServices.Count -ne $expectedServices.Count) {
    Write-Host "  ✖ 部分服务未启动" -ForegroundColor Red
    Write-Host "`n当前运行的服务:" -ForegroundColor Yellow
    docker ps --filter "name=chaoxing" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    exit 1
}

# ==================== 步骤6: 测试API ====================
Write-Host "`n[步骤6] 测试API接口..." -ForegroundColor Yellow

$baseUrl = "http://localhost:8083"
$frontendUrl = "http://localhost:8080"

# 测试计数器
$totalTests = 0
$passedTests = 0
$failedTests = 0

function Test-Api {
    param (
        [string]$Name,
        [string]$Url,
        [string]$Method = "GET"
    )
    
    $script:totalTests++
    Write-Host "  测试: $Name" -ForegroundColor Cyan
    
    try {
        $response = Invoke-WebRequest -Uri $Url -Method $Method -TimeoutSec 5 -UseBasicParsing 2>$null
        if ($response.StatusCode -eq 200) {
            Write-Host "    ✓ 通过 (200 OK)" -ForegroundColor Green
            $script:passedTests++
            return $true
        } else {
            Write-Host "    ✖ 失败 (状态码: $($response.StatusCode))" -ForegroundColor Red
            $script:failedTests++
            return $false
        }
    } catch {
        Write-Host "    ✖ 失败 (无法连接)" -ForegroundColor Red
        $script:failedTests++
        return $false
    }
}

Write-Host "`n  [6.1] 测试前端..." -ForegroundColor Yellow
Test-Api "前端首页" $frontendUrl

Write-Host "`n  [6.2] 测试后端基础接口..." -ForegroundColor Yellow
# 注意：未登录时某些接口会返回401，这是正常的
# 我们主要测试服务是否可达

try {
    $response = Invoke-WebRequest -Uri "$baseUrl/api/subjects" -UseBasicParsing -TimeoutSec 5 2>$null
    Write-Host "    ✓ 后端服务可达" -ForegroundColor Green
    $passedTests++
} catch {
    if ($_.Exception.Response.StatusCode.value__ -eq 401 -or $_.Exception.Response.StatusCode.value__ -eq 403) {
        Write-Host "    ✓ 后端服务运行正常 (需要认证)" -ForegroundColor Green
        $passedTests++
    } else {
        Write-Host "    ✖ 后端服务不可达" -ForegroundColor Red
        $failedTests++
    }
}
$totalTests++

# ==================== 步骤7: 检查数据库 ====================
Write-Host "`n[步骤7] 检查数据库..." -ForegroundColor Yellow

Write-Host "  检查新增的表..." -ForegroundColor Cyan
$tables = @(
    "biz_exam_student",
    "biz_class",
    "biz_class_student",
    "biz_monitor_warning",
    "biz_score_adjustment",
    "biz_subject"
)

$dbCheckCommand = @"
SELECT COUNT(*) as count FROM information_schema.tables 
WHERE table_schema = 'chaoxing' 
AND table_name IN ('biz_exam_student', 'biz_class', 'biz_class_student', 'biz_monitor_warning', 'biz_score_adjustment', 'biz_subject');
"@

try {
    $result = docker exec chaoxing-mysql mysql -uroot -proot chaoxing -e "$dbCheckCommand" 2>$null
    if ($result -match "6") {
        Write-Host "    ✓ 所有新表已创建" -ForegroundColor Green
    } else {
        Write-Host "    ⚠ 部分表可能未创建，请手动检查" -ForegroundColor Yellow
    }
} catch {
    Write-Host "    ⚠ 无法自动检查数据库表" -ForegroundColor Yellow
}

# ==================== 步骤8: 显示日志摘要 ====================
Write-Host "`n[步骤8] 服务日志摘要..." -ForegroundColor Yellow

Write-Host "`n  后端日志 (最后10行):" -ForegroundColor Cyan
docker logs chaoxing-backend --tail 10 2>$null

# ==================== 最终报告 ====================
$endTime = Get-Date
$duration = $endTime - $startTime

Write-Host "`n" -NoNewline
Write-Host "========================================" -ForegroundColor Green
Write-Host "           部署测试完成" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

Write-Host "`n部署统计:" -ForegroundColor Yellow
Write-Host "  总耗时: $([math]::Round($duration.TotalSeconds, 2)) 秒" -ForegroundColor Cyan
Write-Host "  测试总数: $totalTests" -ForegroundColor Cyan
Write-Host "  通过: $passedTests" -ForegroundColor Green
Write-Host "  失败: $failedTests" -ForegroundColor $(if ($failedTests -eq 0) { "Green" } else { "Red" })

Write-Host "`n服务状态:" -ForegroundColor Yellow
docker ps --filter "name=chaoxing" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

Write-Host "`n访问地址:" -ForegroundColor Yellow
Write-Host "  前端: http://localhost:8080" -ForegroundColor Cyan
Write-Host "  后端: http://localhost:8083" -ForegroundColor Cyan

Write-Host "`n常用命令:" -ForegroundColor Yellow
Write-Host "  查看日志: docker logs -f chaoxing-backend" -ForegroundColor Cyan
Write-Host "  停止服务: docker-compose down" -ForegroundColor Cyan
Write-Host "  重启服务: docker-compose restart" -ForegroundColor Cyan

if ($failedTests -gt 0) {
    Write-Host "`n⚠ 警告: 部分测试未通过，请检查日志" -ForegroundColor Yellow
    Write-Host "  运行以下命令查看详细日志:" -ForegroundColor Cyan
    Write-Host "  docker logs chaoxing-backend" -ForegroundColor Cyan
    exit 1
} else {
    Write-Host "`n✓ 所有测试通过！系统部署成功！" -ForegroundColor Green
    exit 0
}

