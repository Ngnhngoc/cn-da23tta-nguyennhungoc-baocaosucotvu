@echo off
chcp 65001 >nul
title KHOI PHUC CO SO DU LIEU TVU

echo =======================================================
echo          KHOI PHUC CO SO DU LIEU (MySQL)
echo =======================================================
echo.

set "BACKUP_FILE=%~dp0..\database_backup\tvu_suco_latest.sql"
set "MYSQL=C:\laragon\bin\mysql\mysql-8.0.30-winx64\bin\mysql.exe"

if not exist "%BACKUP_FILE%" (
    echo [LOI] Khong tim thay file sao luu tai: %BACKUP_FILE%
    pause
    exit /b 1
)

if not exist "%MYSQL%" (
    echo [LOI] Khong tim thay mysql.exe tai: %MYSQL%
    pause
    exit /b 1
)

echo [1/2] Dang tao CSDL tvu_suco neu chua ton tai...
"%MYSQL%" -u root -e "CREATE DATABASE IF NOT EXISTS tvu_suco CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

echo [2/2] Dang nap du lieu tu file %BACKUP_FILE% vao database...
"%MYSQL%" -u root --default-character-set=utf8mb4 tvu_suco < "%BACKUP_FILE%"

echo.
echo =======================================================
echo   DA KHOI PHUC CSDL 'tvu_suco' THANH CONG!
echo =======================================================
pause
