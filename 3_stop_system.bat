@echo off
chcp 65001 >nul
title 3. DUNG HE THONG TVU

echo =======================================================
echo          DANG TAT HE THONG BAO CAO SU CO TVU
echo =======================================================
echo.

echo [1/2] Dang tat cac tien trinh tren port 8000 (Backend)...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :8000') do (
    taskkill /F /PID %%a >nul 2>&1
)

echo [2/2] Dang tat cac tien trinh tren port 8088 (Web Frontend neu co)...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :8088') do (
    taskkill /F /PID %%a >nul 2>&1
)

echo.
echo =======================================================
echo   HE THONG DA DUOC TAT HOAN TOAN!
echo   (Port 8000 va 8088 da duoc giai phong)
echo =======================================================
pause
