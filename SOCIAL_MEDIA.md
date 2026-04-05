# Social Media Announcements - AutoICS

### [v0.0.11] - 2026-04-05 🚀 The "Perfect Bridge" Update

### 🌐 LinkedIn Post (Professional & Tech-Focused)
(Rule: Plain Text Only, No Markdown)

🚀 BIG NEWS: AutoICS v0.0.11 is here! "The Perfect Bridge" Update.

I've taken the "Phone-PC-Router" automated bridge to its production-ready state. This update addresses the most requested stability features for persistent networking.

What's New:
✅ Hardware Auto-Detection: The system now identifies your phone by its device signature. It self-heals even if Windows reboots and renames your connections (v0.0.11 is immune to the "Ethernet 5" -> "Ethernet 6" bug!).
✅ Auto-Elevation (UAC): No more right-clicking! All utilities now automatically request Admin rights and support Windows Terminal (wt.exe) out of the box. 
✅ Nuclear Cleanup: Added a Full-Cleanup Uninstaller that resets all networking settings, purges binaries, and clears logs—leaving your PC exactly as it was found.

We're still keeping the runtime footprint under 30MB of RAM, making this the leanest, most reliable way to turn an old PC into a 5G home gateway.

Check out the full changelog and source: github.com/krishnakanthb13/phone-pc-router

#Networking #OpenSource #WindowsTerminal #Automation #PowerShell #SelfHealing #AutoICS #TechUpdate

---

### 📝 Reddit Post (Conversational & Deep-Dive)
(Rule: Rich Markdown Supported, Target ~2,500 Characters)

**Subreddits**: r/selfhosted, r/programming, r/sysadmin, r/windows

**Title**: [Release] AutoICS v0.0.11 - A professional, self-healing USB-to-Router bridge with hardware-level persistence and auto-elevation

**Post Content**:
Hey everyone!

Following the great feedback from the initial release, I've just pushed **v0.0.11** of **AutoICS**, and it's a huge update.

**The Vision**: A professional "set and forget" bridge that converts a legacy Windows PC into a 5G gateway. 

**What's New in "The Perfect Bridge" (v0.0.11)**:

1. **Hardware-Level Persistence**: Instead of relying on static Windows names, the service now scans for **Hardware Descriptions** (RNDIS/Remote NDIS). If you reboot and Windows renames your phone's connection (the classic "Ethernet 5" becomes "Ethernet 6" issue), AutoICS will automatically find it, rename it, and re-establish the bridge. Total hands-free reliability.
2. **Auto-Elevation & UX**: I've implemented a PowerShell relauncher block in all `.bat` files. You can now just double-click them. They will request UAC elevation and automatically launch in **Windows Terminal** (if installed), giving you a much better UI experience.
3. **Deep Cleanup Uninstaller**: I realized users want a way to fully revert. The updated `Uninstall-Service.ps1` now performs a nuclear cleanup—it wipes the service, deletes `nssm.exe`, purges log history, and **actively disables all ICS sharing settings** to return your PC to its baseline state.
4. **Manual Reset Tool (`Toggle-ICS.bat`)**: A standalone utility to kick the ICS COM objects manually if you ever feel the bridge needs a hard reset without restarting the background service.

**The Tech**:
Still using native Windows Shell COM objects (`HNetCfg.HNetShare`) and PowerShell. It’s incredibly lean: **<30MB RAM** and **<1% CPU**. No heavy third-party drivers or custom kernels needed.

I've updated the full documentation suite, including the Mermaid architecture diagrams and security audit.

Check it out here:
[https://github.com/krishnakanthb13/phone-pc-router]

I'd love to hear how this handles your specific hardware reboots! 🚀

---

### 🐦 X (Twitter) Post (Punchy & Feature-Packed)
(Rule: Plain Text Only, No Markdown, <280 Characters)

🚀 Release: AutoICS v0.0.11 "The Perfect Bridge"

Repurpose that old PC into a self-healing 5G gateway! 📱💻🌐

- Hardware Auto-Detection (Immune to renames)
- Auto-Elevation (Double-click ready)
- Windows Terminal support
- Full Cleanup Uninstaller
- <30MB RAM usage

Check it: github.com/krishnakanthb13/phone-pc-router

#OpenSource #Networking #SelfHealing

---ee.

github.com/krishnakanthb13/phone-pc-router

---

## [v0.0.6] - 2026-04-04 🚀 Initial Public Release

### 🌐 LinkedIn Post (Professional & Value-Driven)
(Rule: Plain Text Only, No Markdown)

🚀 Just released AutoICS v0.0.6!

Ever found yourself with great mobile data but a slow or unreliable home ISP? I've spent the morning creating a solution that turns any old Windows PC into an automated, self-healing network bridge.

📱 AutoICS (Phone-PC-Router) is a set of specialized scripts that shares your phone's USB tethered internet directly to an external Wi-Fi router. 

Key Highlights:
- Autonomous Monitoring: Checks for your phone every 30 seconds and restores the sharing bridge automatically. 
- Legacy PC Optimized: Runs on <30MB of RAM—perfect for that 12-year-old laptop gathering dust.
- Security First: Built-in binary verification and admin privilege checks.

Instead of a complex router OS, AutoICS uses native Windows COM objects for lean, efficient performance.

Check it out on GitHub: github.com/krishnakanthb13/phone-pc-router (Coming soon!)

#OpenSource #Networking #LegacyHardware #Windows #PowerShell #Dev #TechUpdate

---

### 📝 Reddit Post (Conversational & Tech-Focused)
(Rule: Rich Markdown Supported, Target ~2,500 Characters)

**Subreddits**: r/selfhosted, r/programming, r/sysadmin, r/windows

**Title**: I built a lightweight, self-healing bridge to share USB Tethered internet to any router (Windows-only)

**Post Content**:
Hey everyone,

I've been working on a small utility called **AutoICS** to solve a specific problem: making USB tethering to a home router as "Plug-and-Play" as possible.

**The Problem**:
Windows Internet Connection Sharing (ICS) is notoriously brittle. If you disconnect your phone, or if you reboot the host PC, the sharing bridge often breaks. It often resets to "off" or "forgets" the target LAN adapter, requiring a manual dive into the Network Connections Control Panel every single time.

**The Solution**:
AutoICS is a state-driven PowerShell monitor wrapped as a native Windows service (via NSSM). 

- **Autonomous State Management**: It polls your adapter status every 30 seconds. If it detects the "USB-Tether" adapter transition to "Up," it automatically re-enables ICS using Windows Shell COM objects (`HNetCfg.HNetShare`). 
- **Self-Healing**: It's designed to be "set and forget." Once it's running, you can plug/unplug your phone at will, and the home router (connected to the PC's Ethernet port) will regain internet within 30 seconds.
- **Extreme Legacy Optimization**: I specifically built this for 12+ year old systems. It uses ~30MB of RAM and <1% CPU. No complex third-party drivers or heavy router OS required.
- **One-Click Pipeline**: The `Setup-Pipeline.bat` script handles naming your adapters, downloading and verifying the NSSM binary (SHA1 check), and registering the service automatically.

I've just released **v0.0.6 (Initial Alpha)** and would love some feedback from the community. Does it work on your specific Android flavor? Have you found any edge cases where the COM object fails to toggle?

I've included a full Code Walkthrough, Design Philosophy, and a Security Audit in the repo to keep things transparent.

Check out the source here:
[https://github.com/krishnakanthb13/phone-pc-router]

Looking forward to hearing your thoughts and suggestions for v0.0.7! 🚀

---

### 🐦 X (Twitter) Post (Short & Punchy)
(Rule: Plain Text Only, No Markdown, <280 Characters)

🚀 Initial Release: AutoICS v0.0.6 is out!

Repurpose that old Windows PC into a self-healing internet bridge. 📱💻🌐

- Automated USB Tether -> Router (ICS)
- Windows Service (NSSM)
- Self-healing state (30s polling)
- <30MB RAM usage

Check it out: github.com/krishnakanthb13/phone-pc-router

#OpenSource #Networking #PowerShell
