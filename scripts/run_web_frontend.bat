@echo off
chcp 65001 >nul
title CHAY FLUTTER WEB FRONTEND (:8088)

cd /d "%~dp0..\tvu_mobile"
flutter run -d web-server --web-hostname=0.0.0.0 --web-port=8088 --release
