# =========================
# AutoICS - Self Healing ICS Service Script
# Automatically detects Remote NDIS / USB-Tether adapter by hardware
# description and renames it, so ICS survives reboots even when Windows
# assigns a new network name (Ethernet 5, Ethernet 6, ...).
# =========================

# ---- CONFIG ----
$sourceName    = "USB-Tether"   # Desired name for the internet-source adapter
$targetName    = "LAN"          # Desired name for the LAN/router adapter
$refreshSeconds = 30            # How often to check (seconds)

# Hardware description substrings that identify a USB-tether adapter.
# Add more patterns here if you use a different phone/OS.
$tetherDescPatterns = @(
    "Remote NDIS",
    "RNDIS",
    "Android",
    "USB Ethernet",
    "USB-Tether"
)

$logFile    = Join-Path $PSScriptRoot "auto-ics.log"
$lastStatus = "none"  # Minimises repetitive log entries

# ---- HELPERS ----

function Log($msg) {
    $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $logFile -Value "$time - $msg" -Encoding UTF8
}

function Is-TetherAdapter($adapter) {
    foreach ($pattern in $tetherDescPatterns) {
        if ($adapter.InterfaceDescription -match [regex]::Escape($pattern)) {
            return $true
        }
    }
    return $false
}

function Ensure-AdapterName {
    <#
    .SYNOPSIS
        Finds the USB-tether adapter by hardware description and renames it to
        $sourceName if it currently has a different name (e.g. "Ethernet 5").
        Returns the adapter object (with the correct name) or $null.
    #>
    # First: does the correctly-named adapter already exist?
    $existing = Get-NetAdapter -Name $sourceName -ErrorAction SilentlyContinue
    if ($existing) { return $existing }

    # Second: hunt by hardware description
    $all = Get-NetAdapter -ErrorAction SilentlyContinue
    $candidate = $all | Where-Object { Is-TetherAdapter $_ } | Select-Object -First 1

    if (-not $candidate) { return $null }

    Log "Found tether adapter '$($candidate.Name)' ($($candidate.InterfaceDescription)). Renaming to '$sourceName'..."
    try {
        Rename-NetAdapter -Name $candidate.Name -NewName $sourceName -ErrorAction Stop
        Log "Renamed '$($candidate.Name)' -> '$sourceName'"
        return Get-NetAdapter -Name $sourceName -ErrorAction SilentlyContinue
    } catch {
        Log "ERROR renaming adapter: $_"
        return $null
    }
}

function Ensure-SharingRole($config, $requiredType, $adapterName, $roleLabel) {
    if (-not $config.SharingEnabled) {
        $config.EnableSharing($requiredType)
        Log "Sharing enabled on $adapterName ($roleLabel)"
        return
    }

    $currentType = $config.SharingConnectionType
    if ($currentType -ne $requiredType) {
        $config.DisableSharing()
        Start-Sleep -Milliseconds 300
        $config.EnableSharing($requiredType)
        Log "Sharing role corrected on $adapterName ($roleLabel)"
    }
}

# ---- STARTUP ----

Log "===== AutoICS Service Started (Refresh: $refreshSeconds s) ====="

# Ensure the ICS (SharedAccess) Windows service is running
Start-Service  -Name SharedAccess -ErrorAction SilentlyContinue
Set-Service    -Name SharedAccess -StartupType Automatic

# ---- MAIN LOOP ----

while ($true) {
    try {
        # Auto-detect & rename the USB-tether adapter if Windows renamed it
        $src = Ensure-AdapterName
        $dst = Get-NetAdapter -Name $targetName -ErrorAction SilentlyContinue

        if ($src -and $src.Status -eq "Up" -and $dst -and $dst.Status -eq "Up") {

            if ($lastStatus -ne "Detected") {
                Log "Adapters detected. Ensuring ICS is enabled..."
                $lastStatus = "Detected"
            }

            $netSharingManager = New-Object -ComObject HNetCfg.HNetShare
            $connections = $netSharingManager.EnumEveryConnection()

            foreach ($conn in $connections) {
                $props  = $netSharingManager.NetConnectionProps($conn)
                $config = $netSharingManager.INetSharingConfigurationForINetConnection($conn)

                # Public (internet source = phone USB tether)
                if ($props.Name -eq $sourceName) {
                    Ensure-SharingRole -config $config -requiredType 0 -adapterName $sourceName -roleLabel "Public"
                }

                # Private (LAN / router target)
                if ($props.Name -eq $targetName) {
                    Ensure-SharingRole -config $config -requiredType 1 -adapterName $targetName -roleLabel "Private"
                }
            }

        } else {
            if ($lastStatus -ne "Waiting") {
                $srcStatus = if ($src)  { $src.Status }  else { "not found" }
                $dstStatus = if ($dst)  { $dst.Status }  else { "not found" }
                Log "Waiting for adapters... ($sourceName=$srcStatus / $targetName=$dstStatus)"
                $lastStatus = "Waiting"
            }
        }

    } catch {
        Log "ERROR: $_"
    }

    Start-Sleep -Seconds $refreshSeconds
}
