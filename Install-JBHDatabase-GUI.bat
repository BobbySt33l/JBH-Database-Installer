@echo off
REM JBH Database Installer - GUI Launcher
REM This batch file launches the PowerShell GUI installer script

echo ========================================
echo   JBH Database Installer for Autodesk
echo         GUI Version
echo ========================================
echo.

REM Check if PowerShell is available
where powershell >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: PowerShell is not installed or not in PATH
    echo Please install PowerShell to run this installer
    pause
    exit /b 1
)

REM Get the directory where this batch file is located
set "SCRIPT_DIR=%~dp0"

REM Launch PowerShell GUI script
echo Starting GUI installer...
echo.

powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File "%SCRIPT_DIR%Install-JBHDatabase-GUI.ps1" %*

if %errorlevel% neq 0 (
    echo.
    echo Installation encountered an error (Exit code: %errorlevel%)
    pause
    exit /b %errorlevel%
)

exit /b 0
