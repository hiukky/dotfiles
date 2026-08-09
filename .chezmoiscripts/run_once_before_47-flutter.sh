#!/bin/bash
set -euo pipefail

# Matches the existing PATH in dot_zshrc ($HOME/.flutter/bin). Android SDK
# stays on the Windows host (installed via Android Studio, see
# run_once_before_18-windows-apps.sh) -- ANDROID_HOME in dot_zshrc points
# into /mnt/c/... on purpose.
if [ ! -d "$HOME/.flutter" ]; then
  git clone --depth 1 -b stable https://github.com/flutter/flutter.git "$HOME/.flutter"
fi

"$HOME/.flutter/bin/flutter" precache >/dev/null 2>&1 || true
