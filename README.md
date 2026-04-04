# 📱 Phone-to-PC-to-Router Automated Pipeline (AutoICS)

A set of specialized scripts designed to turn any Windows PC (even older hardware) into an automated bridge that shares mobile internet (via USB Tethering) to an external Router.

## 🚀 The Goal
To create a "Plug and Play" experience where you simply connect your phone via USB, and the PC automatically configures **Internet Connection Sharing (ICS)** to push that data through the Ethernet port into your router—restoring internet to your entire home Wi-Fi network without manual setup.

---

## 🛠 Project Components

| File | Description |
| :--- | :--- |
| **`Setup-Pipeline.bat`** | **Start Here.** Automatically renames adapters and installs the background service. |
| **`AutoICS.ps1`** | The main logic engine. Monitors adapters and manages ICS status. |
| **`Install-Service.ps1`** | Downloads **NSSM** and registers AutoICS as a Windows Service. |
| **`Rename-Adapters.ps1`** | Standardizes your network adapter names to `USB-Tether` and `LAN`. |
| **`Enable-Tether-ADB.bat`** | Optional utility to force-enable RNDIS (USB Tethering) via ADB. |
| **`Uninstall-Service.ps1`** | Safely removes the AutoICS service and stops all background loops. |

---

## ⚙️ Initial Setup

### 1. Prerequisites
*   **Phone**: Poco F3 GT (or any Android device with USB Tethering).
*   **PC**: Windows 10/11 (Optimized for older 12+ year old systems).
*   **Router**: Configured in **Access Point (AP) Mode** (or DHCP disabled).

### 2. Installation
1.  Connect your phone to the PC via USB and enable **USB Tethering**.
2.  Right-click **`Setup-Pipeline.bat`** and select **"Run as Administrator"**.
3.  The script will automatically:
    *   Confirm Admin rights.
    *   Rename your network adapters.
    *   Download and verify the **NSSM** binary (via SHA1 hash).
    *   Install the **AutoICS** background service.

---

## 🚦 How it Works (Autonomous Mode)

Once installed, you don't need to touch your PC. The system is **Self-Healing**:
1.  **Detection**: The service checks for your phone every **30 seconds**.
2.  **Activation**: If it detects the phone is "Up," it automatically enables ICS.
3.  **Efficiency**: It uses only **~30MB of RAM** and **<1% CPU**, making it perfect for legacy hardware.
4.  **Logging**: It only writes to `auto-ics.log` when a status change occurs, preventing disk bloat.

---

## 🔒 Security & Integrity
*   **Admin Check**: All setup scripts verify administrative privileges before running.
*   **Binary Integrity**: `Install-Service.ps1` verifies the SHA1 hash of the `nssm.cc` download to prevent malicious tampering.
*   **Audit**: A full security audit was performed on 2026-04-04 (See **`SECURITY.md`**).

---

## 📦 Version Control (Git)
The project includes a specialized `.gitignore` to ensure your repository stays clean:
*   **Initial Commit**: `git add .` -> `git commit -m "Initial setup"`
*   **Excluded**: All `.log` files, `nssm.exe`, and temporary `.zip` files are automatically ignored.

---

## 🛑 Maintenance & Uninstallation
If you wish to remove the service and stop the background monitoring:
1.  Open **PowerShell as Administrator**.
2.  Run:
    ```powershell
    .\Uninstall-Service.ps1
    ```

---

## 📜 Logs 
Check these files in the root directory for real-time status:
*   `auto-ics.log`: Timeline of adapter detection and connection sharing.
*   `service.log`: Standard output log from the service manager.
*   `service-error.log`: Technical errors (if any occur).

---

## 💡 Advanced Tips & Best Practices

1.  **🚀 USB Hardware**: Your USB cable is the "backbone" of your home network. Use a high-quality, short USB 3.0 cable to ensure the highest data transfer speeds between your phone and the PC.
2.  **🔋 Phone Battery Settings**: On your Poco F3 GT, ensure that USB Tethering is not being optimized by the battery saver. Setting it as a "Developer Option" can help maintain stability during long sessions.
3.  **⚡ DNS Optimization**: To speed up website loading times, you can manually set your router's DNS to `8.8.8.8` (Google) or `1.1.1.1` (Cloudflare).
4.  **🌐 Mobile NAT (Port Forwarding)**: Most mobile data providers use CGNAT. If you need to host games or a web server, traditional port forwarding won't work. Consider using tools like **Tailscale** or **Cloudflare Tunnels** for external access.
5.  **🐢 Legacy Hardware**: This system uses ~30MB of RAM and <1% CPU, making it perfectly safe for even the oldest dual-core systems. No further optimization is needed for your 12-year-old PC.

---
