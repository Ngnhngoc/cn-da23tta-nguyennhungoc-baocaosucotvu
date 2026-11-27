@echo off
chcp 65001 >nul
title CHAY FLUTTER WEB FRONTEND (:8088)

echo =======================================================
echo    KHOI DONG FLUTTER WEB FRONTEND (PORT 8088)
echo =======================================================
echo.

if exist "%~dp0..\tvu_mobile\build\web\index.html" (
    echo [OK] Phat hien ban build web san co!
    echo Dang khoi dong Web Server sieu toc tai: http://localhost:8088
    echo.
    cd /d "%~dp0..\tvu_mobile\build\web"
    php -S 0.0.0.0:8088
) else (
    echo Dang khoi dong bang Flutter Development Server...
    cd /d "%~dp0..\tvu_mobile"
    flutter run -d web-server --web-hostname=0.0.0.0 --web-port=8088 --release
)
