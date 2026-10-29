#!/bin/bash
set -euo pipefail

# Google Chrome stable at /opt/google/chrome, the browser the Playwright MCP
# server (claude-plugins-official/playwright) launches by default. Playwright
# installs it from Google's .deb with apt, system libraries included, so it
# asks for sudo once.

[ -x /opt/google/chrome/chrome ] && exit 0

NPX_BIN="$(command -v npx || echo "$HOME/.local/share/mise/shims/npx")"
[ -x "$NPX_BIN" ] || exit 0

"$NPX_BIN" --yes playwright@latest install chrome
