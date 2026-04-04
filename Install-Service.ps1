# 🚀 1. Download NSSM (if not exists)
# -------------------------
$nssmPath = Join-Path $PSScriptRoot "nssm.exe"
if (-not (Test-Path $nssmPath)) {
    Write-Host "Downloading NSSM..."
    $url = "https://nssm.cc/release/nssm-2.24.zip" 
    $zipFile = Join-Path $env:TEMP "nssm.zip"
    $expectedHash = "be7b3577c6e3a280e5106a9e9db5b3775931cefc" # Official SHA1 from nssm.cc

    Invoke-WebRequest -Uri $url -OutFile $zipFile

    $actualHash = (Get-FileHash -Path $zipFile -Algorithm SHA1).Hash
    if ($actualHash -ne $expectedHash) {
        Write-Error "CRITICAL: NSSM zip file hash check failed! Possible tampering."
        exit
    }
    
    Expand-Archive -Path $zipFile -DestinationPath $env:TEMP -Force
    # Copy the win64 version
    Move-Item -Path "$env:TEMP\nssm-2.24\win64\nssm.exe" -Destination $nssmPath -Force
}

# 🚀 2. Install AutoICS Service
# -------------------------
$scriptPath = Join-Path $PSScriptRoot "AutoICS.ps1"
$psPath = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
$serviceArgs = "-ExecutionPolicy Bypass -File `"$scriptPath`""

Write-Host "Installing AutoICS service..."
& "$nssmPath" install AutoICS "$psPath" "$serviceArgs"
& "$nssmPath" set AutoICS AppDirectory "$PSScriptRoot"
& "$nssmPath" set AutoICS AppStdout (Join-Path $PSScriptRoot "service.log")
& "$nssmPath" set AutoICS AppStderr (Join-Path $PSScriptRoot "service-error.log")
& "$nssmPath" set AutoICS Start SERVICE_DELAYED_AUTO_START

Write-Host "Starting AutoICS service..."
& "$nssmPath" start AutoICS

Write-Host "✅ Done!"
