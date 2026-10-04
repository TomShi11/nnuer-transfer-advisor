@echo off
chcp 65001 >nul
title 部署到 Vercel (nnu.11s.space)
echo ========================================================
echo   谷超凡转专业辅助系统 · Vercel 一键云端部署向导
echo   目标域名: https://nnu.11s.space
echo ========================================================
echo.
cd /d "%~dp0"

echo [1/3] 检查并登录 Vercel 账号...
call npx vercel login
if errorlevel 1 (
    echo [提示] 登录中断，请重新运行或检查网络。
    pause
    exit /b 1
)

echo.
echo [2/3] 正在发布生产环境 (Vercel Production)...
call npx vercel --prod --yes
if errorlevel 1 (
    echo [提示] 部署遇到问题，请检查上方的错误提示。
    pause
    exit /b 1
)

echo.
echo [3/3] 正在关联自定义域名 nnu.11s.space...
call npx vercel domains add nnu.11s.space

echo.
echo ========================================================
echo   🎉 Vercel 项目部署与域名绑定指令已执行！
echo ========================================================
echo.
echo 【关键最后一步：Cloudflare DNS 解析配置】
echo 请登录 Cloudflare 控制台 (https://dash.cloudflare.com/)：
echo 1. 进入域名 [11s.space] -> [DNS] -> [记录 (Records)]
echo 2. 点击 [添加记录 (Add record)]：
echo    - 类型 (Type): CNAME
echo    - 名称 (Name): nnu
echo    - 目标 (Target): cname.vercel-dns.com
echo    - 代理状态 (Proxy status): 仅限 DNS (DNS only / 灰色小云朵)
echo    - TTL: 自动 (Auto)
echo 3. 保存后等待 1~3 分钟生效，即可通过 https://nnu.11s.space 访问！
echo ========================================================
echo.
pause
