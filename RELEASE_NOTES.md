# Release Notes - AutoICS

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
