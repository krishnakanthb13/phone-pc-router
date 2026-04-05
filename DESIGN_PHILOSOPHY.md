# Design Philosophy - AutoICS

## ❓ Problem Definition

Legacy hardware is often abandoned because it's too slow for modern tasks, yet these machines frequently have reliable hardware like Ethernet and USB ports. Simultaneously, many users rely on high-speed mobile data through USB tethering, but standard Windows ICS is brittle, manually-triggered, and often resets after a reboot or after disconnecting a device.

**AutoICS** aims to solve the "last-mile" internet sharing problem for users with limited dedicated home internet options by converting old PCs into reliable, self-healing network bridges.

## 🚀 Why This Solution?

1.  **Low Resource Overhead**: Instead of a full-blown router OS (like pfSense or OpenWrt), AutoICS uses native Windows COM objects and PowerShell, requiring only **~30MB of RAM** and **<1% CPU**.
2.  **Autonomous Operation**: Users should not have to log in or click anything after the initial setup. The PC should act as a headless appliance.
3.  **Self-Healing**: Windows ICS is notorious for failing when the source adapter is disconnected and reconnected. AutoICS addresses this by constantly monitoring the "Source" and "Target" statuses and re-enabling sharing whenever a "Plug-and-Play" event occurs.

## 🎨 Design Principles

*   **Simplicity Over Complexity**: If a native Windows tool exists (like `HNetCfg`), use it instead of custom drivers.
*   **Transparent Logging**: Every state change (Detection, Error, Activation) should be logged for easy troubleshooting.
*   **Zero-Maintenance**: Once installed, the system should operate without user intervention for months.
*   **Security First**: Scripts ensure admin rights and verify binaries (NSSM) before execution.

## 🧠 Adapting to Volatile Environments

One of the project's key innovations is **Persistent Object Identification**. Windows often reassigns names to network adapters (e.g., `Ethernet 4` becomes `Ethernet 5`) when devices are re-plugged or the system reboots. To address this, **AutoICS** uses hardware description patterns (like `Remote NDIS`) instead of static interface names. This ensures the bridge is truly "set and forget," as the system can re-identify and re-standardize the environment even after major system updates or hardware re-enumerations.

## 👥 Target Audience & Use Cases

*   **Rural Connectivity**: Users in areas with poor ISP infrastructure but great 5G mobile coverage.
*   **Backup Internet**: A low-cost failover system for small offices or homes.
*   **Budget Homelab**: Repurposing a decade-old laptop or desktop to serve as a gateway for a home Wi-Fi network.

## 📉 Trade-offs & Constraints

*   **Windows Dependency**: This is a Windows-only tool. It cannot be used on Linux or macOS.
*   **CGNAT Limitations**: Mobile networks often use Carrier Grade NAT, which complicates external port-forwarding.
*   **Hardware Speed**: The sharing speed is fundamentally capped by the slower of the two NICs (e.g., a 100Mbps Ethernet port on a legacy PC).

## 🛠 Real-World Workflow Fit

In a typical setup, a user has an unlimited data plan on a phone but no home fiber. They plug the phone into the PC, and the PC provides internet to a standard TP-Link or ASUS router via Ethernet. The router is set to **Access Point Mode**, providing a standard Wi-Fi experience to all devices in the house (Smart TVs, Laptops, IoT).
