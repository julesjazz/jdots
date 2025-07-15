#!/usr/bin/env bash
# 🧙 stow-restore — Restore dotfiles from jdots/stowfiles

set -euo pipefail
cd "$(dirname "$0")/.."

echo -e "\n📥  \033[1;34mRestoring dotfiles from jdots/stowfiles...\033[0m"

STOW_DIR="stowfiles"

restore() {
  local src="$1"
  local target="$2"
  for dir in "$src"/*/; do
    [[ -d "$dir" ]] || continue
    name="$(basename "$dir")"

    # Avoid overwriting plugins in ~/.config/zsh
    if [[ "$target" == "$HOME/.config" && "$name" == "zsh" ]]; then
      echo "♻️  Restoring $name (excluding plugins/) to $target"
      rsync -a --exclude-from=.rsyncignore "$dir" "$target/"
    else
      echo "♻️  Restoring $name to $target"
      rsync -a --exclude-from=.rsyncignore "$dir" "$target/"
    fi
  done
}

restore "$STOW_DIR/config" "$HOME/.config"
restore "$STOW_DIR/home" "$HOME"

echo -e "\n✅  \033[1;32mRestore complete!\033[0m"
