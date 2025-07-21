#!/usr/bin/env bash
set -euo pipefail

DOTFILES_ROOT="${DOTFILES_ROOT:-$HOME/jdots}"
ASDF_DIR="$HOME/.asdf"
ASDF_BACKUP="$DOTFILES_ROOT/core/asdf"
ASDF_GIT_URL="https://github.com/asdf-vm/asdf.git"
ASDF_VERSION="v0.14.0"  # Pin to a known good version if desired

# ────────────────────────────────────────────────────────────────────────
# Step 1: Clone asdf if missing
if [[ ! -d "$ASDF_DIR" ]]; then
  echo "📥 Installing asdf from $ASDF_GIT_URL..."
  git clone --branch "$ASDF_VERSION" "$ASDF_GIT_URL" "$ASDF_DIR"
else
  echo "✅ asdf already installed at $ASDF_DIR"
fi

# ────────────────────────────────────────────────────────────────────────
# Step 2: Restore completions and sh symlink info
if [[ -f "$ASDF_BACKUP/asdf.bash" ]]; then
  echo "🔁 Restoring completions"
  cp "$ASDF_BACKUP/asdf.bash" "$ASDF_DIR/completions/asdf.bash"
fi

if [[ -f "$ASDF_BACKUP/asdf-sh-symlink.txt" ]]; then
  echo "🔁 Restoring asdf.sh symlink if needed (manual step if not default layout)"
  # Not automatically re-linking for safety
  cat "$ASDF_BACKUP/asdf-sh-symlink.txt"
fi

# ────────────────────────────────────────────────────────────────────────
# Step 3: Restore plugins
PLUGIN_LIST="$ASDF_BACKUP/plugin-list.txt"
if [[ -f "$PLUGIN_LIST" ]]; then
  echo "🔗 Restoring asdf plugins..."
  while read -r line; do
    plugin=$(echo "$line" | awk '{print $1}')
    url=$(echo "$line" | awk '{print $2}')
    echo "  → $plugin from $url"
    asdf plugin add "$plugin" "$url" 2>/dev/null || echo "    ↪️  already added"
  done < "$PLUGIN_LIST"
else
  echo "⚠️  No plugin list found at $PLUGIN_LIST"
fi

echo "✅ asdf install complete!"