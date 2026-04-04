$ErrorActionPreference = "Stop"
$serviceName = "AutoICS"
$nssmPath = Join-Path $PSScriptRoot "nssm.exe"

function Test-IsAdmin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Remove-WithSc {
    Write-Host "Using built-in Service Control fallback..."
    
    # Try stopping it first (non-blocking)
    sc.exe stop $serviceName | Out-Null
    
    # Wait for service to stop (up to 5 seconds)
    $timeout = 0
    while ((Get-Service $serviceName -ErrorAction SilentlyContinue).Status -ne 'Stopped' -and $timeout -lt 5) {
        Start-Sleep -Seconds 1
        $timeout++
    }
    
    sc.exe delete $serviceName | Out-Null
}

try {
    # 1. Admin check (required for sc.exe and nssm)
    if (-not (Test-IsAdmin)) {
        throw "Administrator privileges are required to uninstall the service. Please run PowerShell as Admin."
    }

    # 2. Check if service exists before starting removal
    $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
    if (-not $service) {
        Write-Host "Service '$serviceName' is not installed."
        exit 0
    }

    # 3. Attempt removal via NSSM (preferred)
    if (Test-Path $nssmPath) {
        Write-Host "Stopping $serviceName service..."
        & "$nssmPath" stop $serviceName | Out-Null

        Write-Host "Removing $serviceName service..."
        & "$nssmPath" remove $serviceName confirm | Out-Null

        # If NSSM fails (e.g. exit code non-zero), fallback to sc.exe
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "NSSM removal failed with exit code $LASTEXITCODE. Falling back..."
            Remove-WithSc
        }
    } else {
        Remove-WithSc
    }

    Write-Host "Done. Service '$serviceName' has been uninstalled successfully."
}
catch {
    Write-Error "CRITICAL: Uninstall failed: $($_.Exception.Message)"
    exit 1
}
