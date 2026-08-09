#!/bin/bash
set -euo pipefail

if ! command -v mise >/dev/null 2>&1; then
  curl -fsSL https://mise.run | sh
fi
