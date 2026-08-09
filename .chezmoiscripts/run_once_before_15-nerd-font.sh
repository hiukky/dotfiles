#!/bin/bash
set -euo pipefail

# Nerd Font glyphs (starship, eza --icons) are rendered by the Windows Terminal
# process, so under WSL the font must be installed on the Windows host, not here.
if ! grep -qi microsoft /proc/version 2>/dev/null; then
  exit 0
fi

if ! command -v powershell.exe >/dev/null 2>&1; then
  exit 0
fi

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command '
$ErrorActionPreference = "Stop"
$fontName = "FiraCode Nerd Font"
$fontsDir = Join-Path $env:LOCALAPPDATA "Microsoft\Windows\Fonts"
$regPath  = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts"

$already = Get-ChildItem $fontsDir -Filter "FiraCodeNerdFont-*.ttf" -ErrorAction SilentlyContinue
if ($already) {
  Write-Host "FiraCode Nerd Font already installed, skipping download."
} else {
  New-Item -ItemType Directory -Force -Path $fontsDir | Out-Null

  $zipUrl = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip"
  $tmpDir = Join-Path $env:TEMP "firacode-nerd-font"
  $zipPath = Join-Path $env:TEMP "FiraCode.zip"

  Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath
  Expand-Archive -Path $zipPath -DestinationPath $tmpDir -Force

  Get-ChildItem $tmpDir -Filter "*.ttf" | ForEach-Object {
    $dest = Join-Path $fontsDir $_.Name
    Copy-Item $_.FullName $dest -Force
    $valueName = "$($_.BaseName) (TrueType)"
    New-ItemProperty -Path $regPath -Name $valueName -Value $_.Name -PropertyType String -Force | Out-Null
  }

  Remove-Item $zipPath, $tmpDir -Recurse -Force -ErrorAction SilentlyContinue
  Write-Host "Installed FiraCode Nerd Font for the current user."
}

# Best-effort: set it as the default font in Windows Terminal
$wtPaths = @(
  (Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"),
  (Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json"),
  (Join-Path $env:LOCALAPPDATA "Microsoft\Windows Terminal\settings.json")
)

foreach ($settingsPath in $wtPaths) {
  if (-not (Test-Path $settingsPath)) { continue }
  try {
    $raw = Get-Content $settingsPath -Raw
    $stripped = $raw -replace "(?m)^\s*//.*$", ""
    $json = $stripped | ConvertFrom-Json

    if (-not $json.profiles) { $json | Add-Member -NotePropertyName profiles -NotePropertyValue ([PSCustomObject]@{}) -Force }
    if (-not $json.profiles.defaults) { $json.profiles | Add-Member -NotePropertyName defaults -NotePropertyValue ([PSCustomObject]@{}) -Force }
    if (-not $json.profiles.defaults.font) { $json.profiles.defaults | Add-Member -NotePropertyName font -NotePropertyValue ([PSCustomObject]@{}) -Force }
    $json.profiles.defaults.font | Add-Member -NotePropertyName face -NotePropertyValue $fontName -Force

    Copy-Item $settingsPath "$settingsPath.bak" -Force
    $json | ConvertTo-Json -Depth 32 | Set-Content $settingsPath -Encoding UTF8
    Write-Host "Updated $settingsPath (backup at $settingsPath.bak)"
  } catch {
    Write-Host "Could not auto-update $settingsPath -- set the font manually: Settings > Defaults > Appearance > Font face = $fontName"
  }
}
'
