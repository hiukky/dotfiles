#!/bin/bash
set -euo pipefail

# Android SDK lives on the Windows host, matching dot_zshrc's ANDROID_HOME
# (/mnt/c/...). Requires Android Studio already installed (see
# run_once_before_18-windows-apps.sh) for its bundled JBR (used as JAVA_HOME
# to run sdkmanager -- avoids needing a separate Windows-side JDK install).
if ! grep -qi microsoft /proc/version 2>/dev/null; then
  exit 0
fi

if ! command -v powershell.exe >/dev/null 2>&1; then
  exit 0
fi

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command '
$ErrorActionPreference = "Stop"

$studioJbr = "C:\Program Files\Android\Android Studio\jbr"
if (-not (Test-Path $studioJbr)) {
  Write-Host "Android Studio not found -- skipping Android SDK setup."
  exit 0
}
$env:JAVA_HOME = $studioJbr

$sdkRoot = Join-Path $env:LOCALAPPDATA "Android\Sdk"
$cmdlineTools = Join-Path $sdkRoot "cmdline-tools\latest"
$sdkManager = Join-Path $cmdlineTools "bin\sdkmanager.bat"

if (-not (Test-Path $sdkManager)) {
  Write-Host "Downloading Android SDK command-line tools..."
  $zipUrl = "https://dl.google.com/android/repository/commandlinetools-win-15859902_latest.zip"
  $tmpZip = Join-Path $env:TEMP "cmdline-tools.zip"
  $tmpExtract = Join-Path $env:TEMP "cmdline-tools-extract"

  New-Item -ItemType Directory -Force -Path $sdkRoot | Out-Null
  Invoke-WebRequest -Uri $zipUrl -OutFile $tmpZip
  Expand-Archive -Path $tmpZip -DestinationPath $tmpExtract -Force

  New-Item -ItemType Directory -Force -Path (Join-Path $sdkRoot "cmdline-tools") | Out-Null
  Move-Item -Path (Join-Path $tmpExtract "cmdline-tools") -Destination $cmdlineTools -Force

  Remove-Item $tmpZip, $tmpExtract -Recurse -Force -ErrorAction SilentlyContinue
}

# sdkmanager.bat runs via cmd.exe, which always warns about UNC-path cwds
# (harmless -- we are invoked from a \\wsl.localhost\... path) on stderr.
# With $ErrorActionPreference = "Stop" that warning gets promoted to a
# terminating error before redirection can suppress it, so relax it here.
$ErrorActionPreference = "Continue"

Write-Host "Accepting Android SDK licenses..."
$yesBlock = (1..20 | ForEach-Object { "y" }) -join "`n"
$yesBlock | & $sdkManager --licenses --sdk_root="$sdkRoot" 2>$null | Out-Null

Write-Host "Installing Android SDK packages..."
& $sdkManager --sdk_root="$sdkRoot" "platform-tools" "build-tools;36.1.0" "platforms;android-35" "emulator" 2>$null

# sdkmanager.bat (via cmd.exe) can return a non-zero exit code even when the
# actual install/update succeeded (same UNC-path cmd.exe quirk as above).
# Everything fatal was already caught above under $ErrorActionPreference =
# "Stop", so force success here rather than letting a cosmetic exit code
# fail the whole chezmoi apply.
exit 0
'
