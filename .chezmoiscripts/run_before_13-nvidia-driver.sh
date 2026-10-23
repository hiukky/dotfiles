#!/bin/bash
set -euo pipefail

# Keeps the Windows host on NVIDIA's newest GeForce Game Ready driver, which
# also brings the NVIDIA app (the package ships it, PhysX and HD audio
# alongside the driver). Windows Update installs a bare driver only.
#
# `run_` without once/onchange: it runs on every apply, and asks NVIDIA's
# driver lookup for the newest Game Ready release each time; it downloads
# (~1 GB) and installs only when that is newer than the installed driver.
#
# The lookup IDs are NVIDIA's for the card in README.md (GeForce RTX 40
# Series = 127, RTX 4060 Ti = 1022, Windows 11 = 135, pt-BR = 1046), from
# https://www.nvidia.com/Download/API/lookupValueSearch.aspx (TypeID 2, 3, 4).
# upCRD=0 is Game Ready; 1 would be Studio. A different card is skipped
# rather than handed a driver looked up for another one.
CARD="NVIDIA GeForce RTX 4060 Ti"
LOOKUP="https://gfwsl.geforce.com/services_toolkit/services/com/nvidia/services/AjaxDriverService.php?func=DriverManualLookup&psid=127&pfid=1022&osID=135&languageCode=1046&beta=0&isWHQL=1&dltype=-1&dch=1&upCRD=0&qnf=0&sort1=0&numberOfResults=1"

if ! grep -qi microsoft /proc/version 2>/dev/null || ! command -v powershell.exe >/dev/null 2>&1; then
  exit 0
fi

# WSL exposes the Windows driver's nvidia-smi here.
NVIDIA_SMI="$(command -v nvidia-smi || echo /usr/lib/wsl/lib/nvidia-smi)"
if [ ! -x "$NVIDIA_SMI" ]; then
  echo "No NVIDIA driver visible from WSL; skipping the Game Ready driver."
  exit 0
fi

IFS=, read -r name installed < <("$NVIDIA_SMI" --query-gpu=name,driver_version --format=csv,noheader | head -1)
installed="${installed// /}"
if [ "$name" != "$CARD" ]; then
  echo "GPU is $name, not $CARD; skipping the Game Ready driver (update the lookup IDs in this script)."
  exit 0
fi

latest_json="$(curl -fsSL -A "Mozilla/5.0" "$LOOKUP")"
latest="$(jq -r '.IDS[0].downloadInfo.Version' <<<"$latest_json")"
url="$(jq -r '.IDS[0].downloadInfo.DownloadURL' <<<"$latest_json")"
case "$url" in
  https://*.download.nvidia.com/*) ;;
  *) echo "NVIDIA lookup returned an unexpected download URL: $url" >&2; exit 1 ;;
esac

if [ "$(printf '%s\n%s\n' "$latest" "$installed" | sort -V | tail -1)" = "$installed" ]; then
  echo "NVIDIA Game Ready driver $installed is current."
  exit 0
fi

echo "Updating the NVIDIA Game Ready driver $installed -> $latest..."

# The installer runs on Windows, so it is downloaded to a Windows path.
local_app_data="$(cmd.exe /c "echo %LOCALAPPDATA%" 2>/dev/null | tr -d '\r\n')"
cache="$(wslpath "$local_app_data")/nvidia-driver"
installer="$cache/$latest.exe"
mkdir -p "$cache"
if [ ! -f "$installer" ]; then
  curl -fL -A "Mozilla/5.0" -o "$installer.part" "$url"
  mv "$installer.part" "$installer"
fi

cd "$cache"
INSTALLER_WIN="$(wslpath -w "$installer")" WSLENV="${WSLENV:+$WSLENV:}INSTALLER_WIN" \
  powershell.exe -NoProfile -ExecutionPolicy Bypass -Command '
$ErrorActionPreference = "Stop"
$installer = $env:INSTALLER_WIN

# NVIDIA publishes no checksum with the lookup; the package is Authenticode
# signed, so an unsigned or tampered download is refused.
$sig = Get-AuthenticodeSignature $installer
if ($sig.Status -ne "Valid" -or $sig.SignerCertificate.Subject -notmatch "NVIDIA Corporation") {
  Write-Host ("Refusing the NVIDIA installer: signature " + $sig.Status + ", " + $sig.SignerCertificate.Subject)
  exit 1
}

# The self-extractor hands -s/-noreboot to setup.exe: silent, every default
# component (NVIDIA app included), and the restart left to the user. RunAs
# prompts only when the session is not already elevated.
$p = Start-Process $installer -ArgumentList "-s", "-noreboot" -Verb RunAs -Wait -PassThru
Write-Host ("NVIDIA installer exited with " + $p.ExitCode + ".")
'
cd - >/dev/null

now="$("$NVIDIA_SMI" --query-gpu=driver_version --format=csv,noheader | head -1 | tr -d ' ')"
if [ "$now" != "$latest" ]; then
  echo "The NVIDIA driver is still $now after installing $latest; the installer log is under C:\\ProgramData\\NVIDIA Corporation\\Installer2." >&2
  exit 1
fi
rm -f "$installer"
echo "NVIDIA Game Ready driver $latest installed; restart Windows to finish."
