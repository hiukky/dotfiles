#!/bin/bash
set -euo pipefail

BUN_BIN="$(command -v bun || echo "$HOME/.bun/bin/bun")"

if [ -x "$BUN_BIN" ] && ! command -v vercel >/dev/null 2>&1; then
  "$BUN_BIN" add --global vercel
fi
