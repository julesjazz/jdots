#!/usr/bin/env bash
# 🚀 stow-deploy — Symlink stowfiles into $HOME and ~/.config

set -euo pipefail
cd "$(dirname "$0")/.."

echo -e "\n🔗  \033[1;34mDeploying jdots/stowfiles with GNU Stow...\033[0m"

cd stowfiles

echo -e "\n📁  Deploying home packages..."
for dir in home/*/; do
  pkg="${dir#home/}"
  echo "📎  stow --target=\$HOME $pkg"
  stow -d "home" -t "$HOME" "$pkg"
done

echo -e "\n📁  Deploying config packages..."
for dir in config/*/; do
  pkg="${dir#config/}"
  echo "📎  stow --target=\$HOME/.config $pkg"
  stow -d "config" -t "$HOME/.config" "$pkg"
done

echo -e "\n✅  \033[1;32mDeployment complete!\033[0m"
