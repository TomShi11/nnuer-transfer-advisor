# 谷超凡转专业辅助系统 · Vercel 一键云端部署向导 (PowerShell版)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "部署到 Vercel (nnu.11s.space)"

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "   谷超凡转专业辅助系统 · Vercel 一键云端部署向导" -ForegroundColor Yellow
Write-Host "   目标自定义域名: https://nnu.11s.space" -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""

$CurrentDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $CurrentDir

Write-Host "[1/3] 验证并登录 Vercel 账号..." -ForegroundColor Cyan
npx vercel login
if ($LASTEXITCODE -ne 0) {
    Write-Host "[提示] 登录中断，请检查网络或重新运行。" -ForegroundColor Red
    exit 1
}

Write-Host "`n[2/3] 正在发布生产环境 (Vercel Production)..." -ForegroundColor Cyan
npx vercel --prod --yes
if ($LASTEXITCODE -ne 0) {
    Write-Host "[错误] 生产部署失败，请查看上方输出日志。" -ForegroundColor Red
    exit 1
}

Write-Host "`n[3/3] 正在绑定自定义域名 nnu.11s.space..." -ForegroundColor Cyan
npx vercel domains add nnu.11s.space

Write-Host ""
Write-Host "========================================================" -ForegroundColor Green
Write-Host "   🎉 部署与域名绑定完成！" -ForegroundColor Yellow
Write-Host "========================================================" -ForegroundColor Green
Write-Host ""
Write-Host "【重要：Cloudflare DNS 解析配置指引】" -ForegroundColor Cyan
Write-Host "请前往 Cloudflare 仪表盘 (https://dash.cloudflare.com/)：" -ForegroundColor White
Write-Host " 1. 选择你的域名 [11s.space] -> 点击左侧 [DNS] -> [记录]" -ForegroundColor Gray
Write-Host " 2. 点击 [添加记录 (Add record)]，填入以下参数：" -ForegroundColor Gray
Write-Host "    - 类型 (Type)     : CNAME" -ForegroundColor Yellow
Write-Host "    - 名称 (Name)     : nnu" -ForegroundColor Yellow
Write-Host "    - 目标 (Target)   : cname.vercel-dns.com" -ForegroundColor Yellow
Write-Host "    - 代理状态 (Proxy): 仅限 DNS (DNS only / 灰色小云朵) [重要!]" -ForegroundColor Magenta
Write-Host "    - TTL             : 自动 (Auto)" -ForegroundColor Yellow
Write-Host " 3. 点击保存后，等待几分钟解析生效，即可通过 https://nnu.11s.space 访问！" -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Cyan
