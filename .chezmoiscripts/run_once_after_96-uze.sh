#!/bin/bash
set -euo pipefail

# uze is installed from source on purpose, not via its published installer
# (`curl -fsSL https://uze.hiukky.com/i | sh`): this machine develops uze, so
# the binary on PATH must be the one built from the local checkout at ~/uze.
# Runs after 95-account-setup.sh so the SSH key is already registered with
# GitHub by the time we clone over SSH.

UZE_SRC="$HOME/uze"
UZE_REPO="git@github.com:hiukky/uze.git"

if [ -d "$UZE_SRC/.git" ]; then
  # An existing checkout is a working tree, not a build artifact -- only move
  # it to main when there is nothing in progress to lose.
  if [ -n "$(git -C "$UZE_SRC" status --porcelain)" ]; then
    echo "==> $UZE_SRC has local changes, building it as-is."
  else
    git -C "$UZE_SRC" fetch --quiet origin main
    git -C "$UZE_SRC" checkout --quiet main
    git -C "$UZE_SRC" merge --ff-only --quiet origin/main
  fi
else
  git clone "$UZE_REPO" "$UZE_SRC"
fi

# cargo comes from mise (`rust` in dot_config/mise/config.toml), installed by
# run_once_after_80-mise-install.sh; chezmoi scripts don't source .zshrc, so
# the shim path is the fallback.
CARGO_BIN="$(command -v cargo || echo "$HOME/.local/share/mise/shims/cargo")"

if [ -x "$CARGO_BIN" ]; then
  # Installs into ~/.cargo/bin, already on PATH via dot_zshrc.
  "$CARGO_BIN" install --path "$UZE_SRC" --bin uze --locked --force
else
  echo "cargo not found, skipping uze build."
fi
