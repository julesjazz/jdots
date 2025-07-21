# scripts/pkgs/pm-new-install.sh

#!/usr/bin/env bash
set -euo pipefail

echo "📦 Running new system package setup"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PROFILE_DIR="$DOTFILES_ROOT/profiles"
PROFILE_ENV="$DOTFILES_ROOT/profile.env"
PM_MANAGER="$SCRIPT_DIR/pm-manager.sh"

if [[ ! -f "$PROFILE_ENV" ]]; then
  echo "❌ profile.env not found!"
  exit 1
fi

# shellcheck disable=SC1090
source "$PROFILE_ENV"

echo "🔍 Profile loaded. Proceeding with package setup..."
bash "$PM_MANAGER" install