# =========================
# AutoICS - Self Healing ICS Service Script
# =========================

# ---- CONFIG ----
$sourceName = "USB-Tether"   # USB tether adapter (EDIT THIS)
$targetName = "LAN"          # LAN adapter (EDIT THIS)

$logFile = Join-Path $PSScriptRoot "auto-ics.log"

function Log($msg) {
    $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$time - $msg" | Out-File -Append -FilePath $logFile
}

Log "===== AutoICS Service Started ====="

# Ensure ICS service is running
Start-Service -Name SharedAccess -ErrorAction SilentlyContinue
Set-Service -Name SharedAccess -StartupType Automatic

while ($true) {
    try {
        $src = Get-NetAdapter -Name $sourceName -ErrorAction SilentlyContinue
        $dst = Get-NetAdapter -Name $targetName -ErrorAction SilentlyContinue

        if ($src -and $src.Status -eq "Up" -and $dst -and $dst.Status -eq "Up") {

            Log "Adapters detected. Ensuring ICS is configured..."

            $netSharingManager = New-Object -ComObject HNetCfg.HNetShare
            $connections = $netSharingManager.EnumEveryConnection()

            foreach ($conn in $connections) {
                $props = $netSharingManager.NetConnectionProps($conn)
                $config = $netSharingManager.INetSharingConfigurationForINetConnection($conn)

                if ($props.Name -eq $sourceName) {
                    if (-not $config.SharingEnabled) {
                        Log "Enabling PUBLIC (internet) on $sourceName"
                        $config.EnableSharing(0)
                    }
                }

                if ($props.Name -eq $targetName) {
                    if (-not $config.SharingEnabled) {
                        Log "Enabling PRIVATE (LAN) on $targetName"
                        $config.EnableSharing(1)
                    }
                }
            }

        } else {
            Log "Waiting for adapters... ($sourceName / $targetName)"
        }

    } catch {
        Log "ERROR: $_"
    }

    Start-Sleep -Seconds 10
}
