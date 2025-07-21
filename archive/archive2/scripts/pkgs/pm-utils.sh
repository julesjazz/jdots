#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# pm-utils.sh: Utility functions for package installation
# -----------------------------------------------------------------------------

# 🧰 Install CLI packages
install_package() {
  local pkg="$1"
  local pm="$2"

  case "$pm" in
    brew)
      if brew list --formula | grep -q "^$pkg\$"; then
        echo "✅ $pkg already installed (brew)"
      else
        echo "➕ Installing $pkg (brew)"
        brew install "$pkg"
      fi
      ;;
    apt)
      echo "⏳ APT support not implemented yet: $pkg"
      ;;
    dnf)
      echo "⏳ DNF support not implemented yet: $pkg"
      ;;
    *)
      echo "❌ Unknown package manager: $pm"
      ;;
  esac
}

# 🖥️ Install GUI (Cask) packages
install_gui_package() {
  local app="$1"
  local pm="$2"

  case "$pm" in
    brew)
      if brew list --cask | grep -q "^$app\$"; then
        echo "✅ $app already installed (cask)"
      else
        echo "🖥️ Installing $app (cask)"
        brew install --cask "$app"
      fi
      ;;
    apt|dnf)
      echo "⏳ GUI app install not supported yet for $pm: $app"
      ;;
    *)
      echo "❌ Unknown package manager: $pm"
      ;;
  esac
}