#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-}"  # redact | restore

# Derive jdots repo root from script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JDOTS_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG_SRC="$JDOTS_ROOT/core"
PATTERNS_FILE="$JDOTS_ROOT/scripts/filters/redact.patterns"
PROFILE_ENV="$JDOTS_ROOT/profile.env"

[[ -f "$PATTERNS_FILE" ]] || { echo "❌ Patterns file not found! $PATTERNS_FILE"; exit 1; }

if [[ "$MODE" != "redact" && "$MODE" != "restore" ]]; then
  echo "Usage: $0 [redact|restore]"
  exit 1
fi

if [[ "$MODE" == "restore" && ! -f "$PROFILE_ENV" ]]; then
  echo "❌ profile.env not found at $PROFILE_ENV"
  exit 1
fi

if [[ "$MODE" == "restore" ]]; then
  echo "📄 Loading profile: $PROFILE_ENV"
  # shellcheck source=/dev/null
  source "$PROFILE_ENV"
fi

echo "🔧 Mode: $MODE"
echo "📁 Working in: $CONFIG_SRC"

find "$CONFIG_SRC" -type f | while read -r file; do
  rel_path="${file#$CONFIG_SRC/}"

  if [[ "$MODE" == "redact" ]]; then
    if grep -qE "(email =|signingkey =|name =)" "$file"; then
      echo "🛡️  Redacting $rel_path"
      tmp="$(mktemp)"
      sed -f "$PATTERNS_FILE" "$file" > "$tmp"
      mv "$tmp" "$file"
    fi
  else
    echo "🔁 Restoring $rel_path"
    tmp="$(mktemp)"
    content="$(cat "$file")"
    content="${content//\{\{EMAIL\}\}/$EMAIL}"
    content="${content//\{\{FIRST_NAME\}\}/$FIRST_NAME}"
    content="${content//\{\{LAST_NAME\}\}/$LAST_NAME}"
    content="${content//\{\{GPG_KEY_ID\}\}/$GPG_KEY_ID}"
    echo "$content" > "$tmp"
    mv "$tmp" "$file"
  fi
done

echo "✅ Done: $MODE complete."