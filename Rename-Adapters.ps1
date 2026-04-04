# =========================
# Renames adapters to USB-Tether and LAN (interactive by default)
# =========================

[CmdletBinding()]
param(
    [string]$DefaultTetherName = "Ethernet 5",
    [string]$DefaultLanName = "Ethernet",
    [switch]$NonInteractive
)

$ErrorActionPreference = "Stop"

function Test-IsAdmin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Select-Adapter {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Prompt,
        [Parameter(Mandatory = $true)]
        [object[]]$Candidates,
        [string]$DefaultName
    )

    if ($Candidates.Count -eq 0) {
        throw "No adapters available for selection."
    }

    $defaultIndex = -1
    if ($DefaultName) {
        for ($i = 0; $i -lt $Candidates.Count; $i++) {
            if ($Candidates[$i].Name -eq $DefaultName) {
                $defaultIndex = $i
                break
            }
        }
    }

    Write-Host ""
    Write-Host $Prompt
    for ($i = 0; $i -lt $Candidates.Count; $i++) {
        $adapter = $Candidates[$i]
        $marker = ""
        if ($i -eq $defaultIndex) { $marker = " (default)" }
        Write-Host ("[{0}] {1} | {2} | {3}{4}" -f ($i + 1), $adapter.Name, $adapter.Status, $adapter.InterfaceDescription, $marker)
    }

    if ($NonInteractive) {
        if ($defaultIndex -ge 0) {
            return $Candidates[$defaultIndex]
        }
        return $Candidates[0]
    }

    while ($true) {
        $choice = Read-Host "Enter selection number (press Enter for default)"
        if ([string]::IsNullOrWhiteSpace($choice)) {
            if ($defaultIndex -ge 0) {
                return $Candidates[$defaultIndex]
            }
            Write-Host "No default found. Please choose a number."
            continue
        }

        [int]$number = 0
        if ([int]::TryParse($choice, [ref]$number) -and $number -ge 1 -and $number -le $Candidates.Count) {
            return $Candidates[$number - 1]
        }

        Write-Host "Invalid selection. Choose a number from the list."
    }
}

try {
    if (-not (Test-IsAdmin)) {
        throw "Administrator privileges are required."
    }

    $adapters = Get-NetAdapter | Sort-Object Name
    if ($adapters.Count -lt 2) {
        throw "At least 2 network adapters are required."
    }

    $tetherAdapter = Select-Adapter -Prompt "Select the USB tether adapter (internet source):" -Candidates $adapters -DefaultName $DefaultTetherName
    $lanCandidates = $adapters | Where-Object { $_.InterfaceIndex -ne $tetherAdapter.InterfaceIndex }
    $lanAdapter = Select-Adapter -Prompt "Select the LAN adapter (router target):" -Candidates $lanCandidates -DefaultName $DefaultLanName

    if ($tetherAdapter.InterfaceIndex -eq $lanAdapter.InterfaceIndex) {
        throw "Source and target adapters cannot be the same."
    }

    $existingSourceName = Get-NetAdapter -Name "USB-Tether" -ErrorAction SilentlyContinue
    if ($existingSourceName -and $existingSourceName.InterfaceIndex -ne $tetherAdapter.InterfaceIndex) {
        throw "An adapter named 'USB-Tether' already exists: '$($existingSourceName.Name)'. Rename it first."
    }

    $existingTargetName = Get-NetAdapter -Name "LAN" -ErrorAction SilentlyContinue
    if ($existingTargetName -and $existingTargetName.InterfaceIndex -ne $lanAdapter.InterfaceIndex) {
        throw "An adapter named 'LAN' already exists: '$($existingTargetName.Name)'. Rename it first."
    }

    if ($tetherAdapter.Name -ne "USB-Tether") {
        Write-Host "Renaming '$($tetherAdapter.Name)' to 'USB-Tether'..."
        Rename-NetAdapter -Name $tetherAdapter.Name -NewName "USB-Tether" -Confirm:$false
    } else {
        Write-Host "Source adapter is already named 'USB-Tether'."
    }

    if ($lanAdapter.Name -ne "LAN") {
        Write-Host "Renaming '$($lanAdapter.Name)' to 'LAN'..."
        Rename-NetAdapter -Name $lanAdapter.Name -NewName "LAN" -Confirm:$false
    } else {
        Write-Host "Target adapter is already named 'LAN'."
    }

    Write-Host ""
    Get-NetAdapter | Select-Object Name, Status, InterfaceDescription
}
catch {
    Write-Error $_
    exit 1
}
