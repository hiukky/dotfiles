#!/bin/bash
set -euo pipefail

sudo apt-get update -qq
sudo apt-get install -y \
  zsh \
  git \
  curl \
  unzip \
  ca-certificates \
  gnupg \
  build-essential \
  eza \
  bat \
  fd-find \
  ripgrep \
  fzf \
  gh \
  glab \
  tree \
  jq
