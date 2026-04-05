# Release Notes - AutoICS

## [v0.0.11] - 2026-04-05 🚀 The "Perfect Bridge" Update

This massive update elevates **AutoICS** to a production-grade utility by adding hardware-based persistence, auto-elevation for all tools, and a comprehensive cleanup system. It is now the most reliable way to share USB-tethered internet on Windows.

### 🚀 New Features
- **Hardware-Based Auto-Detection**: The service now identifies your phone by its **hardware signature** (Remote NDIS/RNDIS). It automatically finds and re-standardizes the connection even if Windows renames it (e.g., `Ethernet 5` -> `Ethernet 6`) after a reboot.
- **Auto-Elevation (UAC) & wt.exe Support**: All `.bat` utilities now automatically request Administrator privileges and prefer launching in **Windows Terminal** for a modern, high-performance experience.
- **Full Cleanup Uninstaller**: `Uninstall-Service.ps1` is now a total system reset. It removes the service, deletes `nssm.exe`, purges log files, and **disables all ICS sharing** to return your PC to its exact original state.
- **Manual Reset Tool (`Toggle-ICS.bat`)**: A new one-click utility to manually cycle the sharing bridge without interrupting the background listener.

### ⚡ Improvements & Optimization
- **Self-Healing Loop**: Optimized the main loop to re-detect hardware every 30 seconds, making the system 100% resilient to phone re-plugs.
- **Race Condition Protection**: I implemented a lock-aware file deletion strategy for log purging and binary removal, ensuring smooth uninstalls even on older hard drives.
- **Universal Launcher**: Setup scripts now work seamlessly via double-click, eliminating the need for manual "Run as Admin" right-clicks.

### 📚 Documentation Overhaul
- **Revised Architecture**: `CODE_DOCUMENTATION.md` now covers the persistent object identification and elevation-rereader patterns.
- **UX Refresh**: `README.md` instructions have been halved in size due to the new automated workflows.

### 🏗️ Infrastructure & Maintenance
- **Refined Polling Logic**: Minimal CPU/RAM impact (~30MB) while maintaining state-standardization consistency across reboots.

---

## [v0.0.6] - 2026-04-04 🚀 Initial Public Release

Welcome to the first public release of **AutoICS**! This version transforms any legacy Windows PC into an automated, self-healing network bridge, sharing mobile internet (USB Tethering) to your external home router.

### 🚀 New Features
- **Automated ICS Engine**: Automatically toggles Windows Internet Connection Sharing (ICS) from a "USB-Tether" source to a "LAN" target.
- **Self-Healing Monitor**: A background service that checks connection health every 30 seconds, ensuring internet is restored immediately if a phone is reconnected.
- **One-Click Installation**: The `Setup-Pipeline.bat` script handles adapter renaming, binary verification, and service installation in one go.

### ⚡ Improvements & Optimization
- **Legacy PC Optimized**: Engineered to run on systems with as little as 2GB RAM and dual-core CPUs, consuming **<30MB RAM**.
- **Service Integration**: Built-in support for **NSSM** (Non-Sucking Service Manager) to run logic as a robust Windows Service.
- **Adapter Standardization**: Automated renaming of network interfaces to ensure the script finds the correct hardware every time.

### 📚 Documentation Suite
- **Code Walkthrough**: Full breakdown of the state-driven logic and COM object interactions.
- **Design Philosophy**: Deep dive into why we used native Windows APIs over complex third-party drivers.
- **Security Audit**: OWASP-aligned security review, including binary integrity checks and Admin privilege verification.
- **Contributing Guide**: Clear instructions for the community to help optimize the pipeline.

### 🏗️ Infrastructure & Maintenance
- **Binary Integrity**: Implemented SHA1 hash verification for the NSSM download to prevent tampering.
- **Logging System**: Minimalist logging (`auto-ics.log`) to prevent disk bloat on older mechanical drives.
- **Git Ready**: Pre-configured `.gitignore` to keep your repository clean of logs and temporary artifacts.

---
