# 学生端考试API测试脚本
# 用于快速验证后端API是否正常工作

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "    学生端考试功能API测试" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$baseUrl = "http://localhost:8083/api"
$studentUsername = "stu001"
$studentPassword = "123456"

# 测试结果统计
$totalTests = 0
$passedTests = 0
$failedTests = 0

function Test-API {
    param(
        [string]$TestName,
        [string]$Url,
        [string]$Method = "GET",
        [hashtable]$Headers = @{},
        [object]$Body = $null
    )
    
    $global:totalTests++
    Write-Host "`n[$global:totalTests] 测试: $TestName" -ForegroundColor Yellow
    Write-Host "请求: $Method $Url" -ForegroundColor Gray
    
    try {
        $params = @{
            Uri = $Url
            Method = $Method
            Headers = $Headers
            ContentType = "application/json"
            ErrorAction = "Stop"
        }
        
        if ($Body -ne $null) {
            $params.Body = ($Body | ConvertTo-Json -Depth 10)
        }
        
        $response = Invoke-RestMethod @params
        
        if ($response.code -eq 200) {
            Write-Host "✓ 通过: $TestName" -ForegroundColor Green
            $global:passedTests++
            return $response
        } else {
            Write-Host "✖ 失败: $TestName - 错误码: $($response.code)" -ForegroundColor Red
            Write-Host "错误信息: $($response.message)" -ForegroundColor Red
            $global:failedTests++
            return $null
        }
    }
    catch {
        Write-Host "✖ 失败: $TestName" -ForegroundColor Red
        Write-Host "错误: $($_.Exception.Message)" -ForegroundColor Red
        $global:failedTests++
        return $null
    }
}

# ==================== 步骤1: 健康检查 ====================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "步骤1: 服务健康检查" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

try {
    $healthCheck = Invoke-RestMethod -Uri "http://localhost:8083/actuator/health" -Method GET -ErrorAction SilentlyContinue
    Write-Host "✓ 后端服务正常运行" -ForegroundColor Green
}
catch {
    try {
        $response = Invoke-WebRequest -Uri $baseUrl -Method GET -ErrorAction SilentlyContinue
        Write-Host "✓ 后端服务正常运行（备用检查）" -ForegroundColor Green
    }
    catch {
        Write-Host "✖ 后端服务未响应" -ForegroundColor Red
        Write-Host "请确认Docker服务是否正常启动：docker-compose ps" -ForegroundColor Yellow
        exit 1
    }
}

# ==================== 步骤2: 登录获取Token ====================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "步骤2: 学生登录" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$loginBody = @{
    username = $studentUsername
    password = $studentPassword
}

$loginResponse = Test-API -TestName "学生登录" -Url "$baseUrl/auth/login" -Method "POST" -Body $loginBody

if ($loginResponse -eq $null) {
    Write-Host "`n无法继续测试，登录失败" -ForegroundColor Red
    Write-Host "请检查：" -ForegroundColor Yellow
    Write-Host "1. 用户名和密码是否正确" -ForegroundColor Yellow
    Write-Host "2. 数据库是否已初始化" -ForegroundColor Yellow
    Write-Host "3. 后端服务是否正常" -ForegroundColor Yellow
    exit 1
}

$token = $loginResponse.data.token
$authHeaders = @{
    "Authorization" = "Bearer $token"
}

Write-Host "✓ 获取到Token: $($token.Substring(0, [Math]::Min(20, $token.Length)))..." -ForegroundColor Green

# ==================== 步骤3: 获取考试列表 ====================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "步骤3: 获取考试列表" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$examListResponse = Test-API -TestName "获取考试列表（全部）" -Url "$baseUrl/student/exams?page=1&size=10" -Headers $authHeaders

if ($examListResponse -ne $null -and $examListResponse.data.list) {
    Write-Host "  考试总数: $($examListResponse.data.total)" -ForegroundColor Cyan
    Write-Host "  本页数量: $($examListResponse.data.list.Count)" -ForegroundColor Cyan
    
    if ($examListResponse.data.list.Count -gt 0) {
        $firstExam = $examListResponse.data.list[0]
        Write-Host "`n  第一个考试信息：" -ForegroundColor Cyan
        Write-Host "    - ID: $($firstExam.id)" -ForegroundColor Gray
        Write-Host "    - 名称: $($firstExam.name)" -ForegroundColor Gray
        Write-Host "    - 学科: $($firstExam.subject)" -ForegroundColor Gray
        Write-Host "    - 状态: $($firstExam.status)" -ForegroundColor Gray
    }
}

# 测试筛选功能
$null = Test-API -TestName "按状态筛选（进行中）" -Url "$baseUrl/student/exams?status=ongoing&page=1&size=10" -Headers $authHeaders
$null = Test-API -TestName "按学科筛选" -Url "$baseUrl/student/exams?subject=数学&page=1&size=10" -Headers $authHeaders

# ==================== 步骤4: 获取试卷（如果有可用考试）====================
if ($examListResponse -ne $null -and $examListResponse.data.list.Count -gt 0) {
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "步骤4: 获取试卷题目" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    
    $examId = $examListResponse.data.list[0].id
    $paperResponse = Test-API -TestName "获取试卷题目" -Url "$baseUrl/student/exams/$examId/paper" -Headers $authHeaders
    
    if ($paperResponse -ne $null -and $paperResponse.data.questions) {
        Write-Host "  题目总数: $($paperResponse.data.questions.Count)" -ForegroundColor Cyan
        
        if ($paperResponse.data.questions.Count -gt 0) {
            $firstQuestion = $paperResponse.data.questions[0]
            Write-Host "`n  第一道题信息：" -ForegroundColor Cyan
            Write-Host "    - ID: $($firstQuestion.id)" -ForegroundColor Gray
            Write-Host "    - 类型: $($firstQuestion.type_code)" -ForegroundColor Gray
            Write-Host "    - 分值: $($firstQuestion.score)" -ForegroundColor Gray
            Write-Host "    - 内容: $($firstQuestion.content.Substring(0, [Math]::Min(50, $firstQuestion.content.Length)))..." -ForegroundColor Gray
        }
        
        # ==================== 步骤5: 提交试卷（模拟） ====================
        Write-Host "`n========================================" -ForegroundColor Cyan
        Write-Host "步骤5: 模拟提交试卷" -ForegroundColor Cyan
        Write-Host "========================================" -ForegroundColor Cyan
        
        Write-Host "注意: 实际测试会提交答案到数据库" -ForegroundColor Yellow
        Write-Host "是否继续测试提交功能？(Y/N): " -ForegroundColor Yellow -NoNewline
        $continue = Read-Host
        
        if ($continue -eq "Y" -or $continue -eq "y") {
            # 构造模拟答案
            $mockAnswers = @{}
            foreach ($q in $paperResponse.data.questions) {
                $qid = $q.id.ToString()
                switch ($q.type_code) {
                    "SINGLE" { $mockAnswers[$qid] = "A" }
                    "MULTI" { $mockAnswers[$qid] = @("A", "B") }
                    "TRUE_FALSE" { $mockAnswers[$qid] = "T" }
                    "FILL" { $mockAnswers[$qid] = "这是填空答案" }
                    "SHORT" { $mockAnswers[$qid] = "这是简答题答案" }
                    default { $mockAnswers[$qid] = "测试答案" }
                }
            }
            
            $submitBody = @{
                answers = $mockAnswers
                durationUsed = 1800
            }
            
            $submitResponse = Test-API -TestName "提交试卷" -Url "$baseUrl/student/exams/$examId/submit" -Method "POST" -Headers $authHeaders -Body $submitBody
            
            if ($submitResponse -ne $null) {
                Write-Host "✓ 试卷提交成功" -ForegroundColor Green
            }
        }
        else {
            Write-Host "跳过提交测试" -ForegroundColor Gray
        }
    }
    
    # ==================== 步骤6: 查看考试结果 ====================
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "步骤6: 查看考试结果" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    
    $resultResponse = Test-API -TestName "查看考试结果" -Url "$baseUrl/student/exams/$examId/result" -Headers $authHeaders
    
    if ($resultResponse -ne $null) {
        if ($resultResponse.data.record) {
            Write-Host "  成绩记录：" -ForegroundColor Cyan
            Write-Host "    - 得分: $($resultResponse.data.record.score)" -ForegroundColor Gray
            Write-Host "    - 状态: $($resultResponse.data.record.status)" -ForegroundColor Gray
        }
        if ($resultResponse.data.questions) {
            Write-Host "  题目数量: $($resultResponse.data.questions.Count)" -ForegroundColor Cyan
        }
        if ($resultResponse.data.answers) {
            Write-Host "  答案记录数: $($resultResponse.data.answers.Count)" -ForegroundColor Cyan
        }
    }
}
else {
    Write-Host "`n没有可用的考试，跳过试卷相关测试" -ForegroundColor Yellow
}

# ==================== 测试总结 ====================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "测试总结" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "总测试数: $totalTests" -ForegroundColor Cyan
Write-Host "通过: $passedTests" -ForegroundColor Green
Write-Host "失败: $failedTests" -ForegroundColor Red
Write-Host ""

if ($failedTests -eq 0) {
    Write-Host "🎉 所有测试通过！" -ForegroundColor Green
    Write-Host "学生端考试功能后端API运行正常" -ForegroundColor Green
}
else {
    Write-Host "⚠ 有 $failedTests 个测试失败" -ForegroundColor Yellow
    Write-Host "请查看上面的错误信息进行排查" -ForegroundColor Yellow
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "下一步操作建议" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "1. 访问前端页面测试完整功能: http://localhost:8080" -ForegroundColor Yellow
Write-Host "2. 查看详细测试指南: docs/EXAM_FEATURE_TEST_GUIDE.md" -ForegroundColor Yellow
Write-Host "3. 查看后端日志: docker-compose logs backend" -ForegroundColor Yellow
Write-Host ""

