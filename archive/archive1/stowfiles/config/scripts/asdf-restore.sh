#!/bin/bash

set -euo pipefail

BACKUP_DIR="$HOME/.config/asdf"
COMPLETIONS_TARGET="$HOME/.asdf/completions/asdf.bash"
TOOL_VERSIONS_TARGET="$HOME/.tool-versions"

echo "♻️  Starting asdf restore from $BACKUP_DIR..."

# Step 1: Restore plugins
if [ -f "$BACKUP_DIR/plugin-list.txt" ]; then
  echo "🔁 Restoring plugins from plugin-list.txt..."
  while read -r plugin url; do
    # Skip empty or malformed lines
    if [[ -z "$plugin" || -z "$url" ]]; then
      continue
    fi

    if asdf plugin list | grep -q "^$plugin$"; then
      echo "⏭️  Plugin $plugin already exists. Skipping."
    else
      echo "➕ Adding plugin $plugin from $url"
      asdf plugin add "$plugin" "$url" || echo "⚠️  Failed to add plugin: $plugin"
    fi
  done < "$BACKUP_DIR/plugin-list.txt"
else
  echo "❌ No plugin-list.txt found in $BACKUP_DIR."
fi

# Step 2: Restore .tool-versions
if [ -f "$BACKUP_DIR/tool-versions.bak" ]; then
  if cmp -s "$BACKUP_DIR/tool-versions.bak" "$TOOL_VERSIONS_TARGET"; then
    echo "⏭️  .tool-versions already up to date. Skipping copy."
  else
    echo "📝 Restoring .tool-versions..."
    cp "$BACKUP_DIR/tool-versions.bak" "$TOOL_VERSIONS_TARGET"
  fi
else
  echo "❌ No tool-versions.bak found in $BACKUP_DIR."
fi

# Step 3: Install tool versions (if not already installed)
echo "⬇️ Ensuring all tool versions are installed..."
while read -r plugin version; do
  [[ -z "$plugin" || -z "$version" ]] && continue
  if asdf list "$plugin" | grep -q "^  $version$"; then
    echo "⏭️  $plugin $version already installed. Skipping."
  else
    echo "⬇️ Installing $plugin $version..."
    asdf install "$plugin" "$version"
  fi
done < <(grep -v '^#' "$TOOL_VERSIONS_TARGET")

# Step 4: Restore completions
if [ -f "$BACKUP_DIR/asdf.bash" ]; then
  if [ -f "$COMPLETIONS_TARGET" ] && cmp -s "$BACKUP_DIR/asdf.bash" "$COMPLETIONS_TARGET"; then
    echo "⏭️  Completions file already up to date. Skipping copy."
  else
    echo "🔧 Restoring completions file..."
    mkdir -p "$(dirname "$COMPLETIONS_TARGET")"
    cp "$BACKUP_DIR/asdf.bash" "$COMPLETIONS_TARGET"
  fi
else
  echo "❌ No asdf.bash completions file found in $BACKUP_DIR."
fi

# Conditionally restore asdf.sh symlink on Apple Silicon
ARCH=$(uname -m)
if [ "$ARCH" = "arm64" ] && [ -f "$BACKUP_DIR/asdf-sh-symlink.txt" ]; then
  TARGET_PATH=$(cat "$BACKUP_DIR/asdf-sh-symlink.txt")
  echo "🔁 Restoring asdf.sh symlink for Apple Silicon..."
  ln -sf "$TARGET_PATH" "$HOME/.asdf/asdf.sh"
fi

echo "✅ asdf restore complete!"
