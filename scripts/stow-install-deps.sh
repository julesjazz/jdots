#!/usr/bin/env bash
# 🛠️ stow-install-deps — Install stow + rsync (via brew)

set -euo pipefail
cd "$(dirname "$0")/.."

echo -e "\n🔧  \033[1;34mInstalling stow & rsync via Homebrew...\033[0m"

if ! command -v brew &>/dev/null; then
  echo "❌ Homebrew is not installed. Please install it first."
  exit 1
fi

brew install stow rsync

echo -e "\n✅  \033[1;32mDependencies installed!\033[0m"
