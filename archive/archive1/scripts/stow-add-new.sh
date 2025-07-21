#!/usr/bin/env bash
# ➕ stow-add-new — Add a new dotdir to jdots/stowfiles

set -euo pipefail
cd "$(dirname "$0")/.."

echo -e "\n📂  \033[1;34mAdd new config to jdots/stowfiles...\033[0m"

read -rp "🔹 Enter the full path to the config directory: " src
read -rp "🔹 Stow into which group? [home/config]: " target

case "$target" in
  home) dest="stowfiles/home" ;;
  config) dest="stowfiles/config" ;;
  *)
    echo "❌ Invalid target. Use 'home' or 'config'."
    exit 1 ;;
esac

name="$(basename "$src")"
echo "🆕  Adding $name → $dest/$name"

mkdir -p "$dest/$name"
  rsync -a --exclude-from=.rsyncignore "$src/" "$dest/$name/"

echo -e "\n✅  \033[1;32mAdded $name to $dest\033[0m"
