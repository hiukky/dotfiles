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

function Install-App {
  param($Name, $MsstoreId, $WingetId)

  $id = if ($MsstoreId) { $MsstoreId } else { $WingetId }
  $source = if ($MsstoreId) { "msstore" } else { "winget" }

  winget list --id $id --source $source --exact *> $null
  if ($LASTEXITCODE -eq 0) {
    Write-Host "$Name already installed, skipping."
    return
  }

  Write-Host "Installing $Name from $source..."
  winget install --id $id --source $source --accept-package-agreements --accept-source-agreements
}

Install-App -Name "Discord" -MsstoreId "XPDC2RH70K22MN"
Install-App -Name "Notion" -MsstoreId "XPDBVSS44R0L9H"
Install-App -Name "Steam" -WingetId "Valve.Steam"

# Dev tools
Install-App -Name "Claude" -WingetId "Anthropic.Claude"
Install-App -Name "Cursor" -WingetId "Anysphere.Cursor"
Install-App -Name "Android Studio" -WingetId "Google.AndroidStudio"
Install-App -Name "Google Chrome" -WingetId "Google.Chrome"

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

# WhatsApp Desktop (5319275A.WhatsAppDesktop) is on the Store but winget
# cannot resolve/search it under either source -- known winget limitation.
Write-Host "WhatsApp: no resolvable winget id -- install manually from the Microsoft Store."
'
