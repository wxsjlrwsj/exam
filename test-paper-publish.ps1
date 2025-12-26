# 试卷发布功能测试脚本

$baseUrl = "http://localhost:8083"
$ErrorActionPreference = "Continue"

Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║          试卷发布功能测试                                  ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

# 测试计数器
$totalTests = 0
$passedTests = 0
$failedTests = 0

function Test-API {
    param(
        [string]$Name,
        [string]$Url,
        [string]$Method = "GET",
        [hashtable]$Headers = @{},
        [string]$Body = $null,
        [int]$ExpectedStatus = 200
    )
    
    $script:totalTests++
    Write-Host "`n[$script:totalTests] $Name" -ForegroundColor Yellow
    
    try {
        $params = @{
            Uri = $Url
            Method = $Method
            Headers = $Headers
            TimeoutSec = 10
            UseBasicParsing = $true
        }
        
        if ($Body) {
            $params.Body = $Body
            $params.ContentType = "application/json"
        }
        
        $response = Invoke-WebRequest @params
        
        if ($response.StatusCode -eq $ExpectedStatus) {
            Write-Host "   ✅ 通过 (状态码: $($response.StatusCode))" -ForegroundColor Green
            $script:passedTests++
            
            # 解析响应内容
            try {
                $content = $response.Content | ConvertFrom-Json
                if ($content.data) {
                    Write-Host "   📄 响应数据: $($content.data | ConvertTo-Json -Compress)" -ForegroundColor Gray
                }
            } catch {}
            
            return $response
        } else {
            Write-Host "   ❌ 失败 (期望: $ExpectedStatus, 实际: $($response.StatusCode))" -ForegroundColor Red
            $script:failedTests++
            return $null
        }
    } catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        if ($statusCode -eq $ExpectedStatus) {
            Write-Host "   ✅ 通过 (状态码: $statusCode)" -ForegroundColor Green
            $script:passedTests++
            return $null
        } else {
            Write-Host "   ❌ 失败: $($_.Exception.Message)" -ForegroundColor Red
            if ($statusCode) {
                Write-Host "      状态码: $statusCode" -ForegroundColor Gray
            }
            $script:failedTests++
            return $null
        }
    }
}

# ============================================
# 第一步：教师登录
# ============================================
Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "  第一步：教师登录" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

$loginBody = @{
    username = "teacher01"
    password = "password123"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/api/auth/login" `
        -Method POST `
        -ContentType "application/json" `
        -Body $loginBody `
        -TimeoutSec 10
    
    if ($loginResponse.code -eq 200 -and $loginResponse.data.token) {
        $token = $loginResponse.data.token
        Write-Host "✅ 教师登录成功！" -ForegroundColor Green
        Write-Host "   Token: $($token.Substring(0, 20))..." -ForegroundColor Gray
        $script:passedTests++
        $script:totalTests++
    } else {
        Write-Host "❌ 登录失败：$($loginResponse.message)" -ForegroundColor Red
        $token = $null
        $script:failedTests++
        $script:totalTests++
        exit 1
    }
} catch {
    Write-Host "❌ 登录请求失败: $($_.Exception.Message)" -ForegroundColor Red
    $token = $null
    $script:failedTests++
    $script:totalTests++
    exit 1
}

$authHeaders = @{ Authorization = "Bearer $token" }

# ============================================
# 第二步：获取试卷列表
# ============================================
Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "  第二步：获取试卷列表" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

$papersResponse = Test-API -Name "获取试卷列表" `
    -Url "$baseUrl/api/papers?page=1&size=10" `
    -Headers $authHeaders

if ($papersResponse) {
    try {
        $papersData = $papersResponse.Content | ConvertFrom-Json
        $papers = $papersData.data.list
        
        if ($papers -and $papers.Count -gt 0) {
            Write-Host "`n   找到 $($papers.Count) 个试卷：" -ForegroundColor Cyan
            foreach ($paper in $papers) {
                $statusText = switch ($paper.status) {
                    0 { "草稿" }
                    1 { "已使用" }
                    2 { "已发布" }
                    default { "未知" }
                }
                Write-Host "   - ID: $($paper.id), 名称: $($paper.name), 状态: $statusText" -ForegroundColor White
            }
            
            # 选择第一个草稿状态的试卷进行测试
            $testPaper = $papers | Where-Object { $_.status -eq 0 } | Select-Object -First 1
            
            if ($testPaper) {
                $testPaperId = $testPaper.id
                Write-Host "`n   ✅ 选择试卷 ID: $testPaperId 进行发布测试" -ForegroundColor Green
            } else {
                Write-Host "`n   ⚠️  没有找到草稿状态的试卷，将创建一个测试试卷" -ForegroundColor Yellow
                $testPaperId = $null
            }
        } else {
            Write-Host "`n   ⚠️  没有找到试卷，将创建一个测试试卷" -ForegroundColor Yellow
            $testPaperId = $null
        }
    } catch {
        Write-Host "   ⚠️  解析试卷列表失败" -ForegroundColor Yellow
        $testPaperId = $null
    }
} else {
    $testPaperId = $null
}

# ============================================
# 第三步：创建测试试卷（如果需要）
# ============================================
if (-not $testPaperId) {
    Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "  第三步：创建测试试卷" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    
    # 先获取题目列表
    try {
        $questionsResponse = Invoke-RestMethod -Uri "$baseUrl/api/questions?page=1&size=5" `
            -Headers $authHeaders `
            -TimeoutSec 10
        
        if ($questionsResponse.data.list -and $questionsResponse.data.list.Count -gt 0) {
            $questions = $questionsResponse.data.list | Select-Object -First 3
            
            $createPaperBody = @{
                name = "测试试卷-$(Get-Date -Format 'yyyyMMddHHmmss')"
                subject = "测试科目"
                passScore = 60
                questions = @($questions | ForEach-Object { 
                    @{ id = $_.id; score = 10 } 
                })
            } | ConvertTo-Json -Depth 10
            
            Write-Host "   创建试卷，包含 $($questions.Count) 个题目..." -ForegroundColor Yellow
            
            $createResponse = Invoke-RestMethod -Uri "$baseUrl/api/papers" `
                -Method POST `
                -Headers $authHeaders `
                -ContentType "application/json" `
                -Body $createPaperBody `
                -TimeoutSec 10
            
            if ($createResponse.code -eq 200) {
                $testPaperId = $createResponse.data.id
                Write-Host "   ✅ 试卷创建成功！ID: $testPaperId" -ForegroundColor Green
                $script:passedTests++
                $script:totalTests++
            } else {
                Write-Host "   ❌ 试卷创建失败" -ForegroundColor Red
                $script:failedTests++
                $script:totalTests++
            }
        } else {
            Write-Host "   ❌ 没有可用的题目，无法创建试卷" -ForegroundColor Red
            $script:failedTests++
            $script:totalTests++
        }
    } catch {
        Write-Host "   ❌ 创建试卷失败: $($_.Exception.Message)" -ForegroundColor Red
        $script:failedTests++
        $script:totalTests++
    }
}

# ============================================
# 第四步：测试发布试卷
# ============================================
if ($testPaperId) {
    Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "  第四步：测试发布试卷" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    
    Test-API -Name "发布试卷 (PUT /api/papers/$testPaperId/publish)" `
        -Url "$baseUrl/api/papers/$testPaperId/publish" `
        -Method "PUT" `
        -Headers $authHeaders
    
    # ============================================
    # 第五步：验证试卷状态
    # ============================================
    Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "  第五步：验证试卷状态" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    
    $detailResponse = Test-API -Name "获取试卷详情" `
        -Url "$baseUrl/api/papers/$testPaperId" `
        -Headers $authHeaders
    
    if ($detailResponse) {
        try {
            $paperDetail = ($detailResponse.Content | ConvertFrom-Json).data
            Write-Host "`n   试卷状态: $($paperDetail.status)" -ForegroundColor $(if ($paperDetail.status -eq "published") { "Green" } else { "Red" })
            
            if ($paperDetail.status -eq "published") {
                Write-Host "   ✅ 试卷已成功发布！" -ForegroundColor Green
            } else {
                Write-Host "   ❌ 试卷状态不正确" -ForegroundColor Red
            }
        } catch {
            Write-Host "   ⚠️  无法解析试卷详情" -ForegroundColor Yellow
        }
    }
    
    # ============================================
    # 第六步：测试取消发布
    # ============================================
    Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "  第六步：测试取消发布" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    
    Test-API -Name "取消发布试卷 (PUT /api/papers/$testPaperId/unpublish)" `
        -Url "$baseUrl/api/papers/$testPaperId/unpublish" `
        -Method "PUT" `
        -Headers $authHeaders
    
    # 再次验证状态
    $detailResponse2 = Test-API -Name "再次获取试卷详情" `
        -Url "$baseUrl/api/papers/$testPaperId" `
        -Headers $authHeaders
    
    if ($detailResponse2) {
        try {
            $paperDetail2 = ($detailResponse2.Content | ConvertFrom-Json).data
            Write-Host "`n   试卷状态: $($paperDetail2.status)" -ForegroundColor $(if ($paperDetail2.status -eq "draft") { "Green" } else { "Red" })
            
            if ($paperDetail2.status -eq "draft") {
                Write-Host "   ✅ 试卷已成功取消发布！" -ForegroundColor Green
            } else {
                Write-Host "   ❌ 试卷状态不正确" -ForegroundColor Red
            }
        } catch {
            Write-Host "   ⚠️  无法解析试卷详情" -ForegroundColor Yellow
        }
    }
}

# ============================================
# 测试总结
# ============================================
Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "║                    测试结果总结                            ║" -ForegroundColor Magenta
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Magenta

Write-Host "`n总测试数:   $totalTests" -ForegroundColor White
Write-Host "通过:       $passedTests" -ForegroundColor Green
Write-Host "失败:       $failedTests" -ForegroundColor Red
$successRate = if ($totalTests -gt 0) { [math]::Round(($passedTests / $totalTests) * 100, 2) } else { 0 }
Write-Host "成功率:     $successRate%" -ForegroundColor $(if ($successRate -ge 80) { "Green" } elseif ($successRate -ge 60) { "Yellow" } else { "Red" })

if ($failedTests -eq 0) {
    Write-Host "`n🎉 所有测试通过！试卷发布功能正常！" -ForegroundColor Green
} elseif ($successRate -ge 80) {
    Write-Host "`n✅ 大部分测试通过，功能基本正常" -ForegroundColor Yellow
} else {
    Write-Host "`n⚠️  多个测试失败，请检查配置" -ForegroundColor Red
}

Write-Host ""


