#!/bin/bash
set -euo pipefail

# Every coding harness on this machine is provisioned by `uze setup`, not by
# a curl|sh script per vendor. uze already knows each one's official
# installer, reports which route it took (`uze setup inspect <harness>`),
# and verifies an existing install instead of blindly reinstalling. The
# project's own declared plugins are then installed with `uze install` from
# ~/uze; setup provisions harnesses only. This replaced
# run_once_before_70-claude-code.sh and 71-codex-cli.sh, and absorbed
# `opencode`, which never had a script at all.
#
# Numbered past 96-uze.sh, which builds the `uze` binary this needs. That is
# also why 98-claude-plugins.sh and 99-harness-auth.sh sit after it rather
# than at their old 83/95 slots: `claude` does not exist until this runs.
#
# `antigravity` is deliberately not listed -- uze can provision it, but it
# isn't used on this machine. Add it here if that changes.

UZE_BIN="$(command -v uze || echo "$HOME/.cargo/bin/uze")"

if [ ! -x "$UZE_BIN" ]; then
  echo "uze not found, skipping harness provisioning."
  exit 0
fi

"$UZE_BIN" setup claude codex opencode

# agents.yaml/agents.lock in the UZE checkout declare the personal ai
# marketplace (git, tui, openspec and code). UZE owns the generated vendor
# marketplace and plugin lifecycle, so do not mirror those selectors in
# ~/.claude/settings.json.
if [ -d "$HOME/uze/.git" ]; then
  (
    cd "$HOME/uze"
    "$UZE_BIN" install --trust
  )
fi
