# 修复脚本执行权限
# 如果遇到 "cannot be loaded because running scripts is disabled" 错误，运行此脚本

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "修复 PowerShell 脚本执行权限" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# 1. 检查当前执行策略
Write-Host "`n[1/3] 检查当前执行策略..." -ForegroundColor Yellow
$currentPolicy = Get-ExecutionPolicy
Write-Host "当前策略: $currentPolicy" -ForegroundColor Gray

# 2. 尝试设置执行策略（如果需要）
if ($currentPolicy -eq "Restricted") {
    Write-Host "`n[2/3] 正在设置执行策略为 RemoteSigned..." -ForegroundColor Yellow
    try {
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        Write-Host "✓ 执行策略已更新！" -ForegroundColor Green
    } catch {
        Write-Host "⚠ 无法修改执行策略（可能需要管理员权限）" -ForegroundColor Yellow
    }
} else {
    Write-Host "`n[2/3] 执行策略正常，跳过..." -ForegroundColor Green
}

# 3. 解除所有 .ps1 文件的阻止
Write-Host "`n[3/3] 正在解除脚本文件阻止..." -ForegroundColor Yellow
$scriptFiles = Get-ChildItem -Path $PSScriptRoot -Filter "*.ps1"
$unblocked = 0

foreach ($file in $scriptFiles) {
    try {
        Unblock-File -Path $file.FullName -ErrorAction SilentlyContinue
        Write-Host "  ✓ $($file.Name)" -ForegroundColor Gray
        $unblocked++
    } catch {
        Write-Host "  ⚠ $($file.Name) (可能已解除)" -ForegroundColor Yellow
    }
}

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "✓ 修复完成！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "`n已处理 $unblocked 个脚本文件" -ForegroundColor Cyan
Write-Host "`n现在可以正常运行部署脚本了：" -ForegroundColor Yellow
Write-Host "  .\deploy-all.ps1" -ForegroundColor Cyan
Write-Host "  .\deploy-frontend.ps1" -ForegroundColor Cyan
Write-Host "  .\deploy-backend.ps1`n" -ForegroundColor Cyan

