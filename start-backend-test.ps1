# 后端启动测试脚本

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  后端服务启动测试" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# 切换到后端目录
Set-Location "C:\Users\34445\Desktop\chaoxin\exam\backend"

Write-Host "`n1. 检查JAR文件..." -ForegroundColor Yellow
if (Test-Path "target/backend.jar") {
    $jarInfo = Get-Item "target/backend.jar"
    Write-Host "✅ JAR文件存在: $([math]::Round($jarInfo.Length/1MB, 2)) MB" -ForegroundColor Green
} else {
    Write-Host "❌ JAR文件不存在" -ForegroundColor Red
    exit 1
}

Write-Host "`n2. 检查MySQL连接..." -ForegroundColor Yellow
Write-Host "   数据库URL: jdbc:mysql://localhost:3306/chaoxing" -ForegroundColor White
Write-Host "   用户名: root" -ForegroundColor White
Write-Host "   密码: (空)" -ForegroundColor White

Write-Host "`n3. 启动后端服务..." -ForegroundColor Yellow
Write-Host "   端口: 8083" -ForegroundColor White
Write-Host "   日志将显示在下方..." -ForegroundColor White
Write-Host "`n" -NoNewline

# 启动后端
java -jar target/backend.jar






