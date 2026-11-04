@echo off
chcp 65001 >nul
title HE THONG BAO CAO SU CO CO SO VAT CHAT TVU

echo =======================================================
echo    HE THONG BAO CAO SU CO CO SO VAT CHAT TVU
echo =======================================================
echo.

:: 1. Kiem tra MySQL Laragon
echo [1/3] Kiem tra ket noi Database (MySQL port 3306)...
netstat -ano | findstr :3306 >nul
if %errorlevel% equ 0 (
    echo    - MySQL dang hoat dong tot!
) else (
    echo    - CANH BAO: MySQL chua bat! Vui long bat Laragon/MySQL truoc khi chay.
)

:: 2. Khoi dong Backend Laravel
echo.
echo [2/3] Dang khoi dong Backend Laravel tren port 8000...
start "TVU Backend (Laravel :8000)" cmd /k "cd /d %~dp0tvu_backend && php artisan serve --host=0.0.0.0 --port=8000"

:: 3. Khoi dong Frontend Flutter Web
echo.
echo [3/3] Dang khoi dong Frontend Flutter Web tren port 8088...
start "TVU Frontend (Flutter :8088)" cmd /k "cd /d %~dp0tvu_mobile && flutter run -d web-server --web-hostname=0.0.0.0 --web-port=8088"

echo.
echo =======================================================
echo   HE THONG DA KHOI DONG THANH CONG!
echo.
echo   - Backend API  : http://localhost:8000
echo   - Frontend Web : http://localhost:8088
echo.
echo   De DUNG he thong: chay file stop_system.bat
echo =======================================================
pause
