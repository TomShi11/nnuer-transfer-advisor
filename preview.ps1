# 谷超凡专属 · 南京师范大学转专业与人生航向辅助系统 本地服务启动与预览脚本
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "谷超凡转专业辅助系统 · 本地预览"

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "   谷超凡专属 · 南京师范大学转专业与人生航向辅助系统" -ForegroundColor Yellow
Write-Host "   仙林校区环境科学与工程学院 · 科学转轨与升维破局指南" -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""

$CurrentDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $CurrentDir

$HtmlPath = Join-Path $CurrentDir "index.html"
if (-not (Test-Path $HtmlPath)) {
    Write-Host "[错误] 未找到 index.html，请确认文件完整性。" -ForegroundColor Red
    exit 1
}

$port = 5200

# 检测是否有 Python 或 Node.js
$hasPython = $null
$hasNode = $null
try { $hasPython = (Get-Command python -ErrorAction SilentlyContinue) } catch {}
try { $hasNode = (Get-Command npx -ErrorAction SilentlyContinue) } catch {}

if ($hasPython) {
    Write-Host "[模式: Python HTTP Server] 正在端口 $port 启动静态服务器..." -ForegroundColor Green
    $url = "http://localhost:$port"
    Start-Process $url
    python -m http.server $port
} elseif ($hasNode) {
    Write-Host "[模式: npx serve] 正在端口 $port 启动静态服务器..." -ForegroundColor Green
    $url = "http://localhost:$port"
    Start-Process $url
    npx -y serve -l $port .
} else {
    Write-Host "[模式: 本地浏览器直开] 正在直接唤起系统默认浏览器..." -ForegroundColor Yellow
    Start-Process $HtmlPath
    Write-Host "页面已在默认浏览器中打开！" -ForegroundColor Green
}
