@echo off
cd /d "%~dp0"
start "JinShan Auto OCR" powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\auto-type.ps1"
timeout /t 1 /nobreak >nul
start "" "%~dp0JinShan.html"
