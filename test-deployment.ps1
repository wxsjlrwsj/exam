# 部署测试脚本 - 测试教师端功能
# 此脚本将测试所有新部署的教师端API

Write-Host "========================================" -ForegroundColor Magenta
Write-Host "  教师端API全面测试" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta

$baseUrl = "http://localhost:8083"
$frontendUrl = "http://localhost:8080"

# 测试统计
$totalTests = 0
$passedTests = 0
$failedTests = 0
$skippedTests = 0

# 测试结果数组
$testResults = @()

# 测试函数
function Test-Endpoint {
    param (
        [string]$Name,
        [string]$Url,
        [string]$Method = "GET",
        [string]$Token = $null,
        [object]$Body = $null,
        [int[]]$ExpectedStatus = @(200)
    )
    
    $script:totalTests++
    
    Write-Host "`n[$script:totalTests] 测试: $Name" -ForegroundColor Cyan
    Write-Host "    URL: $Method $Url" -ForegroundColor Gray
    
    try {
        $headers = @{
            "Content-Type" = "application/json"
        }
        
        if ($Token) {
            $headers["Authorization"] = "Bearer $Token"
        }
        
        $params = @{
            Uri = $Url
            Method = $Method
            Headers = $headers
            UseBasicParsing = $true
            TimeoutSec = 10
        }
        
        if ($Body) {
            $params["Body"] = ($Body | ConvertTo-Json -Depth 5)
        }
        
        $response = Invoke-WebRequest @params
        
        if ($response.StatusCode -in $ExpectedStatus) {
            Write-Host "    ✓ 通过 (状态码: $($response.StatusCode))" -ForegroundColor Green
            $script:passedTests++
            
            $result = [PSCustomObject]@{
                Test = $Name
                Status = "PASS"
                StatusCode = $response.StatusCode
                Message = "成功"
            }
            $script:testResults += $result
            
            return @{
                Success = $true
                StatusCode = $response.StatusCode
                Content = $response.Content
            }
        } else {
            Write-Host "    ✖ 失败 (状态码: $($response.StatusCode), 期望: $($ExpectedStatus -join ','))" -ForegroundColor Red
            $script:failedTests++
            
            $result = [PSCustomObject]@{
                Test = $Name
                Status = "FAIL"
                StatusCode = $response.StatusCode
                Message = "状态码不符合期望"
            }
            $script:testResults += $result
            
            return @{
                Success = $false
                StatusCode = $response.StatusCode
                Content = $response.Content
            }
        }
    } catch {
        $statusCode = $null
        if ($_.Exception.Response) {
            $statusCode = [int]$_.Exception.Response.StatusCode.value__
        }
        
        if ($statusCode -and ($statusCode -in $ExpectedStatus)) {
            Write-Host "    ✓ 通过 (状态码: $statusCode - 符合预期)" -ForegroundColor Green
            $script:passedTests++
            
            $result = [PSCustomObject]@{
                Test = $Name
                Status = "PASS"
                StatusCode = $statusCode
                Message = "符合预期的错误状态"
            }
            $script:testResults += $result
            
            return @{
                Success = $true
                StatusCode = $statusCode
                Content = $null
            }
        } else {
            Write-Host "    ✖ 失败 (错误: $($_.Exception.Message))" -ForegroundColor Red
            if ($statusCode) {
                Write-Host "    状态码: $statusCode" -ForegroundColor Gray
            }
            $script:failedTests++
            
            $result = [PSCustomObject]@{
                Test = $Name
                Status = "FAIL"
                StatusCode = $statusCode
                Message = $_.Exception.Message
            }
            $script:testResults += $result
            
            return @{
                Success = $false
                StatusCode = $statusCode
                Content = $null
            }
        }
    }
}

# ==================== 第一部分：基础服务检查 ====================
Write-Host "`n========================================" -ForegroundColor Blue
Write-Host "第一部分：基础服务检查" -ForegroundColor Blue
Write-Host "========================================" -ForegroundColor Blue

# 1. 检查前端
Test-Endpoint -Name "前端服务" -Url $frontendUrl

# 2. 检查后端健康（期望401或403，因为需要认证）
Test-Endpoint -Name "后端服务可达性" -Url "$baseUrl/api/subjects" -ExpectedStatus @(200, 401, 403)

# ==================== 第二部分：公开接口测试 ====================
Write-Host "`n========================================" -ForegroundColor Blue
Write-Host "第二部分：公开接口测试" -ForegroundColor Blue
Write-Host "========================================" -ForegroundColor Blue

# 3. 测试科目列表（根据实际权限配置，可能需要认证）
$result = Test-Endpoint -Name "科目列表API" -Url "$baseUrl/api/subjects" -ExpectedStatus @(200, 401, 403)

# ==================== 第三部分：认证接口测试 ====================
Write-Host "`n========================================" -ForegroundColor Blue
Write-Host "第三部分：需要认证的接口测试" -ForegroundColor Blue
Write-Host "========================================" -ForegroundColor Blue

Write-Host "`n注意: 以下测试需要有效的认证令牌" -ForegroundColor Yellow
Write-Host "如果没有令牌，这些测试将返回401/403，这是正常的" -ForegroundColor Yellow

# 4. 班级列表（需要认证）
Test-Endpoint -Name "班级列表API" -Url "$baseUrl/api/classes?all=true" -ExpectedStatus @(200, 401, 403)

# 5. 考试列表（需要认证）
Test-Endpoint -Name "考试列表API" -Url "$baseUrl/api/exams?status=0&page=1&size=10" -ExpectedStatus @(200, 401, 403)

# 6. 试卷列表（需要认证）
Test-Endpoint -Name "试卷列表API" -Url "$baseUrl/api/papers?page=1&size=10" -ExpectedStatus @(200, 401, 403)

# 7. 题库列表（需要认证）
Test-Endpoint -Name "题库列表API" -Url "$baseUrl/api/questions?page=1&size=10" -ExpectedStatus @(200, 401, 403)

# ==================== 第四部分：数据库完整性检查 ====================
Write-Host "`n========================================" -ForegroundColor Blue
Write-Host "第四部分：数据库完整性检查" -ForegroundColor Blue
Write-Host "========================================" -ForegroundColor Blue

Write-Host "`n检查数据库表..." -ForegroundColor Cyan

$tables = @(
    "biz_exam_student",
    "biz_class",
    "biz_class_student",
    "biz_monitor_warning",
    "biz_score_adjustment",
    "biz_subject"
)

foreach ($table in $tables) {
    $script:totalTests++
    try {
        $result = docker exec chaoxing-mysql mysql -uroot -proot chaoxing -e "SELECT COUNT(*) as count FROM $table;" 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "    ✓ 表 $table 存在且可查询" -ForegroundColor Green
            $script:passedTests++
            
            $testResult = [PSCustomObject]@{
                Test = "数据库表: $table"
                Status = "PASS"
                StatusCode = "N/A"
                Message = "表存在且可查询"
            }
            $script:testResults += $testResult
        } else {
            Write-Host "    ✖ 表 $table 查询失败" -ForegroundColor Red
            $script:failedTests++
            
            $testResult = [PSCustomObject]@{
                Test = "数据库表: $table"
                Status = "FAIL"
                StatusCode = "N/A"
                Message = "查询失败"
            }
            $script:testResults += $testResult
        }
    } catch {
        Write-Host "    ✖ 表 $table 检查异常: $($_.Exception.Message)" -ForegroundColor Red
        $script:failedTests++
        
        $testResult = [PSCustomObject]@{
            Test = "数据库表: $table"
            Status = "FAIL"
            StatusCode = "N/A"
            Message = $_.Exception.Message
        }
        $script:testResults += $testResult
    }
}

# 检查初始数据
Write-Host "`n检查初始数据..." -ForegroundColor Cyan

$script:totalTests++
$subjectCount = docker exec chaoxing-mysql mysql -uroot -proot chaoxing -e "SELECT COUNT(*) as count FROM biz_subject;" 2>&1 | Select-String -Pattern "^\d+$"
if ($subjectCount -and [int]$subjectCount.Line -gt 0) {
    Write-Host "    ✓ 科目表有初始数据 (共 $($subjectCount.Line) 条)" -ForegroundColor Green
    $script:passedTests++
    
    $testResult = [PSCustomObject]@{
        Test = "科目初始数据"
        Status = "PASS"
        StatusCode = "N/A"
        Message = "共 $($subjectCount.Line) 条数据"
    }
    $script:testResults += $testResult
} else {
    Write-Host "    ✖ 科目表无初始数据" -ForegroundColor Red
    $script:failedTests++
    
    $testResult = [PSCustomObject]@{
        Test = "科目初始数据"
        Status = "FAIL"
        StatusCode = "N/A"
        Message = "无数据"
    }
    $script:testResults += $testResult
}

$script:totalTests++
$classCount = docker exec chaoxing-mysql mysql -uroot -proot chaoxing -e "SELECT COUNT(*) as count FROM biz_class;" 2>&1 | Select-String -Pattern "^\d+$"
if ($classCount -and [int]$classCount.Line -gt 0) {
    Write-Host "    ✓ 班级表有初始数据 (共 $($classCount.Line) 条)" -ForegroundColor Green
    $script:passedTests++
    
    $testResult = [PSCustomObject]@{
        Test = "班级初始数据"
        Status = "PASS"
        StatusCode = "N/A"
        Message = "共 $($classCount.Line) 条数据"
    }
    $script:testResults += $testResult
} else {
    Write-Host "    ✖ 班级表无初始数据" -ForegroundColor Red
    $script:failedTests++
    
    $testResult = [PSCustomObject]@{
        Test = "班级初始数据"
        Status = "FAIL"
        StatusCode = "N/A"
        Message = "无数据"
    }
    $script:testResults += $testResult
}

# ==================== 第五部分：日志检查 ====================
Write-Host "`n========================================" -ForegroundColor Blue
Write-Host "第五部分：日志检查" -ForegroundColor Blue
Write-Host "========================================" -ForegroundColor Blue

Write-Host "`n检查后端日志中的错误..." -ForegroundColor Cyan
$logs = docker logs chaoxing-backend --tail 50 2>&1
$errors = $logs | Select-String -Pattern "ERROR"

if ($errors.Count -eq 0) {
    Write-Host "    ✓ 未发现错误日志" -ForegroundColor Green
} else {
    Write-Host "    ⚠ 发现 $($errors.Count) 条错误日志:" -ForegroundColor Yellow
    $errors | ForEach-Object {
        Write-Host "      $_" -ForegroundColor Gray
    }
}

# ==================== 最终报告 ====================
Write-Host "`n" -NoNewline
Write-Host "========================================" -ForegroundColor Green
Write-Host "          测试完成" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

Write-Host "`n测试统计:" -ForegroundColor Yellow
Write-Host "  总测试数: $totalTests" -ForegroundColor Cyan
Write-Host "  通过: $passedTests" -ForegroundColor Green
Write-Host "  失败: $failedTests" -ForegroundColor $(if ($failedTests -eq 0) { "Green" } else { "Red" })
Write-Host "  跳过: $skippedTests" -ForegroundColor Gray

$passRate = if ($totalTests -gt 0) { [math]::Round(($passedTests / $totalTests) * 100, 2) } else { 0 }
Write-Host "`n通过率: $passRate%" -ForegroundColor $(if ($passRate -ge 80) { "Green" } elseif ($passRate -ge 60) { "Yellow" } else { "Red" })

# 显示详细测试结果表格
Write-Host "`n详细测试结果:" -ForegroundColor Yellow
$testResults | Format-Table -AutoSize

# 服务状态
Write-Host "`n当前服务状态:" -ForegroundColor Yellow
docker ps --filter "name=chaoxing" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# 问题诊断
if ($failedTests -gt 0) {
    Write-Host "`n========================================" -ForegroundColor Yellow
    Write-Host "问题诊断建议" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Yellow
    
    Write-Host "`n如果API测试失败（401/403）:" -ForegroundColor Cyan
    Write-Host "  - 这是正常的，需要认证的接口需要先登录获取令牌" -ForegroundColor Gray
    Write-Host "  - 可以通过前端登录后，使用开发者工具获取令牌" -ForegroundColor Gray
    
    Write-Host "`n如果数据库测试失败:" -ForegroundColor Cyan
    Write-Host "  - 检查迁移脚本是否正确执行" -ForegroundColor Gray
    Write-Host "  - 运行: docker exec -i chaoxing-mysql mysql -uroot -proot chaoxing < backend/db_migration_teacher.sql" -ForegroundColor Gray
    
    Write-Host "`n查看详细日志:" -ForegroundColor Cyan
    Write-Host "  docker logs chaoxing-backend" -ForegroundColor Gray
    Write-Host "  docker logs chaoxing-mysql" -ForegroundColor Gray
}

# 访问地址
Write-Host "`n访问地址:" -ForegroundColor Yellow
Write-Host "  前端: $frontendUrl" -ForegroundColor Cyan
Write-Host "  后端: $baseUrl" -ForegroundColor Cyan
Write-Host "  API文档: 参考 backend/TEACHER_API_IMPLEMENTATION.md" -ForegroundColor Cyan

# 返回退出码
if ($failedTests -eq 0) {
    Write-Host "`n✓ 所有测试通过！" -ForegroundColor Green
    exit 0
} else {
    Write-Host "`n⚠ 部分测试失败，请检查日志" -ForegroundColor Yellow
    exit 1
}

