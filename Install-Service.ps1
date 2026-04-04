$ErrorActionPreference = "Stop"

function Invoke-Nssm {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    & "$script:nssmPath" @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "NSSM command failed: nssm $($Arguments -join ' ')"
    }
}

# 1. Download NSSM (if not exists)
$nssmPath = Join-Path $PSScriptRoot "nssm.exe"
if (-not (Test-Path $nssmPath)) {
    Write-Host "Downloading NSSM..."
    $url = "https://nssm.cc/release/nssm-2.24.zip"
    $zipFile = Join-Path $env:TEMP "nssm.zip"
    $expectedHash = "be7b3577c6e3a280e5106a9e9db5b3775931cefc" # Official SHA1 from nssm.cc
    $extractRoot = Join-Path $env:TEMP "nssm-2.24"
    $binaryFolder = if ([Environment]::Is64BitOperatingSystem) { "win64" } else { "win32" }
    $sourceBinary = Join-Path $extractRoot "$binaryFolder\nssm.exe"

    Invoke-WebRequest -Uri $url -OutFile $zipFile

    $actualHash = (Get-FileHash -Path $zipFile -Algorithm SHA1).Hash
    if ($actualHash -ne $expectedHash) {
        throw "CRITICAL: NSSM zip file hash check failed. Possible tampering."
    }

    Expand-Archive -Path $zipFile -DestinationPath $env:TEMP -Force
    if (-not (Test-Path $sourceBinary)) {
        throw "NSSM binary not found at expected path: $sourceBinary"
    }
    Move-Item -Path $sourceBinary -Destination $nssmPath -Force
}

# 2. Install/Update AutoICS Service
$scriptPath = Join-Path $PSScriptRoot "AutoICS.ps1"
$psPath = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
$serviceArgs = "-ExecutionPolicy Bypass -File `"$scriptPath`""
$serviceName = "AutoICS"

$existingService = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
if ($existingService) {
    Write-Host "Service '$serviceName' already exists. Updating configuration..."
} else {
    Write-Host "Installing '$serviceName' service..."
    Invoke-Nssm -Arguments @("install", $serviceName, $psPath, $serviceArgs)
}

Invoke-Nssm -Arguments @("set", $serviceName, "AppDirectory", $PSScriptRoot)
Invoke-Nssm -Arguments @("set", $serviceName, "AppStdout", (Join-Path $PSScriptRoot "service.log"))
Invoke-Nssm -Arguments @("set", $serviceName, "AppStderr", (Join-Path $PSScriptRoot "service-error.log"))
Invoke-Nssm -Arguments @("set", $serviceName, "Start", "SERVICE_DELAYED_AUTO_START")

Write-Host "Starting '$serviceName' service..."
$service = Get-Service -Name $serviceName -ErrorAction Stop
if ($service.Status -eq "Running") {
    Restart-Service -Name $serviceName -Force
} else {
    Start-Service -Name $serviceName
}

Write-Host "Done."
