#!/bin/bash
set -euo pipefail

# Split out of run_once_after_95-account-setup.sh when harness installation
# moved to `uze setup` (97): on a fresh machine `claude` does not exist until
# that script runs, so this has to come after it. Still the last thing a
# `chezmoi apply` does.
#
# It only *reports*, it does not log in. The block this replaced called
# `claude auth status` / `claude auth login`, and neither does what it looks
# like: `claude` has no `auth status` subcommand, so on a TTY (which is
# exactly how chezmoi runs this) the words are taken as a prompt and the full
# interactive Claude Code TUI opens -- blocking the whole apply until someone
# notices and quits it. Verified by running it under a pty.
#
# Auth state is read from ~/.claude/.credentials.json instead, which is where
# the OAuth token actually lives. Only the presence of the key is checked;
# the value is never read or printed.

echo "==> Claude Code"
CLAUDE_BIN="$(command -v claude || echo "$HOME/.local/bin/claude")"
CREDS="$HOME/.claude/.credentials.json"

if [ ! -x "$CLAUDE_BIN" ]; then
  echo "claude binary not found, skipping."
elif [ -f "$CREDS" ] && jq -e '.claudeAiOauth.accessToken' "$CREDS" >/dev/null 2>&1; then
  echo "Already authenticated."
else
  echo "Not authenticated. Run 'claude' and use /login to finish -- this is"
  echo "left to you on purpose, so a chezmoi apply never blocks on a TUI."
fi
