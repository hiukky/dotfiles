#!/bin/bash
set -euo pipefail

# opencode is the one harness here without an installer worth hand-scripting
# (that's why it sat in AGENTS.md's "deliberately not scripted" list). uze
# already knows how to provision it from its official install script, so this
# defers to `uze setup` instead of reimplementing that. Runs after 96, which
# is what installs uze itself.

UZE_BIN="$(command -v uze || echo "$HOME/.cargo/bin/uze")"

if [ ! -x "$UZE_BIN" ]; then
  echo "uze not found, skipping harness provisioning."
elif command -v opencode >/dev/null 2>&1; then
  echo "opencode already installed."
else
  "$UZE_BIN" setup opencode
fi
