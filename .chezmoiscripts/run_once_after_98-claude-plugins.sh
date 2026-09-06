#!/bin/bash
set -euo pipefail

CLAUDE_BIN="$(command -v claude || echo "$HOME/.local/bin/claude")"
SETTINGS="$HOME/.claude/settings.json"

[ -x "$CLAUDE_BIN" ] || exit 0
[ -f "$SETTINGS" ] || exit 0

if ! "$CLAUDE_BIN" plugin marketplace list --json | jq -e '.[] | select(.name == "claude-plugins-official")' >/dev/null; then
  "$CLAUDE_BIN" plugin marketplace add anthropics/claude-plugins-official
fi

plugin_state() {
  "$CLAUDE_BIN" plugin list --json | jq -r --arg p "$1" '
    [.[] | select(.id == $p)] as $m
    | if ($m | length) == 0 then "absent"
      elif $m[0].enabled then "true"
      else "false"
      end
  '
}

jq -r '.enabledPlugins // {} | to_entries[] | select(.value == true) | .key' "$SETTINGS" | while IFS= read -r plugin; do
  state="$(plugin_state "$plugin")"

  if [ "$state" = "absent" ]; then
    "$CLAUDE_BIN" plugin install "$plugin"
    state="$(plugin_state "$plugin")"
  fi

  if [ "$state" = "false" ]; then
    "$CLAUDE_BIN" plugin enable "$plugin"
  fi
done
