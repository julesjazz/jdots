#!/usr/bin/env bash
set -euo pipefail

# setup-venv.sh for new deploys
# this should exist in dotfilerepo/scripts

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENV_DIR="$DOTFILES_ROOT/.venv"

echo "📦 Setting up Python virtual environment in $VENV_DIR"
python3 -m venv "$VENV_DIR"

echo "🐍 Activating virtualenv"
source "$VENV_DIR/bin/activate"

echo "⬇️ Installing Ansible"
pip install --upgrade pip
pip install ansible

echo "✅ Virtual environment ready. To activate later, run:"
echo "    source $VENV_DIR/bin/activate"