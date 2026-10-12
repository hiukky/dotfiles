#!/bin/bash
set -euo pipefail

# 8BitDo Ultimate 2.4G Wireless Controller tooling -- lives on the Windows
# host, where the controller and its 2.4G receiver are plugged in. 8BitDo
# ships these as bare zips (no installer, no winget/Store listing), so this
# downloads each one from download.8bitdo.com into
# %LOCALAPPDATA%\Programs\8BitDo\<Tool>\, adds Start Menu shortcuts and
# drops a README.txt with the model's quirks next to them.
#
# Exactly three tools apply to this controller, and none of the others on
# 8BitDo's site do -- in particular NOT "Ultimate Software V2", which is for
# the Ultimate 2 / 2C / Pro 3 generation and silently enumerates nothing:
#   - Ultimate Software (V1): button mapping, sticks, profiles
#   - Ultimate Pair Tools:    re-pair controller <-> 2.4G receiver
#   - Firmware Updater:       controller and receiver firmware
if ! grep -qi microsoft /proc/version 2>/dev/null; then
  exit 0
fi

if ! command -v powershell.exe >/dev/null 2>&1; then
  exit 0
fi

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command '
$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$root = Join-Path $env:LOCALAPPDATA "Programs\8BitDo"
$startMenu = Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs\8BitDo"
New-Item -ItemType Directory -Force -Path $root, $startMenu | Out-Null

$tools = @(
  @{ Name = "Ultimate Software"; Exe = "8BitDo Ultimate Software.exe"
     Url = "https://download.8bitdo.com/Ultimate-Software/8BitDo-Ultimate-Software-for-Windows.zip" },
  @{ Name = "Pair Tools";        Exe = "PairTools.exe"
     Url = "https://download.8bitdo.com/Tools/PairTools/8BitDo-Ultimate-Pair-Tools.zip" },
  @{ Name = "Firmware Updater";  Exe = "8BitDo Firmware Updater.exe"
     Url = "https://download.8bitdo.com/Tools/FirmwareUpdater/8BitDo_Firmware_Updater_Win.zip" }
)

$shell = New-Object -ComObject WScript.Shell

foreach ($t in $tools) {
  $dir = Join-Path $root $t.Name
  $exe = Join-Path $dir $t.Exe

  if (Test-Path -LiteralPath $exe) {
    Write-Host "$($t.Name) already installed, skipping."
  } else {
    Write-Host "Installing $($t.Name)..."
    $tmp = Join-Path $env:TEMP ("8bitdo-" + [guid]::NewGuid().ToString("N"))
    New-Item -ItemType Directory -Force -Path $tmp | Out-Null
    $zip = Join-Path $tmp "tool.zip"
    Invoke-WebRequest -Uri $t.Url -OutFile $zip -UseBasicParsing
    # The Ultimate Software zip carries a GBK-named top folder that comes out
    # as mojibake on a non-Chinese locale, so the exe is located by name and
    # its parent folder is what gets moved into place under a clean name.
    Expand-Archive -LiteralPath $zip -DestinationPath (Join-Path $tmp "x") -Force
    $found = Get-ChildItem -LiteralPath (Join-Path $tmp "x") -Recurse -Filter $t.Exe | Select-Object -First 1
    if (-not $found) { throw "$($t.Exe) not found inside $($t.Url)" }
    if (Test-Path -LiteralPath $dir) { Remove-Item -LiteralPath $dir -Recurse -Force }
    Move-Item -LiteralPath $found.DirectoryName -Destination $dir
    Get-ChildItem -LiteralPath $dir -Recurse -File | Unblock-File
    Remove-Item -LiteralPath $tmp -Recurse -Force
  }

  $lnk = Join-Path $startMenu ("8BitDo " + $t.Name + ".lnk")
  if (-not (Test-Path -LiteralPath $lnk)) {
    $s = $shell.CreateShortcut($lnk)
    $s.TargetPath = $exe
    $s.WorkingDirectory = $dir
    $s.Save()
  }
}

$readme = Join-Path $root "README.txt"
if (-not (Test-Path -LiteralPath $readme)) {
@"
8BitDo Ultimate 2.4G Wireless Controller (the one with the charging dock,
D/X mode switch on the back; USB VID 2DC8, PID 3106 in X / 3012 in D).
Installed by dotfiles: .chezmoiscripts/run_once_before_14-8bitdo-windows.sh

Which tool does what
  Ultimate Software   configure buttons, sticks, triggers, profiles (V1 -- V2 is for other models)
  Pair Tools          re-pair the controller with its 2.4G receiver
  Firmware Updater    update controller AND receiver firmware (plug each one in separately)

Hard-won notes (2026-10-12)
  - Close Steam and every other 8BitDo tool before using any of these; they
    fight over the controller and the Pair Tool fails silently.
  - Pair Tools: plug the receiver FIRST and wait for "Receiver connected",
    then the controller on USB with the switch on D, then click Pair. If the
    controller is plugged before the receiver is read, it prints "The
    controller does not match with the current receiver" even when it does;
    the text is never cleared, but Pair still works.
  - Receiver stays "IDLE" after pairing: the controller radio may be saved in
    Bluetooth mode. Hold the profile button (oval, below Home) for 5 s;
    two vibrations = back to 2.4G, one = Bluetooth. Bluetooth pairing itself
    is Star held for 3 s with the switch on D.
  - Minus + LB held for 5 s toggles Switch mode (vibrates). In Switch mode the
    receiver stays D-input regardless of the switch.
  - The Ultimate Software forces the controller into D mode every 300 ms
    while open; the receiver only shows X-input once it is closed.
  - Turn off: hold Home 3 s (8 s to force). The mode switch is read when the
    controller powers on, not while it is linked.
  - Receiver firmware 1.10 (2025-07) "enhanced the stability in 2.4G
    connection"; the Firmware Updater main screen may say up to date while
    the receiver list still offers it.
"@ | Set-Content -LiteralPath $readme -Encoding UTF8
}
'
