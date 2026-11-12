#!/bin/bash
set -euo pipefail

# Windows pointer settings for gaming: no pointer acceleration and the neutral
# 6/11 speed, so one inch of mouse travel is always the same number of pixels.
# Games with raw input (Warzone's MouseUsesRawInput) skip these anyway; this
# keeps the desktop, menus and games without raw input consistent with them.
#
# "Enhance pointer precision" is acceleration: MouseSpeed=1 with thresholds
# 6/10. Off means all three are 0. Speed 10 is the 6th notch of 11 -- the only
# one with a 1:1 multiplier.
#
# SystemParametersInfo applies the change live (no logoff) and, with
# SPIF_UPDATEINIFILE|SPIF_SENDCHANGE, also writes HKCU\Control Panel\Mouse, so
# the registry is never written by hand here. Per-user, but host-wide: every
# WSL distro on this machine shares it.
#
# run_onchange_: re-runs only when this file changes, so a later tweak made in
# Windows Settings is not reverted by every apply. No-ops outside WSL.
if ! grep -qi microsoft /proc/version 2>/dev/null; then
  exit 0
fi

POINTER_SPEED=10   # 1..20; 10 = notch 6/11

powershell.exe -NoProfile -Command "
  \$ErrorActionPreference = 'Stop'
  Add-Type -Namespace Win32 -Name Spi -MemberDefinition @'
[DllImport(\"user32.dll\", SetLastError = true)]
public static extern bool SystemParametersInfo(uint action, uint param, int[] vparam, uint winIni);
[DllImport(\"user32.dll\", SetLastError = true)]
public static extern bool SystemParametersInfo(uint action, uint param, System.IntPtr vparam, uint winIni);
'@
  \$SPI_SETMOUSE = 0x0004; \$SPI_SETMOUSESPEED = 0x0071; \$SPIF = 0x01 -bor 0x02
  if (-not [Win32.Spi]::SystemParametersInfo(\$SPI_SETMOUSE, 0, [int[]](0, 0, 0), \$SPIF)) { throw 'SPI_SETMOUSE failed' }
  if (-not [Win32.Spi]::SystemParametersInfo(\$SPI_SETMOUSESPEED, 0, [IntPtr]$POINTER_SPEED, \$SPIF)) { throw 'SPI_SETMOUSESPEED failed' }
  \$m = Get-ItemProperty 'HKCU:\Control Panel\Mouse'
  'mouse-windows: speed=' + \$m.MouseSensitivity + ' accel=' + \$m.MouseSpeed + ' thresholds=' + \$m.MouseThreshold1 + '/' + \$m.MouseThreshold2
" | tr -d '\r'
