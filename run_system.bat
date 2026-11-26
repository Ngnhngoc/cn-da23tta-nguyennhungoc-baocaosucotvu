@echo off
chcp 65001 >nul
title HE THONG BAO CAO SU CO CO SO VAT CHAT TVU

echo =======================================================
echo    HE THONG BAO CAO SU CO CO SO VAT CHAT TVU
echo =======================================================
echo.

:: 1. Kiem tra va Tu dong khoi dong MySQL (port 3306)
echo [1/3] Kiem tra ket noi Database (MySQL port 3306)...
netstat -ano | findstr :3306 >nul
if %errorlevel% equ 0 (
    echo    - MySQL dang hoat dong tot!
) else (
    echo    - MySQL chua bat, dang tu dong khoi dong MySQL...
    for /d %%D in ("C:\laragon\bin\mysql\mysql-*") do (
        if exist "%%D\bin\mysqld.exe" (
            start "" /B "%%D\bin\mysqld.exe"
            timeout /t 2 /nobreak >nul
        )
    )
    netstat -ano | findstr :3306 >nul
    if %errorlevel% equ 0 (
        echo    - Da khoi dong MySQL thanh cong!
    ) else (
        echo    - CANH BAO: Vui long mo Laragon va bam 'Start All' neu MySQL chua len!
    )
)

:: 2. Lay dia chi IP mang hien tai cho dien thoai
for /f "tokens=*" %%i in ('powershell -Command "(Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object { $_.InterfaceAlias -like '*Wi-Fi*' -or $_.InterfaceAlias -like '*Wireless*' -or $_.IPAddress -like '172.20.10.*' -or $_.IPAddress -like '192.168.*' } | Select-Object -First 1).IPAddress"') do set CURRENT_IP=%%i
if "%CURRENT_IP%"=="" set CURRENT_IP=172.20.10.2

:: 3. Khoi dong Backend Laravel (:8000)
echo.
echo [2/3] Dang khoi dong Backend Laravel tren port 8000...
start "TVU Backend (Laravel :8000)" cmd /k "cd /d %~dp0tvu_backend && php artisan serve --host=0.0.0.0 --port=8000"

:: 4. Khoi dong Frontend Flutter Web (:8088) ban Release
echo.
echo [3/3] Dang khoi dong Frontend Flutter Web tren port 8088 (Release Mode)...
start "TVU Frontend (Flutter :8088)" cmd /k "cd /d %~dp0tvu_mobile && flutter run -d web-server --web-hostname=0.0.0.0 --web-port=8088 --release"

echo.
echo =======================================================
echo   HE THONG DA DUOC KHOI DONG THANH CONG!
echo.
echo   [1] Tren MAY TINH:
echo       - Ung dung nguoi dung : http://localhost:8088
echo       - Web Quan tri Admin  : http://localhost:8000/admin
echo.
echo   [2] Tren DIEN THOAI (Cung mang Wi-Fi / Hotspot):
echo       - Ung dung nguoi dung : http://%CURRENT_IP%:8088
echo       - Web Quan tri Admin  : http://%CURRENT_IP%:8000/admin
echo.
echo   * LUU Y: Thu nho 2 cua so den (Backend & Frontend), KHONG dong cua so!
echo   * De TAT he thong: Chay file stop_system.bat
echo =======================================================
pause
