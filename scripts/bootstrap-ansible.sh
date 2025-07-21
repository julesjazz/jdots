#!/usr/bin/env bash
set -euo pipefail

echo "🔧 Bootstrapping Ansible and system prerequisites..."

OS="$(uname -s)"

# ─────────────────────────────────────────────────────────────
# 🍎 macOS Setup
# ─────────────────────────────────────────────────────────────
if [[ "$OS" == "Darwin" ]]; then
  echo "🍎 Detected macOS"

  # Install Xcode Command Line Tools if not present
  if ! xcode-select -p &>/dev/null; then
    echo "🛠️  Installing Xcode Command Line Tools..."
    xcode-select --install
    echo "⏳ Waiting for installation to complete..."
    until xcode-select -p &>/dev/null; do sleep 5; done
    echo "✅ Xcode tools installed."
  else
    echo "✅ Xcode tools already installed."
  fi

  # Install Homebrew if not found
  if ! command -v brew &>/dev/null; then
    echo "🍺 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    echo "✅ Homebrew already installed."
  fi
fi

# ─────────────────────────────────────────────────────────────
# 🐧 Linux Setup
# ─────────────────────────────────────────────────────────────
if [[ "$OS" == "Linux" ]]; then
  echo "🐧 Detected Linux"

  # Detect distro
  if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    DISTRO_ID="${ID:-unknown}"
  else
    DISTRO_ID="unknown"
  fi

  echo "📦 Distro detected: $DISTRO_ID"
# install core reqs for ansbile, to be moved to asdf/mise package manager later
  case "$DISTRO_ID" in
    debian|ubuntu)
      echo "📥 Updating apt and installing prerequisites..."
      sudo apt update
      sudo apt install -y python3-pip python3-venv curl git build-essential
      ;;

    fedora|rhel)
      echo "📥 Installing dnf/yum prerequisites..."
      sudo dnf install -y python3-pip python3-virtualenv curl git make gcc || \
      sudo yum install -y python3-pip python3-virtualenv curl git make gcc
      ;;

    *)
      echo "⚠️ Unsupported Linux distro: $DISTRO_ID"
      ;;
  esac
fi

# ─────────────────────────────────────────────────────────────
# 🚀 Ansible Setup (Common to All)
# ─────────────────────────────────────────────────────────────
echo "🧪 Checking Ansible..."
if ! command -v ansible &>/dev/null; then
  echo "❌ Ansible not found."

  # Recommend user-level install (adjustable)
  echo "📥 Installing Ansible via pipx (recommended)..."
  python3 -m pip install --user pipx
  python3 -m pipx ensurepath
  pipx install ansible
  echo "✅ Ansible installed."
else
  echo "✅ Ansible is already installed."
fi

echo "🎉 Done bootstrapping system tools."