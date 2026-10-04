@echo off
chcp 65001 >nul
title 自动配置 Cloudflare DNS (nnu.11s.space)
echo ========================================================
echo   正在自动配置 Cloudflare DNS 解析记录
echo   目标: nnu.11s.space -> cname.vercel-dns.com
echo ========================================================
echo.
cd /d "%~dp0"

echo [1/3] 检查本地 Cloudflare 凭据...
node setup-cloudflare-dns.js
if %errorlevel% equ 0 (
    echo.
    echo ========================================================
    echo   🎉 Cloudflare DNS 记录配置成功！
    echo ========================================================
    pause
    exit /b 0
)

echo.
echo [2/3] 需要更新 Cloudflare 授权，正在拉起浏览器...
echo 请在弹出的浏览器页面中点击“允许 / Allow”以完成授权。
call npx wrangler login
if %errorlevel% neq 0 (
    echo [错误] 授权未完成，请重试。
    pause
    exit /b 1
)

echo.
echo [3/3] 授权完成，正在自动调用 Cloudflare API 写入 DNS 记录...
node setup-cloudflare-dns.js

echo.
echo ========================================================
echo   🎉 全部完成！DNS 记录已自动配置。
echo ========================================================
pause
