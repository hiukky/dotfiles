#Requires -Version 5.1
<#
  Windows half of the WSL-aware sleep profile.

  Windows' idle timer only counts keyboard and mouse input, so on its own it
  would suspend the machine while a build or an agent is still running inside
  WSL. This polls the Linux-side `idle-guard check` and holds
  ES_SYSTEM_REQUIRED while it reports busy, which suppresses *idle* sleep only:
  an explicit Start > Sleep, a lid close or `powercfg /hibernate` still work,
  and if this process dies the veto dies with it and the machine sleeps
  normally. Failing open is the point -- a guard that can wedge the machine
  awake forever is worse than no guard.

  Deployed and scheduled by
  .chezmoiscripts/run_onchange_before_07-idle-guard.sh.tmpl.
#>
[CmdletBinding()]
param(
  [string] $Distro      = 'Ubuntu',
  [int]    $PollSeconds = 60,
  [string] $LogPath     = (Join-Path $env:LOCALAPPDATA 'idle-guard\guard.log')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Add-Type -Namespace IdleGuard -Name Native -MemberDefinition @'
[DllImport("kernel32.dll", SetLastError = true)]
public static extern uint SetThreadExecutionState(uint esFlags);
'@

# Written in decimal on purpose: Windows PowerShell 5.1 parses the literal
# 0x80000000 as a *signed* Int32 (-2147483648) and then throws converting that
# to the UInt32 the P/Invoke expects. ES_CONTINUOUS makes the state persist on
# this thread until changed, ES_SYSTEM_REQUIRED is the "do not idle-sleep" bit.
# ES_CONTINUOUS alone therefore means "release the veto", not "no-op".
$ES_CONTINUOUS      = [uint32]2147483648
$ES_SYSTEM_REQUIRED = [uint32]1

$null = New-Item -ItemType Directory -Force -Path (Split-Path -Parent $LogPath)

function Write-Log {
  param([string] $EventName, [string] $Detail = '')
  try {
    if ((Test-Path $LogPath) -and ((Get-Item $LogPath).Length -gt 1MB)) {
      Move-Item -Force -Path $LogPath -Destination "$LogPath.1"
    }
    $line = (@((Get-Date -Format 's'), $EventName, $Detail) -join "`t") + [Environment]::NewLine
    # AppendAllText with a BOM-less encoding: Out-File -Append in 5.1 writes a
    # UTF-8 BOM, which would land mid-file on rotation and break the awk-based
    # `idle-guard report` parsing of the first line.
    [IO.File]::AppendAllText($LogPath, $line, (New-Object Text.UTF8Encoding $false))
  }
  catch {
    # Logging must never take the guard down; a wedged veto is the worse bug.
  }
}

# True when the distro is up AND reports work. A distro that is not running
# cannot be busy, and must not be started just to ask -- booting the VM every
# minute would burn more power than the whole profile saves.
function Test-WslBusy {
  param([ref] $Reason)
  $previousEncoding = [Console]::OutputEncoding
  try {
    # `wsl.exe --list` emits UTF-16LE. Read under the default encoding it comes
    # back as "U\0b\0u\0n\0t\0u\0" and never matches the distro name.
    [Console]::OutputEncoding = [Text.Encoding]::Unicode
    $running = @(wsl.exe --list --running --quiet 2>$null) |
      ForEach-Object { $_.Trim() } |
      Where-Object { $_ }
    if ($running -notcontains $Distro) {
      $Reason.Value = 'wsl not running'
      return $false
    }

    # The Linux side writes plain UTF-8; decoding it as UTF-16 mangles it.
    [Console]::OutputEncoding = [Text.Encoding]::UTF8
    # Collected into an array and *then* indexed, never piped through
    # Select-Object -First: that stops the pipeline early, which terminates the
    # native process and leaves $LASTEXITCODE at -1. The exit code is the whole
    # answer here, so losing it makes the guard silently decide "idle" forever.
    $lines = @(wsl.exe -d $Distro -- sh -c '"$HOME"/.local/bin/idle-guard check' 2>$null)
    $busy = ($LASTEXITCODE -eq 0)
    $output = if ($lines.Count -gt 0) { $lines[0] } else { '' }
    if ($output) {
      $parts = $output -split "`t", 2
      if ($parts.Count -eq 2) {
        $Reason.Value = $parts[1].Trim()
      }
      else {
        $Reason.Value = $output.Trim()
      }
    }
    else {
      # No output and a non-zero exit usually means the script is missing (a
      # fresh machine before `chezmoi apply`). Treat as idle: fail open.
      $Reason.Value = 'no answer from wsl'
      $busy = $false
    }
    return $busy
  }
  catch {
    $Reason.Value = "error: $($_.Exception.Message)"
    return $false
  }
  finally {
    [Console]::OutputEncoding = $previousEncoding
  }
}

Write-Log -EventName 'START' -Detail ("distro={0} poll={1}s" -f $Distro, $PollSeconds)

# $null rather than $false so the first evaluation always counts as a
# transition and gets logged: an initial state that is silently wrong is
# exactly the failure this guard is most likely to have.
$held     = $null
$lastTick = Get-Date
$lastBeat = Get-Date
$null     = [IdleGuard.Native]::SetThreadExecutionState($ES_CONTINUOUS)

try {
  while ($true) {
    $now = Get-Date
    # A gap far larger than the poll interval means the process was frozen --
    # the machine slept and has just resumed. This is the only place the guard
    # can observe that it worked, so it is what `idle-guard report` counts.
    $gap = ($now - $lastTick).TotalSeconds
    if ($gap -gt ($PollSeconds * 3)) {
      Write-Log -EventName 'RESUME' -Detail ([int]$gap)
    }
    $lastTick = $now

    $reason = ''
    $busy = Test-WslBusy -Reason ([ref]$reason)

    if ($busy -ne $held) {
      if ($busy) {
        $null = [IdleGuard.Native]::SetThreadExecutionState($ES_CONTINUOUS -bor $ES_SYSTEM_REQUIRED)
        Write-Log -EventName 'HOLD' -Detail $reason
      }
      else {
        $null = [IdleGuard.Native]::SetThreadExecutionState($ES_CONTINUOUS)
        Write-Log -EventName 'RELEASE' -Detail $reason
      }
      $held = $busy
    }
    elseif (($now - $lastBeat).TotalMinutes -ge 30) {
      # Proof of life between transitions, and the sample `idle-guard report`
      # uses to show how much of the day is spent held awake.
      Write-Log -EventName 'BEAT' -Detail $(if ($busy) { "busy: $reason" } else { "idle: $reason" })
      $lastBeat = $now
    }

    Start-Sleep -Seconds $PollSeconds
  }
}
finally {
  $null = [IdleGuard.Native]::SetThreadExecutionState($ES_CONTINUOUS)
  Write-Log -EventName 'STOP'
}
