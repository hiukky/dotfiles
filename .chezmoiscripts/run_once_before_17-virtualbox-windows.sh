#!/bin/bash
set -euo pipefail

# VirtualBox is a Windows-native hypervisor (installs a kernel driver), so
# under WSL it must be installed on the Windows host, not inside WSL --
# WSL2 itself runs on Hyper-V, so "VirtualBox inside WSL" isn't meaningful.
if ! grep -qi microsoft /proc/version 2>/dev/null; then
  exit 0
fi

if ! command -v powershell.exe >/dev/null 2>&1; then
  exit 0
fi

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command '
$ErrorActionPreference = "Stop"

$vboxPath = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"
if ((Get-Command VBoxManage.exe -ErrorAction SilentlyContinue) -or (Test-Path $vboxPath)) {
  Write-Host "VirtualBox already installed, skipping."
  exit 0
}

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
  Write-Host "winget not found -- install VirtualBox manually from https://www.virtualbox.org/wiki/Downloads"
  exit 0
}

# Installs a kernel driver, so this triggers a UAC prompt -- not silent.
winget install --id Oracle.VirtualBox --source winget --accept-package-agreements --accept-source-agreements
'
