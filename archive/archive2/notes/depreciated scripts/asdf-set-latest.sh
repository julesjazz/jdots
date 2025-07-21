#!/bin/bash

# Update tool versions in ~ to latest STABLE available (not just installed) for all asdf plugins

set -euo pipefail

echo "📦 Setting latest stable (LTS) version globally for each asdf plugin..."

cd ~ || exit 1  # Ensure we are in home directory

for plugin in $(asdf plugin list); do
  echo "🔍 Fetching latest version for $plugin..."
  
  latest=$(asdf latest "$plugin" 2>/dev/null || true)

  if [ -z "$latest" ]; then
    echo "⚠️  Could not fetch latest version for $plugin. Skipping."
    continue
  fi

  echo "🔄 Installing $plugin $latest (if not already installed)..."
  if ! asdf list "$plugin" | grep -q "$latest"; then
    asdf install "$plugin" "$latest"
  fi

  echo "✅ Setting $plugin globally to $latest..."
  asdf set "$plugin" "$latest"
done

echo "🎉 Done! Verify with: asdf current"
