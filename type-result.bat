@echo off
setlocal
cd /d "%~dp0"
set "INPUT_FILE=%~1"
if "%INPUT_FILE%"=="" set "INPUT_FILE=%~dp0recognition-result.txt"
if not exist "%INPUT_FILE%" (
  echo Input file not found:
  echo %INPUT_FILE%
  echo.
  echo First click Save TXT in the OCR page, then save the result here as recognition-result.txt.
  pause
  exit /b 1
)
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\type-result.ps1" -InputFile "%INPUT_FILE%" -DelayMilliseconds 400
pause
