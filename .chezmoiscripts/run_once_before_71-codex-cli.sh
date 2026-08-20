#!/bin/bash
set -euo pipefail

if ! command -v codex >/dev/null 2>&1; then
  curl -fsSL https://chatgpt.com/codex/install.sh | sh
fi
