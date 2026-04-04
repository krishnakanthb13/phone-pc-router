# 🛑 Uninstall AutoICS Service
# -------------------------
$nssmPath = Join-Path $PSScriptRoot "nssm.exe"

if (-not (Test-Path $nssmPath)) {
    Write-Error "nssm.exe not found. Cannot proceed with automatic uninstall."
    exit
}

Write-Host "Stopping AutoICS service..."
& "$nssmPath" stop AutoICS

Write-Host "Removing AutoICS service..."
& "$nssmPath" remove AutoICS confirm

Write-Host "✅ Done! Service has been uninstalled."
