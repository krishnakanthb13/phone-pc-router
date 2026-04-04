$ErrorActionPreference = "Stop"
$serviceName = "AutoICS"
$nssmPath = Join-Path $PSScriptRoot "nssm.exe"

function Remove-WithSc {
    Write-Host "Using built-in Service Control fallback..."
    sc.exe stop $serviceName | Out-Null
    Start-Sleep -Seconds 1
    sc.exe delete $serviceName | Out-Null
}

try {
    $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
    if (-not $service) {
        Write-Host "Service '$serviceName' is not installed."
        exit 0
    }

    if (Test-Path $nssmPath) {
        Write-Host "Stopping $serviceName service..."
        & "$nssmPath" stop $serviceName | Out-Null

        Write-Host "Removing $serviceName service..."
        & "$nssmPath" remove $serviceName confirm | Out-Null
    } else {
        Remove-WithSc
    }

    Write-Host "Done. Service has been uninstalled."
}
catch {
    Write-Warning "NSSM uninstall path failed: $($_.Exception.Message)"
    Remove-WithSc
    Write-Host "Done. Service has been uninstalled."
}
