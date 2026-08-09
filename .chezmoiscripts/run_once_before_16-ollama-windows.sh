#!/bin/bash
set -euo pipefail

# Ollama runs natively on Windows (not inside WSL) so it can use the GPU
# directly -- under WSL this shells out to install it on the Windows host.
if ! grep -qi microsoft /proc/version 2>/dev/null; then
  exit 0
fi

if ! command -v powershell.exe >/dev/null 2>&1; then
  exit 0
fi

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command '
$ErrorActionPreference = "Stop"
$installedPath = Join-Path $env:LOCALAPPDATA "Programs\Ollama\ollama.exe"

if (Test-Path $installedPath) {
  Write-Host "Ollama already installed, skipping."
  exit 0
}

$installerUrl = "https://ollama.com/download/OllamaSetup.exe"
$installerPath = Join-Path $env:TEMP "OllamaSetup.exe"

Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath
Start-Process -FilePath $installerPath -ArgumentList "/VERYSILENT", "/NORESTART" -Wait
Remove-Item $installerPath -Force -ErrorAction SilentlyContinue

Write-Host "Installed Ollama for the current user."
'
