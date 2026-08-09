#!/bin/bash
set -euo pipefail

if ! command -v kind >/dev/null 2>&1; then
  mkdir -p "$HOME/.local/bin"
  KIND_VERSION="$(curl -fsSL https://api.github.com/repos/kubernetes-sigs/kind/releases/latest | grep '"tag_name"' | cut -d '"' -f4)"
  curl -fsSLo "$HOME/.local/bin/kind" \
    "https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-amd64"
  chmod +x "$HOME/.local/bin/kind"
fi
