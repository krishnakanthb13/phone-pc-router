@echo off
setlocal

:: Check for Administrator privileges
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if %errorlevel% neq 0 (
    echo ************************************************************
    echo ERROR: Administrative privileges are REQUIRED for this setup.
    echo Please right-click this file and select 'Run as Administrator'.
    echo ************************************************************
    pause
    exit /b
)

echo.
echo ============================================================
echo   🚀 Phone-to-PC-to-Router Automated Setup Pipeline
echo ============================================================
echo.

:: 1. Rename Adapters
echo [STEP 1/2] Renaming Network Adapters...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Rename-Adapters.ps1"
if %errorlevel% neq 0 (
    echo [!] Warning: Rename-Adapters script returned an error code.
    echo Please ensure your phone is plugged in and USB tethering is enabled!
    pause
)

echo.

:: 2. Install Service
echo [STEP 2/2] Installing AutoICS Windows Service...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Install-Service.ps1"
if %errorlevel% neq 0 (
    echo [!] Error: Failed to install the AutoICS service.
    pause
    exit /b
)

echo.
echo ============================================================
echo   🎉 SETUP COMPLETE!
echo ============================================================
echo.
echo Check 'auto-ics.log' and 'service.log' for activity.
echo Remember to set your router to Access Point (AP) mode!
echo.
pause
