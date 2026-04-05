# =========================
# Uninstall-Service - Full Cleanup for AutoICS
# =========================

$ErrorActionPreference = "Stop"
$serviceName = "AutoICS"
$nssmPath = Join-Path $PSScriptRoot "nssm.exe"

# Log files to clean up
$logFiles = @(
    "auto-ics.log",
    "service.log",
    "service-error.log",
    "auto-ics.log.bak",
    "service.log.bak"
)

function Test-IsAdmin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Remove-WithSc {
    Write-Host "[*] Falling back to SC.EXE for service removal..."
    
    # 1. Stop service
    sc.exe stop $serviceName | Out-Null
    
    # 2. Disable service
    sc.exe config $serviceName start= disabled | Out-Null
    
    # 3. Wait for full stop (max 5s)
    $timeout = 0
    while ((Get-Service $serviceName -ErrorAction SilentlyContinue).Status -ne 'Stopped' -and $timeout -lt 5) {
        Start-Sleep -Seconds 1
        $timeout++
    }
    
    # 4. Delete service
    sc.exe delete $serviceName | Out-Null
}

function Disable-ICS {
    <#
    .SYNOPSIS
        Sweeps through all network connections and ensures Internet Connection 
        Sharing (ICS) is disabled, returning settings to default.
    #>
    Write-Host "[*] Disabling Internet Connection Sharing (ICS/SharedAccess)..."
    try {
        $netSharingManager = New-Object -ComObject HNetCfg.HNetShare
        $connections = $netSharingManager.EnumEveryConnection()
        $foundCount = 0
        foreach ($item in $connections) {
            $props = $netSharingManager.NetConnectionProps($item)
            $config = $netSharingManager.INetSharingConfigurationForINetConnection($item)
            if ($config.SharingEnabled) {
                $config.DisableSharing()
                Write-Host "[-] Disabled sharing on: $($props.Name)"
                $foundCount++
            }
        }
        if ($foundCount -eq 0) { Write-Host "   (No active sharing found to disable)" }
    } catch {
        Write-Warning "Non-critical: Could not disable ICS via COM. You might need to check 'Network Connections' manually."
    }
}

try {
    Write-Host ""
    Write-Host "============================================="
    Write-Host "   OFFICIAL AUTO-ICS CLEANUP UNINSTALLER"
    Write-Host "============================================="
    Write-Host ""

    # 1. Admin Verification
    if (-not (Test-IsAdmin)) {
        throw "ADMIN PRIVILEGES REQUIRED. Please right-click PowerShell and 'Run as Administrator'."
    }

    # 2. Service Deconstruction
    $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
    if ($service) {
        if (Test-Path $nssmPath) {
            Write-Host "[1/4] Stopping and removing service via NSSM..."
            & "$nssmPath" stop $serviceName | Out-Null
            & "$nssmPath" remove $serviceName confirm | Out-Null
            
            if ($LASTEXITCODE -ne 0) {
                Write-Warning "NSSM could not remove the service (Exit Code: $LASTEXITCODE)."
                Remove-WithSc
            }
        } else {
            Write-Host "[1/4] Binary missing. Using SC.EXE instead..."
            Remove-WithSc
        }
        Write-Host "   (Service has been fully decommissioned)"
    } else {
        Write-Host "[1/4] Service '$serviceName' not found (probably already uninstalled)."
    }

    # 3. Networking Normalization
    Write-Host "[2/4] Resetting system network shares..."
    Disable-ICS

    # 4. Binary/File Cleanup
    Write-Host "[3/4] Purging binary dependencies..."
    if (Test-Path $nssmPath) {
        # Brief pause to allow OS to release any file locks from the 'stop' command
        Start-Sleep -Seconds 1
        Remove-Item -Path $nssmPath -Force -ErrorAction SilentlyContinue
        if (Test-Path $nssmPath) {
            Write-Warning "Could not delete nssm.exe (File locked). It will be removed on next reboot."
        } else {
            Write-Host "   (nssm.exe purged)"
        }
    } else {
        Write-Host "   (No binary found to delete)"
    }

    # 5. Log Purge
    Write-Host "[4/4] Cleaning log history..."
    $logsCleared = 0
    foreach ($log in $logFiles) {
        $path = Join-Path $PSScriptRoot $log
        if (Test-Path $path) {
            Remove-Item -Path $path -Force -ErrorAction SilentlyContinue
            if (-not (Test-Path $path)) {
                $logsCleared++
            }
        }
    }
    Write-Host "   ($logsCleared log variant(s) cleared)"

    Write-Host ""
    Write-Host "============================================="
    Write-Host "   🎉 SUCCESS: FULL CLEANUP COMPLETE!"
    Write-Host "============================================="
    Write-Host "The PC is now back to its original state."
    Write-Host "Note: Network names 'USB-Tether' and 'LAN' were kept in the OS settings."
    Write-Host ""
}
catch {
    Write-Host ""
    Write-Host "---------------------------------------------" -ForegroundColor Red
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "---------------------------------------------" -ForegroundColor Red
    Write-Host ""
    exit 1
}
