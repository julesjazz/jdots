#!/usr/bin/env bash
set -euo pipefail

# Define backup target relative to jdots
DOTFILES_ROOT="${DOTFILES_ROOT:-$HOME/jdots}"
BACKUP_DIR="$DOTFILES_ROOT/core/asdf"
mkdir -p "$BACKUP_DIR"

echo "🧭 Backing up asdf plugin list to $BACKUP_DIR/plugin-list.txt"
asdf plugin list --urls | sed '/^\s*$/d' > "$BACKUP_DIR/plugin-list.txt"

echo "📦 Backing up completions to $BACKUP_DIR/asdf.bash"
cp "$HOME/.asdf/completions/asdf.bash" "$BACKUP_DIR/asdf.bash"

# Optional: back up .tool-versions if symlinked for compatibility
TOOL_VERSIONS="$HOME/.tool-versions"
if [[ -f "$TOOL_VERSIONS" && ! -L "$TOOL_VERSIONS" ]]; then
  echo "📝 Backing up .tool-versions to $BACKUP_DIR/tool-versions.bak"
  cp "$TOOL_VERSIONS" "$BACKUP_DIR/tool-versions.bak"
fi

# Backup symlink info for M1/M2/M3 macOS installs
ASDF_SYMLINK="$HOME/.asdf/asdf.sh"
if [[ -L "$ASDF_SYMLINK" ]]; then
  echo "🔗 Recording asdf.sh symlink target"
  readlink "$ASDF_SYMLINK" > "$BACKUP_DIR/asdf-sh-symlink.txt"
fi

echo "✅ asdf backup complete!"