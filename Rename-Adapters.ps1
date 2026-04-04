# =========================
# Renames adapters to USB-Tether and LAN
# =========================

# Ensure this script is running as Administrator!

$tetherName = "Ethernet 5"
$lanName = "Ethernet"

Write-Host "Renaming $tetherName to USB-Tether..."
Rename-NetAdapter -Name $tetherName -NewName "USB-Tether" -ErrorAction SilentlyContinue

Write-Host "Renaming $lanName to LAN..."
Rename-NetAdapter -Name $lanName -NewName "LAN" -ErrorAction SilentlyContinue

Get-NetAdapter | Select-Object Name, Status, InterfaceDescription
