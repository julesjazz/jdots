#!/bin/bash

echo "🔄 Updating all asdf tools to their latest stable versions..."

cd ~ || exit 1  # Ensure we're at home so .tool-versions is global

for plugin in $(asdf plugin list); do
  echo "🔍 Checking latest version for $plugin..."

  # Get the latest stable version (skip pre-releases or weird formats)
  latest=$(asdf latest "$plugin" 2>/dev/null)

  if [ -z "$latest" ]; then
    echo "❌ Could not determine latest version for $plugin. Skipping."
    continue
  fi

  # Check if it's already installed
  if ! asdf list "$plugin" | grep -q "$latest"; then
    echo "⬇️ Installing $plugin $latest..."
    asdf install "$plugin" "$latest"
  else
    echo "✅ $plugin $latest already installed."
  fi

  echo "📌 Setting $plugin globally to $latest..."
  asdf set "$plugin" "$latest"
done

echo "🎉 All tools are updated to latest stable versions!"
echo "📋 Check with: asdf current"
