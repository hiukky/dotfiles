# Bootstraps a completely fresh Windows machine: installs WSL2 + Ubuntu (if
# not already present), then hands off to setup.sh inside WSL to install
# chezmoi and init/update this dotfiles repo.
#
# Usage (from a normal, non-elevated PowerShell):
#   irm https://hiukky.com/setup.ps1 | iex
#
# Known limitation: if this is the very first time WSL/virtualization features
# are enabled on this machine, Windows may require a restart partway through.
# There's no way to script past a mandatory OS restart -- if that happens,
# restart and run this same command again; it picks up where it left off.

$ErrorActionPreference = "Stop"

function Test-Admin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

if (-not (Test-Admin)) {
    Write-Host "Installing WSL requires administrator rights -- relaunching elevated (accept the UAC prompt)..."
    $bootstrapUrl = "https://hiukky.com/setup.ps1"
    Start-Process powershell -Verb RunAs -ArgumentList "-NoExit", "-Command", "irm $bootstrapUrl | iex"
    exit
}

$distro = "Ubuntu"

# wsl.exe -l -q writes to stderr when WSL isn't installed at all ("The
# Windows Subsystem for Linux is not installed..."). With
# $ErrorActionPreference = "Stop" that gets promoted into a terminating
# error before the 2>$null redirect can suppress it, so relax it locally
# for this one check.
$ErrorActionPreference = "Continue"
$installed = (wsl.exe -l -q 2>$null) -replace "`0", ""
$ErrorActionPreference = "Stop"

if ($installed -contains $distro) {
    Write-Host "$distro is already installed."
} else {
    Write-Host "Installing WSL2 + $distro..."
    wsl.exe --install -d $distro

    Write-Host ""
    Write-Host "If Windows just enabled virtualization features for the first time, it may"
    Write-Host "now ask you to restart. If so: restart, then run this same command again --"
    Write-Host "it will pick up right where it left off."
    Write-Host ""
}

Write-Host "Launching $distro to finish setup and bootstrap dotfiles..."
Write-Host "(On first launch, $distro will ask you to create your Linux username/password.)"
Write-Host ""

wsl.exe -d $distro -- sh -c '$(curl -fsLS https://hiukky.com/setup.sh)'
