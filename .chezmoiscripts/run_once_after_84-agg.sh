#!/bin/bash
set -euo pipefail

CARGO_BIN="$(command -v cargo || echo "$HOME/.local/share/mise/shims/cargo")"

if [ -x "$CARGO_BIN" ] && ! command -v agg >/dev/null 2>&1; then
  "$CARGO_BIN" install --git https://github.com/asciinema/agg
fi
