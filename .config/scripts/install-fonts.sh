#!/usr/bin/env bash
set -euo pipefail

FONT_SRC="$HOME/.config/assets/fonts"
FONT_DEST="$HOME/.local/share/fonts"

echo "→ Installing Comic Code fonts..."
mkdir -p "$FONT_DEST/ComicCode"
cp "$FONT_SRC/Comic Code/OTF/"*.otf "$FONT_DEST/ComicCode/"

echo "→ Installing Excalifont (web font)..."
mkdir -p "$FONT_DEST/Excalifont"
cp "$FONT_SRC/Excalifont/"*.woff2 "$FONT_DEST/Excalifont/"

echo "→ Refreshing font cache..."
fc-cache -fv

echo "✅ Fonts installed."