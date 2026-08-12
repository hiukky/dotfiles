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
  Invoke-RestMethod -Uri https://llama.app/install.ps1 | Invoke-Expression
}

if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
  Write-Host "Installing scoop..."
  Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
  Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
}

scoop list llmfit *> $null
if ($LASTEXITCODE -eq 0) {
  Write-Host "llmfit already installed, skipping."
} else {
  Write-Host "Installing llmfit..."
  scoop install llmfit
}
'
