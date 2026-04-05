@echo off
setlocal

:: ---- ADMIN CHECK & AUTO-ELEVATION ----
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "if (-not([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {" ^
    "    $use_wt = (Get-Command wt -ErrorAction SilentlyContinue); " ^
    "    if ($use_wt) { Start-Process wt -ArgumentList \"cmd /c `\"`\"%~f0`\"`\"\" -Verb RunAs } " ^
    "    else { Start-Process cmd -ArgumentList \"/c `\"`\"%~f0`\"`\"\" -Verb RunAs } " ^
    "    exit 1" ^
    "}"
if %errorLevel% neq 0 ( exit /b )

echo.
echo ============================================================
echo   🚀 Phone-to-PC-to-Router Automated Setup Pipeline
echo ============================================================
echo.

:: 1. Rename Adapters
echo [STEP 1/2] Renaming Network Adapters...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Rename-Adapters.ps1"
if %errorlevel% neq 0 (
    echo [!] Error: Rename-Adapters failed.
    echo Setup cannot continue until adapter mapping is fixed.
    pause
    exit /b 1
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
