#!/bin/bash
set -euo pipefail

ZSH_PATH="$(command -v zsh || true)"

if [ -n "$ZSH_PATH" ] && [ "$SHELL" != "$ZSH_PATH" ]; then
  grep -qxF "$ZSH_PATH" /etc/shells || echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
  sudo chsh -s "$ZSH_PATH" "$USER"
  echo "Default shell set to zsh. Restart your session for it to take effect."
fi
