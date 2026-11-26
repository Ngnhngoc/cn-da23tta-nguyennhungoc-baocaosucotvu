@echo off
chcp 65001 >nul
title 2. XUAT FILE APK (CHO LDPLAYER & ANDROID)

echo =======================================================
echo    DANG BIEN DICH FILE APK RELEASE (TVU FACILITY)
echo =======================================================
echo.

cd /d "%~dp0tvu_mobile"

echo [1/3] Dang kiem tra thu vien Flutter (flutter pub get)...
call flutter pub get
if %errorlevel% neq 0 (
    echo [LOI] Khong the tai thu vien Flutter!
    pause
    exit /b 1
)

echo.
echo [2/3] Dang build file APK Release (vui long cho 1-2 phut)...
call flutter build apk --release
if %errorlevel% neq 0 (
    echo [LOI] Build APK that bai! Kiem tra lai ma nguon hoac Android SDK.
    pause
    exit /b 1
)

echo.
echo [3/3] Dang xuat file APK ra thu muc apk_output...
if not exist "%~dp0apk_output" mkdir "%~dp0apk_output"
copy /Y "%~dp0tvu_mobile\build\app\outputs\flutter-apk\app-release.apk" "%~dp0apk_output\TVU_Facility.apk" >nul

echo.
echo =======================================================
echo   XUAT FILE APK THANH CONG!
echo.
echo   File APK cua ban nam tai:
echo   - %~dp0apk_output\TVU_Facility.apk
echo.
echo   CACH CAI DAT LEN LDPLAYER:
echo   1. Mo gia lap LDPlayer.
echo   2. Keo va tha file TVU_Facility.apk vao man hinh LDPlayer.
echo   3. Dam bao da chay file 1_start_backend.bat tren may tinh!
echo =======================================================
explorer "%~dp0apk_output"
pause
