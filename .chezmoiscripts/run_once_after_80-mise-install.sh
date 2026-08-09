#!/bin/bash
set -euo pipefail

MISE_BIN="$(command -v mise || echo "$HOME/.local/bin/mise")"

if [ -x "$MISE_BIN" ]; then
  "$MISE_BIN" install
fi
