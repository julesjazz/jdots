#!/usr/bin/env bash
set -euo pipefail

# ────────────────────────────────────────────────────────────────────────
# 🧩 pm-manager.sh — Package Manager Install & Cleanup (macOS-first)
# - Loads config from profile.env
# - Aggregates system packages from active profiles
# - Filters out asdf-managed tools
# - Installs missing packages
# - Runs basic cleanup (brew doctor/cleanup etc.)
# ────────────────────────────────────────────────────────────────────────

# Define paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PROFILE_ENV="$DOTFILES_ROOT/profile.env"
PROFILE_DIR="$DOTFILES_ROOT/profiles"

# Load profile.env
if [[ ! -f "$PROFILE_ENV" ]]; then
  echo "❌ profile.env not found at $PROFILE_ENV"
  exit 1
fi
source "$PROFILE_ENV"

: "${OS_TYPE:?Missing OS_TYPE in profile.env}"
: "${PKG_MANAGER:?Missing PKG_MANAGER in profile.env}"
: "${ACTIVE_PROFILES:?Missing ACTIVE_PROFILES in profile.env}"

echo "🌐 OS: $OS_TYPE | 📦 Package Manager: $PKG_MANAGER"
echo "📁 Active Profiles: $ACTIVE_PROFILES"

# ────────────────────────────────────────────────────────────────────────
# Aggregate system packages
echo "📦 Collecting package lists from profiles..."
ALL_PKGS=()
ASDF_TOOLS=()

IFS=',' read -ra PROFILE_LIST <<< "$ACTIVE_PROFILES"
for profile in "${PROFILE_LIST[@]}"; do
  file="$PROFILE_DIR/${profile}.yml"
  [[ -f "$file" ]] || { echo "⚠️  Profile not found: $file"; continue; }

  echo "🔍 Reading profile: $profile"

  # Extract packages for current package manager and OS type
  mapfile -t pkgs < <(yq e ".packages.${PKG_MANAGER}.${OS_TYPE}[]" "$file" 2>/dev/null || true)
  mapfile -t common < <(yq e ".packages.${PKG_MANAGER}.common[]" "$file" 2>/dev/null || true)
  ALL_PKGS+=("${pkgs[@]}" "${common[@]}")

  # Extract asdf tools for filtering
  mapfile -t asdf_raw < <(yq e '.asdf[]' "$file" 2>/dev/null || true)
  for tool in "${asdf_raw[@]}"; do
    ASDF_TOOLS+=("$(cut -d@ -f1 <<< "$tool")")
  done
done

# Deduplicate and filter out asdf tools
UNIQUE_PKGS=($(printf "%s\n" "${ALL_PKGS[@]}" | sort -u))
FILTERED_PKGS=()

for pkg in "${UNIQUE_PKGS[@]}"; do
  if [[ ! " ${ASDF_TOOLS[*]} " =~ " ${pkg} " ]]; then
    FILTERED_PKGS+=("$pkg")
  else
    echo "🛑 Skipping $pkg (managed by asdf)"
  fi
done

# ────────────────────────────────────────────────────────────────────────
# Prompt user for confirmation
if [[ "${#FILTERED_PKGS[@]}" -eq 0 ]]; then
  echo "✅ No system packages to install."
else
  echo ""
  echo "📦 The following packages will be installed:"
  printf ' - %s\n' "${FILTERED_PKGS[@]}"

  read -t 20 -r -p "⏳ Proceed with installation? [y/N] " confirm || true
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "❌ Aborted."
    exit 0
  fi

  # ────────────────────────────────────────────────────────────────────────
  echo "🚀 Installing system packages..."
  case "$PKG_MANAGER" in
    brew)
      brew install "${FILTERED_PKGS[@]}"
      brew doctor
      brew cleanup
      ;;
    apt)
      sudo apt update
      sudo apt install -y "${FILTERED_PKGS[@]}"
      sudo apt autoremove -y
      ;;
    dnf)
      sudo dnf install -y "${FILTERED_PKGS[@]}"
      sudo dnf autoremove -y
      ;;
    *)
      echo "❌ Unsupported package manager: $PKG_MANAGER"
      exit 1
      ;;
  esac
fi

echo "✅ Package manager tasks complete."