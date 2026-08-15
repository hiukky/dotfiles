# Bootstraps a Linux/WSL machine into this dotfiles setup, regardless of
# whether chezmoi has ever run here before: installs chezmoi if missing,
# then runs `chezmoi init --apply` on a fresh machine or `chezmoi update`
# on one that's already set up. One command either way, no need to know
# which of the two to use.
#
# Usage:
#   sh -c "$(curl -fsLS https://hiukky.com/setup.sh)"

set -e

if ! command -v chezmoi >/dev/null 2>&1; then
  sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
fi

CHEZMOI="$(command -v chezmoi || echo "$HOME/.local/bin/chezmoi")"
SOURCE_DIR="$("$CHEZMOI" source-path 2>/dev/null || echo "$HOME/.local/share/chezmoi")"

if [ -d "$SOURCE_DIR/.git" ]; then
  "$CHEZMOI" update
else
  "$CHEZMOI" init --apply hiukky
fi
