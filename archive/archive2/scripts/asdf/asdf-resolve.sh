#!/usr/bin/env bash
set -euo pipefail

# Script to resolve symbolic asdf versions and write to `asdf-resolved:` section in profile YAML files.
# Requirements: `yq` (https://github.com/mikefarah/yq)

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROFILE_DIR="${DOTFILES_ROOT}/profiles"

if ! command -v yq &> /dev/null; then
  echo "❌ 'yq' is required but not found. Install it via brew, apt, or download from GitHub."
  exit 1
fi

resolve_version() {
  local tool="$1"
  local version="$2"

  # Ensure plugin exists
  asdf plugin-add "$tool" &>/dev/null || true

  case "$version" in
    lts|latest)
      asdf latest "$tool" 2>/dev/null || echo "$version"
      ;;
    *)
      asdf latest "$tool" "$version" 2>/dev/null || echo "$version"
      ;;
  esac
}

for file in "$PROFILE_DIR"/*.yml; do
  echo "🔍 Processing: $file"

  mapfile -t tools < <(yq e '.asdf[]' "$file")
  resolved_entries=()

  for entry in "${tools[@]}"; do
    tool="${entry%@*}"
    version="${entry#*@}"
    resolved=$(resolve_version "$tool" "$version")

    if [[ "$resolved" == *"No compatible"* || -z "$resolved" ]]; then
      echo "⚠️  Could not resolve $tool@$version — skipping"
      continue
    fi

    echo "  ↪ $tool@$version → $resolved"
    resolved_entries+=("  - $tool@$resolved")
  done

  # Remove any existing 'asdf-resolved' section
  yq -i 'del(."asdf-resolved")' "$file"

  # Append updated 'asdf-resolved' section
  {
    echo ""
    echo "asdf-resolved:"
    for entry in "${resolved_entries[@]}"; do
      echo "$entry"
    done
  } >> "$file"

  echo "✅ Updated $file"
done
