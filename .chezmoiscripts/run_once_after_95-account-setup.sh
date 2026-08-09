#!/bin/bash
set -euo pipefail

# Things that inherently need a human in the loop (browser OAuth, device
# codes) can't be silently scripted -- this runs last and walks through them
# interactively, using whatever real TTY is running `chezmoi apply`.

echo "==> SSH key"
KEY_PATH="$HOME/.ssh/id_ed25519"
if [ -f "$KEY_PATH" ]; then
  echo "Already have a key at $KEY_PATH, skipping."
else
  echo "No key found, generating one..."
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"
  ssh-keygen -t ed25519 -N "" -C "$(whoami)@$(hostname)" -f "$KEY_PATH"
fi

echo "==> GitHub CLI"
if gh auth status >/dev/null 2>&1; then
  echo "Already authenticated."
else
  echo "Not authenticated, logging in..."
  gh auth login
fi

if gh auth status >/dev/null 2>&1; then
  PUBKEY_BLOB="$(awk '{print $2}' "$KEY_PATH.pub")"
  if gh ssh-key list 2>/dev/null | cut -f2 | grep -qF "$PUBKEY_BLOB"; then
    echo "SSH key already registered with GitHub."
  else
    echo "Registering SSH key with GitHub..."
    gh ssh-key add "$KEY_PATH.pub" --title "$(hostname)"
  fi
fi

echo "==> GitLab CLI"
# glab auth status always exits 0, even when not authenticated -- it only
# reports problems in its text output. Check for the actual "Logged in to"
# success line instead of trusting the exit code.
if glab auth status 2>&1 | grep -q "Logged in to"; then
  echo "Already authenticated."
else
  echo "Not authenticated, logging in..."
  glab auth login
fi

echo "==> Claude Code"
CLAUDE_BIN="$(command -v claude || echo "$HOME/.local/bin/claude")"
if [ ! -x "$CLAUDE_BIN" ]; then
  echo "claude binary not found, skipping."
elif "$CLAUDE_BIN" auth status 2>/dev/null | grep -q '"loggedIn": *true'; then
  echo "Already authenticated."
else
  echo "Not authenticated, logging in..."
  "$CLAUDE_BIN" auth login
fi
