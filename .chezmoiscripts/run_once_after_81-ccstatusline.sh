#!/bin/bash
set -euo pipefail

BUN_BIN="$(command -v bun || echo "$HOME/.bun/bin/bun")"

if [ -x "$BUN_BIN" ] && ! command -v ccstatusline >/dev/null 2>&1; then
  "$BUN_BIN" install -g ccstatusline
fi
