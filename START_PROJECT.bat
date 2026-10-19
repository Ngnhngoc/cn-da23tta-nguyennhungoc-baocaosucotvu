@echo off
chcp 65001 > nul
title TVU Facility Incident Management System - Khoi Dong He Thong

echo =========================================================================
echo    HE THONG BAO CAO & THEO DOI SU CO CO SO VAT CHAT - DAI HOC TRA VINH
echo =========================================================================
echo.

:: 1. Kiem tra va khoi dong MySQL Laragon
echo [1/3] Kiem tra ket noi MySQL Database...
netstat -ano | findstr :3306 > nul
if %errorlevel% neq 0 (
    echo [!] MySQL chua chay. Dang khoi dong MySQL tu Laragon...
    if exist "C:\laragon\bin\mysql\mysql-8.0.30-winx64\bin\mysqld.exe" (
        start "" /B "C:\laragon\bin\mysql\mysql-8.0.30-winx64\bin\mysqld.exe" --defaults-file="C:\laragon\bin\mysql\mysql-8.0.30-winx64\my.ini" --console
        timeout /t 3 > nul
        echo [*] Da khoi dong MySQL thanh cong.
    ) else (
        echo [X] Khong tim thay mysqld.exe trong C:\laragon. Vui long bat Laragon thu cong!
    )
) else (
    echo [*] MySQL da san sang tren cong 3306.
)
echo.

:: 2. Lay dia chi IP mang Wi-Fi de hien thi cho dien thoai
echo [2/3] Xac dinh dia chi IP Wi-Fi de ket noi dien thoai...
for /f "tokens=4" %%a in ('route print ^| findstr 0.0.0.0 ^| findstr /v "0.0.0.0.*0.0.0.0"') do (
    set LOCAL_IP=%%a
)
echo [*] Dia chi IP Wi-Fi may tinh cua ban: %LOCAL_IP%
echo.

:: 3. Khoi dong Backend ASP.NET Core (.NET 9)
echo [3/3] Dang khoi dong Backend ASP.NET Core & Flutter Web App tren cong 5209...
echo.
echo =========================================================================
echo    HE THONG DA SAN SANG! TRUY CAP CAC DUONG DAN SAU:
echo.
echo    1. Ung dung tren May Tinh (Edge/Chrome):
echo       http://localhost:5209/app/
echo.
echo    2. Ung dung tren Dien Thoai di dong (Chung Wi-Fi):
echo       http://%LOCAL_IP%:5209/app/
echo.
echo    3. Trang In & Quet Thu Tem Ma QR TVU:
echo       http://localhost:5209/qr_stickers.html
echo.
echo    4. Tai lieu Swagger API:
echo       http://localhost:5209/
echo =========================================================================
echo.
echo Dang mo ung dung tren trinh duyet...
start "" "http://localhost:5209/app/"
echo.
echo (Nhan Ctrl + C de dung he thong khi ket thuc lam viec)
echo.

cd /d "%~dp0backend"
dotnet run
pause
