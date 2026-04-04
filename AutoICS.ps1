# =========================
# AutoICS - Self Healing ICS Service Script (Optimized for Older PCs)
# =========================

# ---- CONFIG ----
$sourceName = "USB-Tether"
$targetName = "LAN"
$refreshSeconds = 30         # CHECK EVERY 30 SECONDS

$logFile = Join-Path $PSScriptRoot "auto-ics.log"
$lastStatus = "none"         # Used to minimize logging

function Log($msg) {
    $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $logFile -Value "$time - $msg" -Encoding UTF8
}

Log "===== AutoICS Service Started (Refresh: $refreshSeconds s) ====="

# Ensure ICS service is running at start
Start-Service -Name SharedAccess -ErrorAction SilentlyContinue
Set-Service -Name SharedAccess -StartupType Automatic

while ($true) {
    try {
        $src = Get-NetAdapter -Name $sourceName -ErrorAction SilentlyContinue
        $dst = Get-NetAdapter -Name $targetName -ErrorAction SilentlyContinue

        if ($src -and $src.Status -eq "Up" -and $dst -and $dst.Status -eq "Up") {
            
            # Only log if we just transition to "Detected"
            if ($lastStatus -ne "Detected") {
                Log "Adatpers Detected. Ensuring ICS is enabled..."
                $lastStatus = "Detected"
            }

            $netSharingManager = New-Object -ComObject HNetCfg.HNetShare
            $connections = $netSharingManager.EnumEveryConnection()

            foreach ($conn in $connections) {
                $props = $netSharingManager.NetConnectionProps($conn)
                $config = $netSharingManager.INetSharingConfigurationForINetConnection($conn)

                # Set Public (Source)
                if ($props.Name -eq $sourceName -and -not $config.SharingEnabled) {
                    $config.EnableSharing(0) # 0 = public
                    Log "Sharing enabled on $sourceName (Public)"
                }

                # Set Private (Target)
                if ($props.Name -eq $targetName -and -not $config.SharingEnabled) {
                    $config.EnableSharing(1) # 1 = private
                    Log "Sharing enabled on $targetName (Private)"
                }
            }

        }
        else {
            # Only log if we just transition to "Waiting"
            if ($lastStatus -ne "Waiting") {
                Log "Waiting for adapters... ($sourceName / $targetName)"
                $lastStatus = "Waiting"
            }
        }

    }
    catch {
        Log "ERROR: $_"
    }

    Start-Sleep -Seconds $refreshSeconds
}
