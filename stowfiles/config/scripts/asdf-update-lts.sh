#!/usr/bin/env bash
# 🔄 asdf-update-lts — Update all asdf tools to their latest stable versions

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
  echo -e "${2:-$NC}$1${NC}"
}

# Check if asdf is installed
if ! command -v asdf >/dev/null 2>&1; then
  log "❌ asdf is not installed or not in PATH" "$RED"
  exit 1
fi

log "🔄 Updating all asdf tools to their latest stable versions..." "$BLUE"

# Ensure we're at home so .tool-versions is global
cd ~ || {
  log "❌ Could not change to home directory" "$RED"
  exit 1
}

# Get list of installed plugins
plugins=$(asdf plugin list 2>/dev/null || true)

if [ -z "$plugins" ]; then
  log "⚠️  No asdf plugins found" "$YELLOW"
  exit 0
fi

# Track success/failure
updated_count=0
failed_count=0
skipped_count=0

log "\n📋 Processing plugins: $(echo "$plugins" | wc -l | tr -d ' ')" "$BLUE"

for plugin in $plugins; do
  log "\n🔍 Checking latest version for $plugin..." "$BLUE"

  # Get the latest stable version
  latest=$(asdf latest "$plugin" 2>/dev/null || true)

  if [ -z "$latest" ]; then
    log "❌ Could not determine latest version for $plugin. Skipping." "$RED"
    ((failed_count++))
    continue
  fi

  # Get current global version
  current=$(asdf current "$plugin" 2>/dev/null | awk '{print $2}' || echo "none")
  
  if [ "$current" = "$latest" ]; then
    log "✅ $plugin is already at latest version ($latest)" "$GREEN"
    ((skipped_count++))
    continue
  fi

  log "📊 $plugin: $current → $latest"

  # Check if latest version is already installed
  if ! asdf list "$plugin" 2>/dev/null | grep -q "^[[:space:]]*$latest[[:space:]]*$"; then
    log "⬇️  Installing $plugin $latest..." "$YELLOW"
    if asdf install "$plugin" "$latest"; then
      log "✅ Successfully installed $plugin $latest" "$GREEN"
    else
      log "❌ Failed to install $plugin $latest" "$RED"
      ((failed_count++))
      continue
    fi
  else
    log "✅ $plugin $latest already installed" "$GREEN"
  fi

  log "📌 Setting $plugin globally to $latest..." "$YELLOW"
  if asdf set "$plugin" "$latest"; then
    log "✅ Successfully set $plugin to $latest" "$GREEN"
    ((updated_count++))
  else
    log "❌ Failed to set $plugin to $latest" "$RED"
    ((failed_count++))
  fi
done

# Summary
log "\n🎉 Update Summary:" "$BLUE"
log "  ✅ Updated: $updated_count" "$GREEN"
log "  ⏭️  Skipped (already latest): $skipped_count" "$YELLOW"
log "  ❌ Failed: $failed_count" "$RED"

if [ $failed_count -gt 0 ]; then
  log "\n⚠️  Some updates failed. Check the output above for details." "$YELLOW"
fi

log "\n📋 Current versions:" "$BLUE"
asdf current

# Backup the updated configuration
if [ $updated_count -gt 0 ]; then
  log "\n💾 Backing up updated configuration..." "$BLUE"
  
  BACKUP_DIR="$HOME/.config/asdf"
  mkdir -p "$BACKUP_DIR"
  
  # Backup .tool-versions
  if cp "$HOME/.tool-versions" "$BACKUP_DIR/tool-versions.bak"; then
    log "✅ Backed up .tool-versions to $BACKUP_DIR/tool-versions.bak" "$GREEN"
  else
    log "❌ Failed to backup .tool-versions" "$RED"
  fi
  
  # Backup plugin list
  if asdf plugin list --urls | sed '/^\s*$/d' > "$BACKUP_DIR/plugin-list.txt"; then
    log "✅ Backed up plugin list to $BACKUP_DIR/plugin-list.txt" "$GREEN"
  else
    log "❌ Failed to backup plugin list" "$RED"
  fi
  
  # Backup completions if they exist
  if [ -f "$HOME/.asdf/completions/asdf.bash" ]; then
    if cp "$HOME/.asdf/completions/asdf.bash" "$BACKUP_DIR/asdf.bash"; then
      log "✅ Backed up asdf completions" "$GREEN"
    else
      log "❌ Failed to backup asdf completions" "$RED"
    fi
  fi
  
  # Backup symlink for asdf.sh if on Apple Silicon
  ASDF_SYMLINK="$HOME/.asdf/asdf.sh"
  if [ -L "$ASDF_SYMLINK" ]; then
    if readlink "$ASDF_SYMLINK" > "$BACKUP_DIR/asdf-sh-symlink.txt"; then
      log "✅ Backed up asdf.sh symlink" "$GREEN"
    else
      log "❌ Failed to backup asdf.sh symlink" "$RED"
    fi
  fi
  
  log "\n💡 Configuration backed up to $BACKUP_DIR" "$BLUE"
  log "   Use './scripts/asdf-restore.sh' to restore this configuration later" "$BLUE"
else
  log "\n💡 No updates were made, skipping backup" "$YELLOW"
fi
