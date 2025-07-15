#!/bin/bash

# tealdeer setup script for dotfiles integration
# This script creates symlinks so tealdeer uses ~/.config/tldr for config, cache, and pages
# tealdeer is a rust implementation of tldr

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR"
TEALDEER_CONFIG_DIR="$HOME/Library/Application Support/tealdeer"
TEALDEER_CACHE_DIR="$HOME/Library/Caches/tealdeer"

echo "Setting up tealdeer symlinks for dotfiles integration..."

# Create necessary directories
echo "Creating directories..."
mkdir -p "$CONFIG_DIR/cache"
mkdir -p "$CONFIG_DIR/pages"
mkdir -p "$TEALDEER_CONFIG_DIR"
mkdir -p "$(dirname "$TEALDEER_CACHE_DIR")"

# Backup existing config if it exists and isn't already a symlink
if [[ -f "$TEALDEER_CONFIG_DIR/config.toml" && ! -L "$TEALDEER_CONFIG_DIR/config.toml" ]]; then
    echo "Backing up existing config..."
    cp "$TEALDEER_CONFIG_DIR/config.toml" "$CONFIG_DIR/config.toml.backup"
fi

# Backup existing cache if it exists and isn't already a symlink
if [[ -d "$TEALDEER_CACHE_DIR" && ! -L "$TEALDEER_CACHE_DIR" ]]; then
    echo "Backing up existing cache..."
    cp -r "$TEALDEER_CACHE_DIR" "$CONFIG_DIR/cache.backup"
fi

# Create symlinks
echo "Creating symlinks..."

# Config symlink
if [[ -L "$TEALDEER_CONFIG_DIR/config.toml" ]]; then
    rm "$TEALDEER_CONFIG_DIR/config.toml"
fi
ln -sf "$CONFIG_DIR/config.toml" "$TEALDEER_CONFIG_DIR/config.toml"
echo "  ✓ Config symlink created"

# Cache symlink
if [[ -L "$TEALDEER_CACHE_DIR" ]]; then
    rm "$TEALDEER_CACHE_DIR"
fi
ln -sfn "$CONFIG_DIR/cache" "$TEALDEER_CACHE_DIR"
echo "  ✓ Cache symlink created"

# Custom pages symlink
if [[ -L "$TEALDEER_CONFIG_DIR/pages" ]]; then
    rm "$TEALDEER_CONFIG_DIR/pages"
fi
ln -sfn "$CONFIG_DIR/pages" "$TEALDEER_CONFIG_DIR/pages"
echo "  ✓ Custom pages symlink created"

# Verify setup
echo ""
echo "Verifying setup..."
if tldr --show-paths > /dev/null 2>&1; then
    echo "  ✓ tealdeer is working correctly"
    echo ""
    echo "tealdeer paths:"
    tldr --show-paths
else
    echo "  ✗ tealdeer is not working - please check installation"
    exit 1
fi

echo ""
echo "Setup complete! Your tealdeer configuration is now backed up in:"
echo "  Config: $CONFIG_DIR/config.toml"
echo "  Cache:  $CONFIG_DIR/cache/"
echo "  Pages:  $CONFIG_DIR/pages/"
echo ""
echo "You can now add $CONFIG_DIR to your dotfiles repository." 