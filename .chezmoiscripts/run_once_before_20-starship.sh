#!/bin/bash
set -euo pipefail

if ! command -v starship >/dev/null 2>&1; then
  mkdir -p "$HOME/.local/bin"
  curl -sS https://starship.rs/install.sh | sh -s -- -y -b "$HOME/.local/bin"
fi
