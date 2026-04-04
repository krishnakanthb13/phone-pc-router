# 📱 Phone-to-PC-to-Router Setup (AutoICS)

This set of scripts automates the process of sharing your phone's internet (USB tethering) to your PC and then to a router via Ethernet.

## 🧱 1. Files in this folder

*   `AutoICS.ps1`: The main self-healing script that monitors adapters and enables Internet Connection Sharing (ICS).
*   `Rename-Adapters.ps1`: A script to rename your network adapters to "USB-Tether" and "LAN" for stability.
*   `Install-Service.ps1`: A script that downloads NSSM and installs `AutoICS` as a background Windows service.

---

## 🔍 2. Step 1: Rename Adatpers (Run as Admin)

Before starting the service, you should rename your network adapters so the script can consistently find them.

1.  Open **PowerShell as Administrator**.
2.  Navigate to this folder.
3.  Run:
    ```powershell
    .\Rename-Adapters.ps1
    ```

Check that the adapters are renamed correctly using `Get-NetAdapter`.

---

## 🔒 3. Step 2: Install the Background Service

To make this fully automatic (even after a reboot):

1.  Open **PowerShell as Administrator**.
2.  Run:
    ```powershell
    .\Install-Service.ps1
    ```

This will download **NSSM** (Non-Sucking Service Manager) and register `AutoICS` as a Windows service that starts automatically (delayed start).

---

## 📱 4. Phone Setup (Critical)

On your Poco F3 GT:

*   **USB Tethering**: Must be enabled every time you plug in (some phones can auto-resume).
*   **Developer Options**: Recommended for advanced control.

---

## 🌐 5. Router Setup (VERY IMPORTANT)

Your chain looks like this:
`Phone → USB → PC → Ethernet → Router`

### Configure your Router to:
*   ✔ **Access Point (AP) mode** 
*   **OR** Disable **DHCP**.

Otherwise, you'll have a **Double NAT** problem (two routers trying to assign IPs), which causes internet breakage.

---

## 🔁 6. What Happens Now?

1.  **On Boot**: Windows starts → `AutoICS` service starts.
2.  **Wait**: The script loops every 10s waiting for the "USB-Tether" adapter to appear.
3.  **Plug in Phone**: As soon as you enable USB tethering, the script detects it.
4.  **Auto-Config**: It enables ICS on the USB adapter and points it to the "LAN" adapter.
5.  **Internet**: Your router (and everything connected to it) gets internet!

---

## 🛑 8. Uninstalling (Optional)

If you need to remove the background service:
1. Open PowerShell as **Administrator**.
2. Run:
   ```powershell
   .\Uninstall-Service.ps1
   ```

## 📜 9. Logs (Debugging)
Check these files in this folder for real-time status:
*   `auto-ics.log`: Script-specific logs (adapter detection, ICS status).
*   `service.log`: Standard output from the Windows service.
*   `service-error.log`: Any technical errors from the service.
