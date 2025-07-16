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

    # Special handling for config-root - restore contents directly to ~/.config
    if [[ "$target" == "$HOME/.config" && "$name" == "config-root" ]]; then
      echo "♻️  Restoring $name contents directly to $target"
      rsync -a --exclude-from=.rsyncignore "$dir"/ "$target/"
    # Avoid overwriting plugins in ~/.config/zsh  
    elif [[ "$target" == "$HOME/.config" && "$name" == "zsh" ]]; then
      echo "♻️  Restoring $name (excluding plugins/) to $target/$name"
      mkdir -p "$target/$name"
      rsync -a --exclude-from=.rsyncignore --exclude="plugins/" "$dir"/ "$target/$name/"
    else
      echo "♻️  Restoring $name to $target/$name"
      mkdir -p "$target/$name"
      rsync -a --exclude-from=.rsyncignore "$dir"/ "$target/$name/"
    fi
  done
}

restore "$STOW_DIR/config" "$HOME/.config"
restore "$STOW_DIR/home" "$HOME"

echo -e "\n✅  \033[1;32mRestore complete!\033[0m"
