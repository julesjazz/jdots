#!/bin/bash

set -euo pipefail

BACKUP_DIR="$HOME/.config/asdf"
mkdir -p "$BACKUP_DIR"

echo "📝 Backing up .tool-versions to $BACKUP_DIR/tool-versions.bak"
cp "$HOME/.tool-versions" "$BACKUP_DIR/tool-versions.bak"

echo "📦 Backing up plugin list to $BACKUP_DIR/plugin-list.txt"
asdf plugin list --urls | sed '/^\s*$/d' > "$BACKUP_DIR/plugin-list.txt"

echo "🎯 Backing up asdf completions to $BACKUP_DIR/asdf.bash"
cp "$HOME/.asdf/completions/asdf.bash" "$BACKUP_DIR/asdf.bash"

# Backup symlink for asdf.sh if on M1/M2/M3 Mac
ASDF_SYMLINK="$HOME/.asdf/asdf.sh"
if [ -L "$ASDF_SYMLINK" ]; then
  echo "🔗 Backing up asdf.sh symlink..."
  readlink "$ASDF_SYMLINK" > "$BACKUP_DIR/asdf-sh-symlink.txt"
fi

# Optional: backup custom plugin source
# echo "📁 Backing up plugin source directory to $BACKUP_DIR/custom-plugins.tar.gz"
# tar czf "$BACKUP_DIR/custom-plugins.tar.gz" "$HOME/.asdf/plugins"

echo "✅ Backup complete!"
