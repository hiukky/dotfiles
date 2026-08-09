#!/bin/bash
set -euo pipefail

if ! command -v herdr >/dev/null 2>&1; then
  curl -fsSL https://herdr.dev/install.sh | sh
fi

HERDR_BIN="$(command -v herdr || echo "$HOME/.local/bin/herdr")"

if [ -x "$HERDR_BIN" ] && ! "$HERDR_BIN" plugin list 2>/dev/null | grep -q herdr-file-viewer; then
  "$HERDR_BIN" plugin install smarzban/herdr-file-viewer -y
fi
