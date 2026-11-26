@echo off
chcp 65001 >nul
title SAO LUU CO SO DU LIEU TVU

echo =======================================================
echo          DANG SAO LUU CO SO DU LIEU (MySQL)
echo =======================================================
echo.

set "BACKUP_DIR=%~dp0..\database_backup"
if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"

for /f "usebackq tokens=*" %%i in (`powershell -NoProfile -Command "Get-Date -Format 'yyyyMMdd_HHmmss'"`) do set "TIMESTAMP=%%i"
set "MYSQLDUMP=C:\laragon\bin\mysql\mysql-8.0.30-winx64\bin\mysqldump.exe"

if not exist "%MYSQLDUMP%" (
    echo [LOI] Khong tim thay mysqldump.exe tai: %MYSQLDUMP%
    pause
    exit /b 1
)

echo [1/2] Dang xuat toan bo CSDL 'tvu_suco' ra file...
"%MYSQLDUMP%" -u root --default-character-set=utf8mb4 tvu_suco > "%BACKUP_DIR%\tvu_suco_backup_%TIMESTAMP%.sql"
copy /Y "%BACKUP_DIR%\tvu_suco_backup_%TIMESTAMP%.sql" "%BACKUP_DIR%\tvu_suco_latest.sql" >nul

echo [2/2] Da sao luu thanh cong!
echo   - Ban moi nhat: %BACKUP_DIR%\tvu_suco_latest.sql
pause
