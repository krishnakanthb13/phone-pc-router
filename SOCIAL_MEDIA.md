# Social Media Announcements - AutoICS

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
