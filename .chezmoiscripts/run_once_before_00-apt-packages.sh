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
  vim \
  bubblewrap \
  eza \
  bat \
  bind9-dnsutils \
  fd-find \
  cmake \
  clang \
  ffmpeg \
  fontconfig \
  fonts-inter \
  fonts-noto-core \
  ninja-build \
  openjdk-17-jdk \
  pkg-config \
  ripgrep \
  fzf \
  gh \
  glab \
  tree \
  jq \
  xz-utils \
  zip \
  asciinema
