#!/bin/bash
set -euo pipefail

# chezmoi runs this without the zshrc PATH, so neither bun (a mise shim) nor
# the ~/.bun/bin globals are found by name -- look them up explicitly.
BUN_BIN="$(command -v bun || echo "$HOME/.local/share/mise/shims/bun")"
export PATH="$HOME/.bun/bin:$PATH"

if [ -x "$BUN_BIN" ] && ! command -v ccstatusline >/dev/null 2>&1; then
  "$BUN_BIN" install -g ccstatusline
fi
