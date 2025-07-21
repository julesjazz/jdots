#!/usr/bin/env bash
set -euo pipefail

# === Help ===
usage() {
  cat <<EOF
Usage: obsidian-sync [--dry-run]

Sync filtered config and templates from one Obsidian vault to another.
Example actual-run usage:
(Paths relative to ~/.config)
make obsidian-sync
  Enter source vault path (absolute or relative path): ./obsidian/professional 
  Enter destination vault path (absolute or relative path): ./obsidian/personal 

Options:
  --dry-run   Show what would be copied, without making changes
EOF
  exit 1
}

# === Defaults ===
DRY_RUN=""
VAULTS_DIR="$HOME/.config/obsidian"

# === Parse Args ===
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN="--dry-run"
      shift
      ;;
    -h|--help)
      usage
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      ;;
  esac
done

# === Prompt Vault Paths ===
prompt_vault_path() {
  local prompt="$1"
  local varname="$2"

  echo -n "$prompt (absolute or relative path): "
  read -r path
  path="$(realpath "$path")"

  if [[ ! -d "$path/.obsidian" ]]; then
    echo "Error: '$path' is not a valid vault (missing .obsidian/)" >&2
    exit 1
  fi

  eval "$varname=\"$path\""
}

# === Sync Functions ===

sync_obsidian_config() {
  echo "→ Syncing .obsidian config..."
  rsync -av $DRY_RUN \
    --exclude='app.json' \
    --exclude='backlink.json' \
    --exclude='types.json' \
    --exclude='daily-notes.json' \
    "$SRC_VAULT/.obsidian/" "$DST_VAULT/.obsidian/"
}

sync_templates_only() {
  echo "→ Syncing assets/templates..."
  mkdir -p "$DST_VAULT/assets/templates"
  rsync -av $DRY_RUN \
    --include='boards/' \
    --include='drawings/' \
    --include='journal/' \
    --include='vault/' \
    --include='assets/templates/***' \
    --include='assets/styles/***' \
    --include='.obsidian/plugins/' \
    --include='.obsidian/community-plugins.json' \
    --include='.obsidian/hotkeys.json' \
    --exclude='*.md' \
    --exclude='assets/attachments/***' \
    --exclude='*' \
    "$SRC_VAULT/" "$DST_VAULT/"
}

sync_folder_structure() {
  echo "→ Mirroring folder structure..."
  find "$SRC_VAULT" -type d \
    ! -path "$SRC_VAULT/assets/attachments*" \
    ! -path "$SRC_VAULT/assets/templates*" \
    ! -path "$SRC_VAULT/.obsidian*" \
    | while read -r dir; do
        rel="${dir#$SRC_VAULT/}"
        mkdir -p "$DST_VAULT/$rel"
      done
}

# === Main ===

main() {
  prompt_vault_path "Enter source vault path" SRC_VAULT
  prompt_vault_path "Enter destination vault path" DST_VAULT

  echo "--- Syncing from $SRC_VAULT to $DST_VAULT ---"
  [[ -n "$DRY_RUN" ]] && echo "⚠️  Dry run mode enabled — no changes will be made."

  sync_obsidian_config
  sync_templates_only
  sync_folder_structure

  echo "✅ Sync complete."
}

main