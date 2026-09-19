@echo off
setlocal EnableExtensions
cd /d "%~dp0"
title PowerShell 3.0 Offline Installer Check

echo Checking installed PowerShell version...
set "PS_MAJOR="
for /f "tokens=1 delims=." %%A in ('powershell.exe -NoProfile -Command "$PSVersionTable.PSVersion.ToString()" 2^>nul') do set "PS_MAJOR=%%A"

if not defined PS_MAJOR (
  echo PowerShell was not found.
  set "PS_MAJOR=0"
)
echo Detected PowerShell major version: %PS_MAJOR%

if %PS_MAJOR% GEQ 3 (
  echo PowerShell 3.0 or higher is already installed. No installation is needed.
  pause
  exit /b 0
)

echo PowerShell is older than 3.0. Detecting operating system architecture...
set "ARCH=x86"
if /i "%PROCESSOR_ARCHITEW6432%"=="AMD64" set "ARCH=x64"
if /i "%PROCESSOR_ARCHITEW6432%"=="IA64" set "ARCH=x64"
if /i "%PROCESSOR_ARCHITECTURE%"=="AMD64" set "ARCH=x64"
if /i "%PROCESSOR_ARCHITECTURE%"=="IA64" set "ARCH=x64"
echo Detected architecture: %ARCH%

set "INSTALLER="
for /r "%~dp0offline-installers" %%F in (*KB3191566*%ARCH%*.msu) do if not defined INSTALLER set "INSTALLER=%%F"
for /r "%~dp0offline-installers" %%F in (*KB2506143*%ARCH%*.msu) do if not defined INSTALLER set "INSTALLER=%%F"
for /r "%~dp0" %%F in (*KB3191566*%ARCH%*.msu) do if not defined INSTALLER set "INSTALLER=%%F"
for /r "%~dp0" %%F in (*KB2506143*%ARCH%*.msu) do if not defined INSTALLER set "INSTALLER=%%F"

if not defined INSTALLER (
  echo.
  echo Matching %ARCH% MSU installer was not found.
  echo.
  echo Put the extracted WMF folder or its .msu file inside:
  echo %~dp0offline-installers
  echo The script searches all subfolders automatically.
  pause
  exit /b 1
)

echo Matching installer found:
echo %INSTALLER%
echo Starting the matching PowerShell installer...
echo Administrator permission may be required.
for %%D in ("%INSTALLER%") do set "INSTALLER_DIR=%%~dpD"
if exist "%INSTALLER_DIR%Install-WMF5.1.ps1" (
  echo Running the official WMF compatibility checker...
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%INSTALLER_DIR%Install-WMF5.1.ps1" -AcceptEULA
) else (
  start "PowerShell Installer" wusa.exe "%INSTALLER%"
)
pause
