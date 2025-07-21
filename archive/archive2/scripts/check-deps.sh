#!/usr/bin/env bash
set -euo pipefail

@echo "🔍 Detecting platform and suggesting install commands..."
@UNAME_S=$$(uname -s); \
if command -v brew >/dev/null; then \
    echo "🧰 Use Homebrew:"; \
    echo "run: 	brew install yq git curl gpg"; \
elif [ -f /etc/debian_version ]; then \
    echo "🧰 Use APT (Debian/Ubuntu):"; \
    echo "run:  sudo apt update && sudo apt install -y yq git curl gnupg"; \
elif [ -f /etc/redhat-release ]; then \
    echo "🧰 Use DNF (RHEL/Fedora):"; \
    echo "run:	sudo dnf install -y yq git curl gnupg2"; \
else \
    echo "❗ Unknown OS — please install 'yq', 'git', 'curl', and 'gpg' manually."; \
fi