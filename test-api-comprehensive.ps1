# 综合API测试脚本

$baseUrl = "http://localhost:8083"
$ErrorActionPreference = "Continue"

Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║          超星考试系统 - 综合功能测试                      ║" -ForegroundColor Cyan
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
    Write-Host "`n[$script:totalTests] 测试: $Name" -ForegroundColor Yellow
    
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
            return $true
        } else {
            Write-Host "   ❌ 失败 (期望: $ExpectedStatus, 实际: $($response.StatusCode))" -ForegroundColor Red
            $script:failedTests++
            return $false
        }
    } catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        if ($statusCode -eq $ExpectedStatus) {
            Write-Host "   ✅ 通过 (状态码: $statusCode)" -ForegroundColor Green
            $script:passedTests++
            return $true
        } else {
            Write-Host "   ❌ 失败: $($_.Exception.Message)" -ForegroundColor Red
            if ($statusCode) {
                Write-Host "      状态码: $statusCode" -ForegroundColor Gray
            }
            $script:failedTests++
            return $false
        }
    }
}

# ============================================
# 第一部分：基础健康检查
# ============================================
Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "  第一部分：基础健康检查" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

Test-API -Name "健康检查" -Url "$baseUrl/actuator/health"

# ============================================
# 第二部分：认证测试
# ============================================
Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "  第二部分：认证测试" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

# 尝试学生登录
Write-Host "`n尝试登录获取Token..." -ForegroundColor Yellow
$loginBody = @{
    username = "student01"
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
        Write-Host "✅ 登录成功！Token: $($token.Substring(0, 20))..." -ForegroundColor Green
        $script:passedTests++
        $script:totalTests++
    } else {
        Write-Host "❌ 登录失败：$($loginResponse.message)" -ForegroundColor Red
        $token = $null
        $script:failedTests++
        $script:totalTests++
    }
} catch {
    Write-Host "❌ 登录请求失败: $($_.Exception.Message)" -ForegroundColor Red
    $token = $null
    $script:failedTests++
    $script:totalTests++
}

# ============================================
# 第三部分：学生端API测试
# ============================================
if ($token) {
    Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "  第三部分：学生端API测试" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    
    $authHeaders = @{ Authorization = "Bearer $token" }
    
    # 考试管理
    Test-API -Name "获取考试列表" -Url "$baseUrl/api/student/exams" -Headers $authHeaders
    
    # 题集管理
    Test-API -Name "获取题集列表" -Url "$baseUrl/api/student/collections" -Headers $authHeaders
    
    # 错题本
    Test-API -Name "获取错题统计" -Url "$baseUrl/api/student/errors/stats" -Headers $authHeaders
    Test-API -Name "获取错题列表" -Url "$baseUrl/api/student/errors?page=1&size=10" -Headers $authHeaders
    
    # 练题题库
    Test-API -Name "获取公开题库" -Url "$baseUrl/api/student/practice/questions?page=1&size=10" -Headers $authHeaders
    
    # 用户中心
    Test-API -Name "获取个人信息" -Url "$baseUrl/api/student/profile" -Headers $authHeaders
    Test-API -Name "获取学习统计" -Url "$baseUrl/api/student/profile/stats" -Headers $authHeaders
}

# ============================================
# 第四部分：权限测试（无Token访问）
# ============================================
Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "  第四部分：权限测试" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

Test-API -Name "无Token访问学生API（应返回403）" `
    -Url "$baseUrl/api/student/exams" `
    -ExpectedStatus 403

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
    Write-Host "`n🎉 所有测试通过！系统运行正常！" -ForegroundColor Green
} elseif ($successRate -ge 80) {
    Write-Host "`n✅ 大部分测试通过，系统基本正常" -ForegroundColor Yellow
} else {
    Write-Host "`n⚠️  多个测试失败，请检查系统配置" -ForegroundColor Red
}

Write-Host ""



