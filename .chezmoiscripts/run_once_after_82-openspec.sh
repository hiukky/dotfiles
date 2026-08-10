#!/bin/bash
set -euo pipefail

NPM_BIN="$(command -v npm || echo "$HOME/.local/share/mise/shims/npm")"

if [ -x "$NPM_BIN" ] && ! command -v openspec >/dev/null 2>&1; then
  "$NPM_BIN" install -g @fission-ai/openspec@latest
fi
