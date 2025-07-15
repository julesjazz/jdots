#!/usr/bin/env bash
# 📦 stow-backup — Back up config + select home dotfiles to jdots/stowfiles

set -euo pipefail
cd "$(dirname "$0")/.."  # move to jdots root

echo -e "\n🔄  \033[1;34mBacking up dotfiles into jdots/stowfiles...\033[0m"

STOW_DIR="stowfiles"

backup_config() {
  local src="$HOME/.config"
  local dest="$STOW_DIR/config"
  mkdir -p "$dest"

  for dir in "$src"/*/; do
    [[ -d "$dir" ]] || continue
    name="$(basename "$dir")"

    echo "📝  Backing up $name → $dest/$name"
    mkdir -p "$dest/$name"

    rsync -a --delete \
      --exclude 'plugins/***' \
      --exclude '*.zsh_history' \
      --exclude '*.zcompdump*' \
      --exclude '*.z' \
      --exclude 'sessions/***' \
      --exclude 'netrwhist' \
      --exclude 'undo/***' \
      --exclude 'logs/***' \
      --exclude 'temp/***' \
      --exclude 'tmp/***' \
      --exclude 'cache/***' \
      --exclude-from=.stow-local-ignore \
      "$dir" "$dest/$name/"
  done
}

backup_home() {
  local dest="$STOW_DIR/home"
  mkdir -p "$dest"

  for file in .zshrc .gitconfig .bashrc; do
    src_file="$HOME/$file"
    if [[ -f "$src_file" ]]; then
      echo "📝  Backing up $file → $dest/"
      rsync -a --delete \
        --exclude '*.zsh_history' \
        --exclude '*.zcompdump*' \
        --exclude '*.z' \
        --exclude-from=.stow-local-ignore \
        "$src_file" "$dest/"
    else
      echo "⚠️  Skipping $file — not found in \$HOME"
    fi
  done
}

backup_config
backup_home

echo -e "\n✅  \033[1;32mBackup complete!\033[0m"
