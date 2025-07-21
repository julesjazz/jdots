#!/usr/bin/env bash
set -euo pipefail

SNAPSHOT_FILE="$HOME/.config/scripts/temp/config_snapshot"
CONFIG_DIR="$HOME/.config"

# Ensure temp directory exists
mkdir -p "$(dirname "$SNAPSHOT_FILE")"

# Get current top-level entries (files and dirs) in ~/.config
current_list=$(find "$CONFIG_DIR" -mindepth 1 -maxdepth 1 -exec basename {} \; | sort)

# If snapshot exists, compare it
if [[ -f "$SNAPSHOT_FILE" ]]; then
    previous_list=$(sort "$SNAPSHOT_FILE")

    echo "🔍 Comparing ~/.config contents to previous snapshot..."
    diff_output=$(diff <(echo "$previous_list") <(echo "$current_list") || true)

    if [[ -n "$diff_output" ]]; then
        echo "🔄 Changes since last snapshot:"
        echo "$diff_output" | grep '^[<>]' | sed 's/^< /🗑️ Removed: /; s/^> /➕ Added: /'
    else
        echo "✅ No changes detected in ~/.config"
    fi
else
    echo "📦 No previous snapshot found. Creating initial snapshot."
fi

# Save new snapshot
echo "$current_list" > "$SNAPSHOT_FILE"