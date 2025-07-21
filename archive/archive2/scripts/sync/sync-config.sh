#!/usr/bin/env bash
set -euo pipefail

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  echo "⚠️  Please run this script through \make sync-config\ to ensure redaction is applied."
  exit 1
fi

# -----------------------------------------------------------------------------
# sync-config.sh: Temporary script to sync macOS ~/.config to jdots/core/
# Filters unnecessary files, preserves structure, avoids sensitive data.
# -----------------------------------------------------------------------------

MODE="${1:-}"

if [[ "$MODE" != "backup-redact" && "$MODE" != "restore" && "$MODE" != "new-install" ]]; then
  echo "❌ Usage: $0 [backup-redact|restore|new-install]"
  exit 1
fi

# Define paths
SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_PATH/.." && pwd)"
CONFIG_SRC="$HOME/.config"
CONFIG_DEST="$DOTFILES_ROOT/core"
FILTER_FILE="$DOTFILES_ROOT/scripts/filters/sync-config.filter"
PATTERNS_FILE="$DOTFILES_ROOT/scripts/filters/redact.patterns"
PROFILE_ENV="$DOTFILES_ROOT/profile.env"

# Filter Check
[[ -f "$FILTER_FILE" ]] || { echo "❌ Filter file not found! $FILTER_FILE"; exit 1; }
[[ -f "$PATTERNS_FILE" ]] || { echo "❌ Patterns file not found! $PATTERNS_FILE"; exit 1; }

# ────────────────────────────────────────────────────────────────────────
if [[ "$MODE" == "backup-redact" || "$MODE" == "new-install" ]]; then
  [[ -f "$FILTER_FILE" ]] || { echo "❌ Filter file not found! $FILTER_FILE"; exit 1; }

  echo "🌀 Syncing $CONFIG_SRC to $CONFIG_DEST using: $FILTER_FILE"
  rsync -av --delete --delete-excluded \
    --filter="merge $FILTER_FILE" \
    "$CONFIG_SRC/" "$CONFIG_DEST/"

  if [[ "$MODE" == "backup-redact" ]]; then
    echo "🔐 Redacting sensitive values in $CONFIG_DEST"
    find "$CONFIG_DEST" -type f | while read -r file; do
      if grep -qE "(email =|signingkey =|name =|GIT_AUTHOR|AWS_ACCESS_KEY_ID|GH_TOKEN|GITHUB_TOKEN)" "$file"; then
        echo "🛡️  Redacting: ${file#$CONFIG_DEST/}"
        tmp="$(mktemp)"
        sed -f "$PATTERNS_FILE" "$file" > "$tmp"
        mv "$tmp" "$file"
      fi
    done
  fi

  echo "✅ Config sync complete."
  exit 0
fi

# ────────────────────────────────────────────────────────────────────────
if [[ "$MODE" == "restore" ]]; then
  [[ -f "$PROFILE_ENV" ]] || { echo "❌ profile.env not found at $PROFILE_ENV"; exit 1; }
  echo "📄 Loading: $PROFILE_ENV"
  # shellcheck disable=SC1090
  source "$PROFILE_ENV"

  echo "🔁 Restoring sensitive placeholders in $CONFIG_DEST"
  find "$CONFIG_DEST" -type f | while read -r file; do
    rel_path="${file#$CONFIG_DEST/}"
    echo "🔁 Restoring: $rel_path"
    tmp="$(mktemp)"
    content="$(cat "$file")"
    content="${content//\{\{EMAIL\}\}/$EMAIL}"
    content="${content//\{\{FIRST_NAME\}\}/$FIRST_NAME}"
    content="${content//\{\{LAST_NAME\}\}/$LAST_NAME}"
    content="${content//\{\{GPG_KEY_ID\}\}/$GPG_KEY_ID}"
    content="${content//\{\{AWS_ACCESS_KEY_ID\}\}/$AWS_ACCESS_KEY_ID}"
    content="${content//\{\{AWS_SECRET_ACCESS_KEY\}\}/$AWS_SECRET_ACCESS_KEY}"
    content="${content//\{\{GITHUB_TOKEN\}\}/$GITHUB_TOKEN}"
    content="${content//\{\{HOME\}\}/$HOME}"
    echo "$content" > "$tmp"
    mv "$tmp" "$file"
  done

  echo "✅ Restore complete."
  exit 0
fi