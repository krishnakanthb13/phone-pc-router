@echo off
:: =========================
:: Toggle-ICS - Manually Reset Internet Connection Sharing (ICS)
:: =========================

set "SOURCE_NAME=USB-Tether"
set "TARGET_NAME=LAN"

:: ---- ADMIN CHECK & AUTO-ELEVATION ----
net session >nul 2>&1
if %errorLevel% neq 0 (
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
        "$use_wt = (Get-Command wt -ErrorAction SilentlyContinue); " ^
        "if ($use_wt) { Start-Process wt -ArgumentList \"cmd /c `\"`\"%~f0`\"`\"\" -Verb RunAs } " ^
        "else { Start-Process cmd -ArgumentList \"/c `\"`\"%~f0`\"`\"\" -Verb RunAs }"
    exit /b
)

echo.
echo ========================================================
echo   Auto-Resetting ICS Sharing
echo   Source: %SOURCE_NAME%  --^>  Target: %TARGET_NAME%
echo ========================================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$source = '%SOURCE_NAME%'; $target = '%TARGET_NAME%';" ^
    "$netSharingManager = New-Object -ComObject HNetCfg.HNetShare;" ^
    "$connections = $netSharingManager.EnumEveryConnection();" ^
    "$foundSource = $null; $foundTarget = $null;" ^
    "foreach ($conn in $connections) {" ^
        "$props = $netSharingManager.NetConnectionProps($conn);" ^
        "if ($props.Name -eq $source) { $foundSource = $conn }" ^
        "if ($props.Name -eq $target) { $foundTarget = $conn }" ^
    "}" ^
    "if (-not $foundSource) { Write-Host '[!] Error: Source adapter \"' $source '\" not found.' -ForegroundColor Red; exit 1 }" ^
    "if (-not $foundTarget) { Write-Host '[!] Error: Target adapter \"' $target '\" not found.' -ForegroundColor Red; exit 1 }" ^
    "Write-Host '[*] Found both adapters. Resetting sharing...' -ForegroundColor Cyan;" ^
    "$sourceConfig = $netSharingManager.INetSharingConfigurationForINetConnection($foundSource);" ^
    "$targetConfig = $netSharingManager.INetSharingConfigurationForINetConnection($foundTarget);" ^
    "Write-Host '[-] Disabling existing sharing...';" ^
    "$sourceConfig.DisableSharing();" ^
    "$targetConfig.DisableSharing();" ^
    "Start-Sleep -Seconds 2;" ^
    "Write-Host '[+] Enabling Sharing (Public) on' $source '...';" ^
    "$sourceConfig.EnableSharing(0);" ^
    "Write-Host '[+] Enabling Sharing (Private) on' $target '...';" ^
    "$targetConfig.EnableSharing(1);" ^
    "Write-Host '[V] Done! ICS sharing has been toggled.' -ForegroundColor Green;"

if %errorLevel% neq 0 (
    echo.
    echo [!] An error occurred during the process.
) else (
    echo.
    echo [OK] Sharing successfully toggled off and back on.
)

echo.
echo Press any key to close...
pause >nul
