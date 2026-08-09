#!/bin/bash
set -euo pipefail

if ! command -v nvim >/dev/null 2>&1; then
  mkdir -p "$HOME/.local/lib" "$HOME/.local/bin"

  TARBALL_URL="$(curl -fsSL https://api.github.com/repos/neovim/neovim/releases/latest \
    | grep '"browser_download_url"' \
    | grep 'nvim-linux-x86_64\.tar\.gz"' \
    | cut -d '"' -f4)"

  TMP_TARBALL="$(mktemp -u)"
  curl -fsSL -o "$TMP_TARBALL" "$TARBALL_URL"

  rm -rf "$HOME/.local/lib/nvim-linux-x86_64"
  tar -xzf "$TMP_TARBALL" -C "$HOME/.local/lib"
  rm -f "$TMP_TARBALL"

  ln -sf "$HOME/.local/lib/nvim-linux-x86_64/bin/nvim" "$HOME/.local/bin/nvim"
fi
