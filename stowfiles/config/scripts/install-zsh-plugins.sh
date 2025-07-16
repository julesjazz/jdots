#!/usr/bin/env bash
# 🔌 install-zsh-plugins — Install ZSH plugins to ~/.config/zsh/plugins

set -euo pipefail

# Ensure we're using bash for associative arrays
if [ -z "${BASH_VERSION:-}" ]; then
  echo "❌ This script requires bash, not sh or zsh"
  exit 1
fi

echo -e "\n🔌  \033[1;34mInstalling ZSH plugins...\033[0m"

PLUGINS_DIR="$HOME/.config/zsh/plugins"
mkdir -p "$PLUGINS_DIR"

# Plugin repositories (plugin_name:repo_url)
PLUGINS=(
  "zsh-defer:https://github.com/romkatv/zsh-defer.git"
  "zsh-you-should-use:https://github.com/MichaelAquilina/zsh-you-should-use.git"
  "zsh-safe-rm:https://github.com/mattmc3/zsh-safe-rm.git"
  "colored-man-pages:https://github.com/ael-code/zsh-colored-man-pages.git"
  "git-open:https://github.com/paulirish/git-open.git"
  "forgit:https://github.com/wfxr/forgit.git"
  "z:https://github.com/rupa/z.git"
  "zsh-history-substring-search:https://github.com/zsh-users/zsh-history-substring-search.git"
  "zsh-syntax-highlighting:https://github.com/zsh-users/zsh-syntax-highlighting.git"
  "zsh-autocomplete:https://github.com/marlonrichert/zsh-autocomplete.git"
)

cd "$PLUGINS_DIR"

for entry in "${PLUGINS[@]}"; do
  plugin="${entry%%:*}"
  repo_url="${entry#*:}"
  
  if [[ -d "$plugin" ]]; then
    echo "🔄  Updating $plugin..."
    cd "$plugin"
    git pull --quiet
    cd ..
  else
    echo "📥  Installing $plugin..."
    git clone --quiet --depth=1 "$repo_url" "$plugin"
  fi
done

echo -e "\n✅  \033[1;32mZSH plugins installation complete!\033[0m"
echo -e "\n💡  \033[1;33mNext steps:\033[0m"
echo "  1. Restart your shell or run: source ~/.zshrc"
echo "  2. Plugins will be loaded automatically"

echo -e "\n📋  \033[1;34mInstalled plugins:\033[0m"
for entry in "${PLUGINS[@]}"; do
  plugin="${entry%%:*}"
  if [[ -d "$plugin" ]]; then
    echo "  ✅ $plugin"
  else
    echo "  ❌ $plugin (failed to install)"
  fi
done