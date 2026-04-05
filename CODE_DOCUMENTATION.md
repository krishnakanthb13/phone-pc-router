# Code Documentation - AutoICS

## 📂 File & Folder Structure

| Path | Type | Description |
| :--- | :--- | :--- |
| `AutoICS.ps1` | Script | The main monitoring and ICS management engine. |
| `Enable-Tether-ADB.bat` | Script | Utility to force-enable RNDIS via ADB command. |
| `Install-Service.ps1` | Script | Environment setup and Windows Service registration using NSSM. |
| `Rename-Adapters.ps1` | Script | Standardization utility for naming network interfaces. |
| `Setup-Pipeline.bat` | Script | Entry-point script for automated installation and configuration. |
| `Uninstall-Service.ps1` | Script | **Full Cleanup.** Removes the Windows Service, deletes `nssm.exe`, clears logs, and disables ICS. |
| `nssm.exe` | Binary | Non-Sucking Service Manager for running scripts as background services. |
| `.gitignore` | Config | Defines files to be excluded from version control. |
| `LICENSE` | Legal | GPL v3 license text. |
| `README.md` | Doc | General overview and usage instructions. |
| `SECURITY.md` | Doc | Security policies and audit logs. |

## 🏗 High-Level Architecture

The system operates as a **State-Driven Monitor**. It doesn't rely on events, which can be inconsistent on legacy hardware, but instead polls the adapter status and enforces the desired state (ICS enabled).

```mermaid
graph TD
    A[Setup-Pipeline.bat] --> B[Standardize Names]
    B --> C[Install Service]
    C --> D[AutoICS.ps1]
    
    subgraph Background Service (NSSM)
    D --> E[Auto-Detect Tether by Hardware]
    E --> F[Rename to USB-Tether?]
    F --> G{Adapters Up?}
    G -- Yes --> H[Enforce ICS via COM Objects]
    G -- No --> I[Wait 30 Seconds]
    H --> I
    I --> D
    end
```

## 🛠 Core Modules & Logic

| Component | Logic | Key API / Tools |
| :--- | :--- | :--- |
| **Adapter Naming** | Scans all network interfaces for hardware-specific descriptions like `Remote NDIS` or `RNDIS`. Renames the first match to `USB-Tether` and standardizes the LAN port as `LAN`. | `Get-NetAdapter`, `Rename-NetAdapter` |
| **ICS Management** | Uses Windows Shell COM objects to toggle sharing. Assigns `USB-Tether` as the Public (Source) role and `LAN` as the Private (Target) role. | `HNetCfg.HNetShare` (COM) |
| **Service Wrapper** | Wraps the PowerShell script as a native Windows service. | `NSSM` (Non-Sucking Service Manager) |
| **Tethering Check** | Continuously polling for the `Status` property of the `USB-Tether` adapter. | `Get-NetAdapter` |
| **Auto-Elevation** | `Toggle-ICS.bat` uses a PowerShell relauncher to request Admin rights and prefers `wt.exe` (Windows Terminal) if available. | `Start-Process -Verb RunAs` |

## 🔄 Data Flow

The data flows from the **Mobile Device** (source) through the **PC** (bridge) to the **External Router** (target).

1.  **Mobile Device**: Provides internet via USB RNDIS (USB-Tether).
2.  **PC (AutoICS)**: Detects the link, identifies it as the "Public" sharing interface, and assigns the "Private" role to the Ethernet (LAN) port.
3.  **External Router**: Receives the bridged internet connection and distributes it to the home network.

## 📦 Dependencies

### Runtime Dependencies
*   **Windows 10/11**: Tested on older hardware (Dual Core, 2GB RAM).
*   **PowerShell 5.1+**: Standard on Windows 10/11.
*   **Administrative Privileges**: Required for adapter management and service installation.

### Developer/Build Dependencies
*   **NSSM (Non-Sucking Service Manager)**: Included in the repository for convenience.

## 🚦 Execution Flow

1.  **Entry Point**: User runs `Setup-Pipeline.bat`.
2.  **Configuration**: Adapters are renamed to ensure the monitoring script can find them.
3.  **Registration**: `Install-Service.ps1` downloads NSSM (if missing/corrupt) and creates a service named `AutoICS`.
4.  **Main Loop**: `AutoICS.ps1` runs indefinitely in the background, checking every 30 seconds for specific adapter statuses.
5.  **Steady State**: Once adapters are "Up," ICS is enabled once and then verified in subsequent cycles.
