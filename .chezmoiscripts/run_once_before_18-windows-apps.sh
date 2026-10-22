#!/bin/bash
set -euo pipefail

# Personal desktop apps -- these live on the Windows host, not WSL. Priority
# is the Microsoft Store (sandboxed, self-updating) when the app is listed
# there, falling back to winget's community repo (official installer,
# hash-verified) otherwise.
if ! grep -qi microsoft /proc/version 2>/dev/null; then
  exit 0
fi

if ! command -v powershell.exe >/dev/null 2>&1; then
  exit 0
fi

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command '
$ErrorActionPreference = "Stop"

# winget reports failure only through its exit code, which PowerShell never
# turns into an error: on a fresh Windows every install once failed in a
# second and the script still exited 0, so chezmoi recorded it as done and
# never ran it again. Failures are collected and fail the script instead.
$failed = @()

# A fresh Windows has never refreshed the sources (or accepted the msstore
# agreement), and every lookup against them fails until it does.
winget source update --disable-interactivity
if ($LASTEXITCODE -ne 0) { winget source reset --force --disable-interactivity; winget source update --disable-interactivity }

function Install-App {
  param($Name, $MsstoreId, $WingetId)

  $id = if ($MsstoreId) { $MsstoreId } else { $WingetId }
  $source = if ($MsstoreId) { "msstore" } else { "winget" }

  winget list --id $id --source $source --exact --accept-source-agreements --disable-interactivity *> $null
  if ($LASTEXITCODE -eq 0) {
    Write-Host "$Name already installed, skipping."
    return
  }

  Write-Host "Installing $Name from $source..."
  winget install --id $id --source $source --exact --accept-package-agreements --accept-source-agreements --disable-interactivity
  # 0x8A150061 already installed, 0x8A15002B no applicable update,
  # 0x8A150109 installed but needs a restart: all leave the app in place.
  $ok = @(0, -1978335135, -1978335189, -1978334967)
  if ($ok -notcontains $LASTEXITCODE) {
    Write-Host ("{0} failed (winget exit 0x{1:X8})." -f $Name, $LASTEXITCODE)
    $script:failed += $Name
  }
}

Install-App -Name "Discord" -MsstoreId "XPDC2RH70K22MN"
Install-App -Name "Notion" -MsstoreId "XPDBVSS44R0L9H"
Install-App -Name "Steam" -WingetId "Valve.Steam"
Install-App -Name "Brave Browser" -MsstoreId "XP8C9QZMS2PC1T"
Install-App -Name "ChatGPT" -MsstoreId "9PLM9XGG6VKS"

# Dev tools
Install-App -Name "Claude" -WingetId "Anthropic.Claude"
Install-App -Name "Cursor" -WingetId "Anysphere.Cursor"
Install-App -Name "Android Studio" -WingetId "Google.AndroidStudio"
Install-App -Name "Google Chrome" -WingetId "Google.Chrome"
Install-App -Name "Git for Windows" -WingetId "Git.Git"
Install-App -Name "OpenCode Desktop" -WingetId "SST.OpenCodeDesktop"
Install-App -Name "Bun" -WingetId "Oven-sh.Bun"

# Media / communication
Install-App -Name "Spotify" -MsstoreId "9NCBCSZSJRSB"
Install-App -Name "Microsoft Teams" -MsstoreId "XP8BT8DW290MPQ"
Install-App -Name "VLC" -MsstoreId "XPDM1ZW6815MQM"
Install-App -Name "CapCut" -MsstoreId "XP9KN75RRB9NHS"
Install-App -Name "FxSound" -MsstoreId "XP8JK4TBQ03LZ4"

# Utilities
Install-App -Name "WinRAR" -WingetId "RARLab.WinRAR"
Install-App -Name "TranslucentTB" -WingetId "CharlesMilette.TranslucentTB"

# Other
Install-App -Name "Anki" -WingetId "Anki.Anki"
Install-App -Name "Binance" -WingetId "BinanceTech.Binance"
Install-App -Name "EA app" -WingetId "ElectronicArts.EADesktop"
Install-App -Name "OneDrive" -WingetId "Microsoft.OneDrive"
Install-App -Name "Outlook" -MsstoreId "9NRX63209R7B"
Install-App -Name "WinDirStat" -MsstoreId "9PH1GL95P3WF"

# WhatsApp Desktop (5319275A.WhatsAppDesktop) is on the Store but winget
# cannot resolve/search it under either source -- known winget limitation.
Write-Host "WhatsApp: no resolvable winget id -- install manually from the Microsoft Store."

# BitTorrent Web has no Winget package. Steam itself is provisioned above, but
# the signed-in account owns the library: BLOODSTRIKE, Crysis Remastered,
# Katana ZERO, EA SPORTS FC 26, FC 26 and Wallpaper Engine must be restored
# through Steam/EA after sign-in rather than installed unattended.
Write-Host "BitTorrent Web and the Steam/EA library require manual restoration after sign-in."

if ($failed.Count -gt 0) {
  Write-Host ("Not installed: " + ($failed -join ", ") + ". Re-run chezmoi apply to retry.")
  exit 1
}
'
