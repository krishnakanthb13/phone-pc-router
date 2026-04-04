Here’s a **clean, final, production-ready setup** to make your pipeline fully automatic:

> **Poco F3 GT → USB → Windows (Service) → Ethernet → Router**

No clicks. No manual recovery. Self-healing.

---

# 🧱 1. Final Script (AutoICS)

Create:

```text
C:\Scripts\AutoICS.ps1
```

Paste this **full version**:

```powershell
# =========================
# AutoICS - Self Healing ICS Service Script
# =========================

# ---- CONFIG ----
$sourceName = "Ethernet 2"   # USB tether adapter (EDIT THIS)
$targetName = "Ethernet"     # LAN adapter (EDIT THIS)

$logFile = "C:\Scripts\auto-ics.log"

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
```

---

# 🔍 2. Find Correct Adapter Names (IMPORTANT)

Run:

```powershell
Get-NetAdapter
```

Identify:

* USB tether (your phone) → e.g. `Ethernet 2`
* LAN port → `Ethernet`

👉 Update these in script:

```powershell
$sourceName = "Ethernet 2"
$targetName = "Ethernet"
```

---

# 🔒 3. Fix Adapter Names (prevents breakage)

(Optional but recommended)

```powershell
Rename-NetAdapter -Name "Ethernet 2" -NewName "USB-Tether"
Rename-NetAdapter -Name "Ethernet" -NewName "LAN"
```

Then update script:

```powershell
$sourceName = "USB-Tether"
$targetName = "LAN"
```

---

# ⚙️ 4. Install as Windows Service (NSSM)

Use **NSSM**

---

## Step 4.1 — Install service

Run (Admin CMD):

```bash
nssm install AutoICS
```

Fill:

* **Path:**
  `C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe`

* **Arguments:**

```bash
-ExecutionPolicy Bypass -File C:\Scripts\AutoICS.ps1
```

* **Startup directory:**
  `C:\Scripts`

---

## Step 4.2 — Configure

Inside NSSM:

* Startup type → **Automatic (Delayed Start)**
* I/O tab:

  * Output log → `C:\Scripts\service.log`
  * Error log → `C:\Scripts\service-error.log`
* Shutdown → **Graceful**

---

## Step 4.3 — Start

```bash
nssm start AutoICS
```

---

# 📱 5. Phone Setup (Critical)

On your Poco:

### Enable:

* USB tethering
* Developer options (optional but useful)

### Behavior:

* Usually auto-resumes tether when plugged in

If not → fallback:

```bash
adb shell svc usb setFunctions rndis
```

---

# 🌐 6. Router Setup (VERY IMPORTANT)

Your chain:

```text
Phone → PC → Router
```

### Set router to:

✔ **Access Point (AP) mode**
OR
✔ Disable DHCP

Otherwise you’ll get:

* Double NAT
* Broken routing

---

# 🔁 7. What Happens Now

### On boot:

1. Windows starts
2. Service starts
3. ICS service starts
4. Script loops
5. Waits for phone
6. Phone connects
7. ICS auto-configures
8. Internet flows

---

# 📜 8. Logs (for debugging)

Check:

```text
C:\Scripts\auto-ics.log
```

You’ll see:

* Adapter detection
* ICS enable events
* Errors (if any)

---

# ✅ Final Result

✔ Plug phone → works
✔ Reboot → works
✔ Disconnect/reconnect → recovers
✔ No UI needed
✔ Fully autonomous

---

# 🚀 If you want next upgrades

I can help you add:

* 🔄 **Auto failover (Fiber ↔ Mobile)**
* 📊 **Bandwidth logging dashboard (your port 3004 idea)**
* ⚡ **Native C# service (no PowerShell, ultra stable)**

Just say 👍
