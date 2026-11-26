@echo off
chcp 65001 >nul
title 1. KHOI DONG BACKEND TVU (CHO LDPLAYER & WEB ADMIN)

echo =======================================================
echo    HE THONG BAO CAO SU CO CO SO VAT CHAT TVU
echo    [1] KHOI DONG MYSQL ^& BACKEND LARAVEL (:8000)
echo =======================================================
echo.

:: 1. Kiem tra va Tu dong khoi dong MySQL (port 3306)
echo [1/2] Kiem tra ket noi Database (MySQL port 3306)...
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
        echo    - CANH BAO: Vui long mo Laragon va bam 'Start All' truoc!
    )
)

:: 2. Lay dia chi IP mang LAN hien tai (du phong neu LDPlayer dung Bridge)
for /f "tokens=*" %%i in ('powershell -Command "(Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object { $_.InterfaceAlias -like '*Wi-Fi*' -or $_.InterfaceAlias -like '*Ethernet*' -or $_.IPAddress -like '192.168.*' } | Select-Object -First 1).IPAddress"') do set CURRENT_IP=%%i
if "%CURRENT_IP%"=="" set CURRENT_IP=127.0.0.1

:: 3. Khoi dong Backend Laravel (:8000)
echo.
echo [2/2] Dang khoi dong Backend Laravel tren port 8000...
start "TVU Backend (Laravel :8000)" cmd /k "cd /d %~dp0tvu_backend && php artisan serve --host=0.0.0.0 --port=8000"

echo.
echo =======================================================
echo   BACKEND DA SAN SANG PHUC VU LDPLAYER!
echo.
echo   - API cho LDPlayer (Mac dinh) : http://10.0.2.2:8000/api
echo   - API theo IP mang LAN        : http://%CURRENT_IP%:8000/api
echo   - Web Quan tri Admin (PC)     : http://localhost:8000/admin
echo.
echo   * LUU Y: Thu nho cua so den Backend, KHONG tat khi dang test!
echo   * De TAT he thong: Chay file 3_stop_system.bat
echo =======================================================
pause
