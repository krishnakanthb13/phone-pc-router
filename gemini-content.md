This document summarizes the complete configuration of your **Jio 5G Home Gateway** setup using your **Poco F3 GT**, a **12-year-old Windows PC**, and a **Fiber Router**.

---

# 🌐 Project Jio 5G Home Gateway (Poco F3 GT)

## 1. System Architecture
This setup converts your smartphone into a dedicated 5G modem, using your PC as the "brain" (gateway) and your spare fiber router as the "broadcaster" (Access Point).

**The Connection Chain:**
`Poco F3 GT` $\rightarrow$ (USB Cable) $\rightarrow$ `Windows PC` $\rightarrow$ (Ethernet Cable) $\rightarrow$ `Fiber Router (LAN 1)` $\rightarrow$ (5GHz Wi-Fi) $\rightarrow$ `Client Devices`

---

## 2. Configuration Steps

### A. Poco F3 GT (The Source)
* **Developer Options:** Enable **Tethering Hardware Acceleration** to reduce heat and improve data throughput.
* **Default USB Configuration:** Set to **USB Tethering** (found in Developer Options) to automate the connection when plugged in.
* **Physical Care:** Place the phone on a hard, cool surface near a window for the best 5G reception.

### B. Windows PC (The Gateway)
* **Internet Connection Sharing (ICS):**
    1.  Open Network Connections (`ncpa.cpl`).
    2.  Right-click **Ethernet 5 (Remote NDIS)** > Properties > Sharing.
    3.  Check "Allow other network users to connect..." and select the physical **Ethernet** adapter.
* **Persistent Sharing:** Run the following in PowerShell (Admin) to ensure sharing stays active after reboots:
    `New-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\SharedAccess" -Name "EnableRebootPersistConnection" -Value 1 -PropertyType dword`
* **Performance:** Uncheck "Allow the computer to turn off this device to save power" in the **Power Management** tab of the Network Adapter properties (Device Manager).

### C. Fiber Router (The Access Point)
* **DHCP Server:** Set to **Disabled** or **Relay** (pointing to `192.168.137.1`).
* **Wi-Fi Settings:** Disabled **2.4GHz** and enabled **5GHz only** to eliminate interference and maximize speed.
* **LAN IP:** Set to `192.168.137.2` to allow easy access to settings without changing your PC’s IP.

---

## 3. Client Device Setup (The "Manual" Part)
Since the fiber router's DHCP is disabled, every phone or laptop connecting to the Wi-Fi must be configured with a **Static IP**:

* **IP Address:** `192.168.137.x` (where x is 2–254)
* **Gateway:** `192.168.137.1` (**Your PC**)
* **DNS:** `8.8.8.8` or `1.1.1.1`

---

## 4. Automation Script (PowerShell)
You can use the following script to automatically configure ICS whenever the phone is plugged in. Replace `sourceName` with your actual adapter name (e.g., "Ethernet 5").

```powershell
# CONFIG
$sourceName = "Ethernet 5"   # USB tethering
$targetName = "Ethernet"     # LAN to router

Start-Service -Name SharedAccess -ErrorAction SilentlyContinue
Write-Host "Waiting for USB tether..."

while ($true) {
    $src = Get-NetAdapter -Name $sourceName -ErrorAction SilentlyContinue
    if ($src -and $src.Status -eq "Up") { break }
    Start-Sleep -Seconds 3
}

$netSharingManager = New-Object -ComObject HNetCfg.HNetShare
$connections = $netSharingManager.EnumEveryConnection()

foreach ($conn in $connections) {
    $props = $netSharingManager.NetConnectionProps($conn)
    if ($props.Name -eq $sourceName) {
        $config = $netSharingManager.INetSharingConfigurationForINetConnection($conn)
        if (-not $config.SharingEnabled) { $config.EnableSharing(0) }
    }
    if ($props.Name -eq $targetName) {
        $config = $netSharingManager.INetSharingConfigurationForINetConnection($conn)
        if (-not $config.SharingEnabled) { $config.EnableSharing(1) }
    }
}
Write-Host "ICS configured successfully."
```

---

## 5. Performance & Longevity Analysis
* **Phone Health:** This setup is superior to a mobile hotspot. By offloading Wi-Fi broadcasting to the router, the **Poco F3 GT** stays cooler, significantly extending battery life and preventing "bloat."
* **PC Load:** The 12-year-old PC acts as a transparent bridge. CPU/RAM impact is negligible (approx. **<1% CPU**).
* **Speed Bottlenecks:** The Poco F3 GT uses **USB 2.0**, capping the transfer speed at roughly **300 Mbps**, regardless of how fast the 5G signal is. Using **5GHz Wi-Fi** on the router ensures no further speed loss occurs between the PC and your other devices.

---

## 6. Future Upgrade Path
When budget allows, a **USB-C to Gigabit Ethernet Hub with 100W PD (Power Delivery)** is recommended. This would allow the phone to connect directly to the router's WAN port (if available on a newer router) and charge from a wall outlet simultaneously, removing the need for the PC to remain powered on.

---

**Actionable Suggestion:**
I can help you create a "Startup Task" that runs your PowerShell script automatically every time you turn on your PC so you never have to manually configure the bridge again. Would you like the steps for that?

---

Here is a complete summary of everything discussed on the page — a conversation titled **"PC as Jio 5G Router Bridge"** (created April 3, published April 4, 2026): [gemini.google](https://gemini.google.com/share/c75fcc1dbf8a)

***

## The Core Setup Goal
You wanted to share your **Poco F3 GT's Jio 5G** connection with multiple devices using a spare fiber router, without paying for a USB-C hub. [gemini.google](https://gemini.google.com/share/c75fcc1dbf8a)

***

## Two Setup Options Discussed

### Option 1: PC as Bridge (Zero-Cost)
- Phone connects to PC via **USB tethering**
- PC connects to the router via **Ethernet**
- Windows **Internet Connection Sharing (ICS)** is used to pass the internet through
- PC must stay **powered on** at all times; if it sleeps, the internet dies [gemini.google](https://gemini.google.com/share/c75fcc1dbf8a)

### Option 2: USB-C Hub (Future Upgrade)
- Connect phone → USB-C hub → Ethernet → Router's WAN port
- Cuts the PC out entirely — more stable, lower latency, always-on [gemini.google](https://gemini.google.com/share/c75fcc1dbf8a)
- Must get a **USB-C PD (Power Delivery) hub** to charge the phone while tethering
- Recommended products:
  - **Ugreen 7-in-1 Hub** (₹3,299 – 100W PD, Gigabit Ethernet, best for always-on use) [gemini.google](https://gemini.google.com/share/c75fcc1dbf8a)
  - **Anker PowerExpand 6-in-1** (₹3,404 – 65W PD, compact and reliable) [gemini.google](https://gemini.google.com/share/c75fcc1dbf8a)
  - **TP-Link USB-C to RJ45** (₹1,149 – no PD pass-through, short-term use only) [gemini.google](https://gemini.google.com/share/c75fcc1dbf8a)

***

## Troubleshooting Steps That Were Needed

| Problem | Solution |
|---|---|
| Sharing tab missing in Windows | Enable **ICS service** via `services.msc`; set to Automatic |
| `vEthernet (Default Switch)` present | Caused by **Hyper-V** (Docker/WSL2); disable it temporarily to reveal Sharing tab |
| Router has no WAN port | Use a LAN port; configure router in **Access Point mode** |
| Can't disable DHCP on fiber router | Only had a **DHCP Relay** option; enter `192.168.137.1` as relay destination |
| Bridge method gave "No Internet" | Android's USB tethering is point-to-point; bridging confuses the handshake |
| "No Internet" on connected devices | Set **Static IP** manually on each device: IP `192.168.137.50`, Gateway `192.168.137.1`, DNS `8.8.8.8` |
| Couldn't access router settings page | Set PC to static IP `192.168.1.10`, Gateway `192.168.1.1` to reach router admin |

 [gemini.google](https://gemini.google.com/share/c75fcc1dbf8a)

***

## Working Final Configuration
The **Manual Gateway + ICS method** worked successfully: [gemini.google](https://gemini.google.com/share/c75fcc1dbf8a)
- Phone USB tethers to PC → PC shares internet via Ethernet to router's LAN port
- Each device connected to the router must be set to **Static IP** with Gateway pointing to `192.168.137.1` (the PC)
- Any new device added to the Wi-Fi requires the same manual static IP setup [gemini.google](https://gemini.google.com/share/c75fcc1dbf8a)

***

## Speed Optimization Tips
Several fixes were suggested for slow speeds when two phones connected: [gemini.google](https://gemini.google.com/share/c75fcc1dbf8a)
- **Enable 5GHz Wi-Fi** on the router (2.4GHz caps at ~30–50 Mbps in crowded Chennai areas)
- **Tethering hardware acceleration**: Enable in Developer Options on the Poco
- **Windows QoS fix**: Via `gpedit.msc` → Limit reservable bandwidth → set to 0% to reclaim Windows' reserved bandwidth
- **Check Ethernet cable**: Cat5e or Cat6 required for speeds above 100 Mbps
- **USB port**: Plug into a blue USB 3.0 port on the PC for better throughput
- **Heat management**: Keep the Poco cool; thermal throttling reduces 5G speeds
- **DNS**: Use `1.1.1.1` (Cloudflare) for faster page load response times [gemini.google](https://gemini.google.com/share/c75fcc1dbf8a)

***

## Phone Longevity Tips
Since preserving the Poco F3 GT's battery life was a key goal: [gemini.google](https://gemini.google.com/share/c75fcc1dbf8a)
- USB tethering keeps the phone charging (better than hotspot which drains battery)
- Avoid excessive heat — 5G + charging = heat, which is the #1 battery killer
- Enable **Battery Protection mode** to cap charge at 80% if available
- Keep phone in a ventilated spot, ideally near a fan or window [gemini.google](https://gemini.google.com/share/c75fcc1dbf8a)

***

## Key Technical Notes
- The **MTCTE sticker** on the router is just India's mandatory telecom certification mark (like an ISI mark), not a brand name [gemini.google](https://gemini.google.com/share/c75fcc1dbf8a)
- Poco F3 GT uses **USB 2.0**, capping tethering speeds at ~250–300 Mbps regardless of 5G capability [gemini.google](https://gemini.google.com/share/c75fcc1dbf8a)
- The dongle setup in the future would reduce all this complexity to a **single toggle** ("Share via Ethernet") and about 30 seconds of setup [gemini.google](https://gemini.google.com/share/c75fcc1dbf8a)

***