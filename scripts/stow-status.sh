#!/usr/bin/env bash
# 📊 stow-status — List stow package status from jdots/stowfiles

set -euo pipefail
cd "$(dirname "$0")/.."

echo -e "\n🔍  \033[1;34mStow package status:\033[0m"

echo -e "\n🏠  Home packages:"
find stowfiles/home -mindepth 1 -maxdepth 1 -type d -exec basename {} \;

echo -e "\n🧾  Config packages:"
find stowfiles/config -mindepth 1 -maxdepth 1 -type d -exec basename {} \;

echo -e "\n✅  \033[1;32mStatus listed.\033[0m"