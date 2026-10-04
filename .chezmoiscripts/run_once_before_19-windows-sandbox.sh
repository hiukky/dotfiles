#!/bin/bash
set -euo pipefail

# Windows Sandbox (Containers-DisposableClientVM) is a Windows optional
# feature, so under WSL it is enabled on the Windows host -- a host-wide
# change, not per-distro.
if ! grep -qi microsoft /proc/version 2>/dev/null; then
  exit 0
fi

if ! command -v powershell.exe >/dev/null 2>&1; then
  exit 0
fi

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command '
$ErrorActionPreference = "Stop"

# Get-WindowsOptionalFeature needs admin; the binary the feature ships is a
# check that works without elevation, so an enabled host never prompts.
if (Test-Path "$env:WINDIR\System32\WindowsSandbox.exe") {
  Write-Host "Windows Sandbox already enabled, skipping."
  exit 0
}

# Home editions (EditionID Core*) do not ship the feature at all.
$edition = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").EditionID
if ($edition -like "Core*") {
  Write-Host "Windows Sandbox needs Pro/Enterprise/Education (this is $edition), skipping."
  exit 0
}

# Enabling a feature needs admin, so this triggers a UAC prompt -- not silent.
# -NoRestart: the reboot it needs is left to the user, never forced mid-apply.
Start-Process powershell.exe -Verb RunAs -Wait -ArgumentList @(
  "-NoProfile", "-Command",
  "Enable-WindowsOptionalFeature -Online -FeatureName Containers-DisposableClientVM -All -NoRestart"
)
Write-Host "Windows Sandbox enabled -- restart Windows before using it."
'
