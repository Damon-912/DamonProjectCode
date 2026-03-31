# DRG 前端开发服务器启动脚本
Write-Host "正在启动 DRG 前端开发服务器..." -ForegroundColor Green
Write-Host ""

$frontendPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $frontendPath

Write-Host "当前目录: $frontendPath" -ForegroundColor Cyan
Write-Host ""

# 启动开发服务器
npm run dev

Write-Host ""
Write-Host "按任意键退出..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
