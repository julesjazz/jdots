#!/usr/bin/env bash
set -euo pipefail

# Paths
SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_PATH/.." && pwd)"
CONFIG_SRC="$DOTFILES_ROOT/core"
CONFIG_DEST="$HOME/.config"
PROFILE_ENV="$DOTFILES_ROOT/profile.env"
PKG_INSTALLER="$DOTFILES_ROOT/scripts/pm/pm-new-install.sh"

echo "🔧 Bootstrapping dotfiles from: $DOTFILES_ROOT"

# ────────────────────────────────────────────────────────────────────────
# Load profile variables if available
if [[ -f "$PROFILE_ENV" ]]; then
  echo "📄 Loading profile: $PROFILE_ENV"
  # shellcheck disable=SC1090
  source "$PROFILE_ENV"
else
  echo "❌ No profile.env found!"
  echo "💡 Run \`make new-profile\` to create one before continuing."
  exit 1
fi

# ────────────────────────────────────────────────────────────────────────
# Sync each core config into ~/.config
echo "📁 Syncing configs to $CONFIG_DEST"
for dir in "$CONFIG_SRC"/*; do
  name=$(basename "$dir")
  echo " → $name"
  rsync -a --delete "$dir/" "$CONFIG_DEST/$name/"
done

# ────────────────────────────────────────────────────────────────────────
# Create symlinks in $HOME for common config files
declare -A SYMLINKS=(
  [".bashrc"]="$CONFIG_DEST/bash/bashrc"
  [".zshrc"]="$CONFIG_DEST/zsh/zshrc"
  [".gitconfig"]="$CONFIG_DEST/git/gitconfig"
  [".gitignore"]="$CONFIG_DEST/git/gitignore"
)

echo "🔗 Creating symlinks in $HOME"
for target in "${!SYMLINKS[@]}"; do
  src="${SYMLINKS[$target]}"
  dest="$HOME/$target"
  if [[ -e "$src" ]]; then
    echo " → $target → $src"
    ln -sf "$src" "$dest"
  else
    echo " ⚠️  Skipping $target (source not found: $src)"
  fi
done

# ────────────────────────────────────────────────────────────────────────
# Run package installation if script exists
if [[ -f "$PKG_INSTALLER" ]]; then
  echo "📦 Installing system packages from profile..."
  bash "$PKG_INSTALLER"
else
  echo "⚠️  Package installer script not found: $PKG_INSTALLER"
fi

echo "✅ Dotfiles bootstrap complete."