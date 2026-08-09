#!/bin/bash
set -euo pipefail

# On this machine, xdg-open is configured to launch a Linux-side Chrome,
# which many CLIs (glab, gh, etc.) call directly instead of respecting
# $BROWSER. Register wsl-browser.desktop (dot_local/share/applications/) as
# the default http/https handler so xdg-open forwards to Windows too.
DESKTOP_FILE="$HOME/.local/share/applications/wsl-browser.desktop"

if command -v xdg-mime >/dev/null 2>&1 && [ -f "$DESKTOP_FILE" ]; then
  update-desktop-database "$HOME/.local/share/applications" >/dev/null 2>&1 || true
  xdg-mime default wsl-browser.desktop x-scheme-handler/http x-scheme-handler/https
  xdg-settings set default-web-browser wsl-browser.desktop >/dev/null 2>&1 || true
fi
