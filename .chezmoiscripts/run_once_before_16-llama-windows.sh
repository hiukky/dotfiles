#!/bin/bash
set -euo pipefail

# Local inference runs natively on Windows (not inside WSL) so it can use
# the GPU directly -- under WSL this shells out to install it on the
# Windows host: llama.cpp itself (the runtime) via its official installer,
# plus llmfit (model fit scoring / benchmarking against whatever runtime
# provider is present -- llmfit does not install or manage llama.cpp).
if ! grep -qi microsoft /proc/version 2>/dev/null; then
  exit 0
fi

if ! command -v powershell.exe >/dev/null 2>&1; then
  exit 0
fi

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command '
$ErrorActionPreference = "Stop"

if (Get-Command llama -ErrorAction SilentlyContinue) {
  Write-Host "llama.cpp already installed, skipping."
} else {
  Write-Host "Installing llama.cpp..."
  # The upstream installer removes this directory unconditionally, but its
  # first-run cleanup fails when it has not been created yet.
  $llamaAppDir = Join-Path $env:LOCALAPPDATA "llama-app"
  New-Item -ItemType Directory -Path $llamaAppDir -Force | Out-Null
  Invoke-RestMethod -Uri https://llama.app/install.ps1 | Invoke-Expression
}

if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
  Write-Host "Installing scoop..."
  # The enclosing PowerShell process already runs with -ExecutionPolicy Bypass.
  # A user-level policy write can be blocked by a more specific policy.
  # When WSL itself was started elevated (Windows Terminal run as admin),
  # every Windows process it spawns is elevated too, and the installer then
  # prints "Abort." and returns without failing unless told -RunAsAdmin.
  $principal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
  $installer = Invoke-RestMethod -Uri https://get.scoop.sh
  if ($principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    & ([scriptblock]::Create($installer)) -RunAsAdmin
  } else {
    & ([scriptblock]::Create($installer))
  }
  if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "scoop did not install."
    exit 1
  }
}

if (Get-Command llmfit -ErrorAction SilentlyContinue) {
  Write-Host "llmfit already installed, skipping."
} else {
  Write-Host "Installing llmfit..."
  scoop install llmfit
  if (-not (Get-Command llmfit -ErrorAction SilentlyContinue)) {
    Write-Host "llmfit did not install."
    exit 1
  }
}
'
