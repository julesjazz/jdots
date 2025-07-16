#!/usr/bin/env bash
# 🧹 cleanup-config — Clean up duplicate/misplaced files in ~/.config

set -euo pipefail
cd "$(dirname "$0")/.."

echo -e "\n🧹  \033[1;34mCleaning up ~/.config structure...\033[0m"

# Files that should be directly in ~/.config (from config-root)
CONFIG_ROOT_FILES=(
  ".aliases"
  ".gitignore" 
  ".stow-local-ignore"
  "Makefile"
)

# Files that were incorrectly placed directly in ~/.config (should be in subdirectories)
MISPLACED_FILES=(
  "_asdf.md"
  "_fd"
  "asdf-backup.sh"
  "asdf-install.sh"
  "asdf-restore.sh"
  "asdf-set-latest.sh"
  "asdf-sh-symlink.txt"
  "asdf-update-lts.sh"
  "asdf.bash"
)

echo -e "\n🗑️  Removing misplaced files from ~/.config..."
for file in "${MISPLACED_FILES[@]}"; do
  if [[ -f "$HOME/.config/$file" ]]; then
    echo "  🗑️  Removing ~/.config/$file"
    rm -f "$HOME/.config/$file"
  fi
done

echo -e "\n📁  Ensuring proper directory structure..."

# Create proper directories if they don't exist
mkdir -p "$HOME/.config/asdf"
mkdir -p "$HOME/.config/git"
mkdir -p "$HOME/.config/zsh"
mkdir -p "$HOME/.config/nvim"
mkdir -p "$HOME/.config/starship"

echo -e "\n📋  Current ~/.config structure after cleanup:"
ls -la "$HOME/.config" | grep -E "^d|^-" | head -20

echo -e "\n✅  \033[1;32mCleanup complete!\033[0m"
echo -e "\n💡  \033[1;33mNext steps:\033[0m"
echo "  1. Run 'make stow-restore' to properly restore configs"
echo "  2. Check that directories match stowfiles/config structure"