#!/usr/bin/env bash
# 📦 stow-backup — Back up config + select home dotfiles to jdots/stowfiles

set -euo pipefail
cd "$(dirname "$0")/.."  # move to jdots root

echo -e "\n🔄  \033[1;34mBacking up dotfiles into jdots/stowfiles...\033[0m"

# Run security audit on source directories before backup
echo -e "\n🔒  \033[1;34mRunning security audit on source directories...\033[0m"
./scripts/security-audit.sh --source-only

STOW_DIR="stowfiles"

sanitize_files() {
  echo "🧹  Sanitizing email addresses and sensitive info..."
  
  # Sanitize git config files
  for gitconfig in "$STOW_DIR/config/git/gitconfig" "$STOW_DIR/home/.gitconfig"; do
    if [[ -f "$gitconfig" ]]; then
      echo "  📧  Sanitizing $gitconfig"
      # Replace email addresses with placeholder
      sed -i.bak 's/email = [^@]*@[^[:space:]]*/email = user@domain.com/g' "$gitconfig"
      # Replace real names with placeholder
      sed -i.bak 's/name = .*/name = Your Name/g' "$gitconfig"
      # Fix hardcoded paths to use portable config paths
      sed -i.bak 's|excludesfile = /Users/[^/]*/\.gitignore_global|excludesfile = ~/.config/git/gitignore|g' "$gitconfig"
      sed -i.bak 's|excludesfile = ~/.gitignore_global|excludesfile = ~/.config/git/gitignore|g' "$gitconfig"
      # Remove backup file
      rm -f "$gitconfig.bak"
    fi
  done
  
  # Sanitize hardcoded user paths in all config files
  echo "  🏠  Sanitizing hardcoded user paths..."
  find "$STOW_DIR" -type f \( -name "*.config" -o -name "config" -o -name "*.conf" -o -name "*.toml" -o -name "*.yaml" -o -name "*.yml" \) -exec grep -l "/Users/[^/]*" {} \; 2>/dev/null | while read -r file; do
    echo "    🏠  Sanitizing paths in $file"
    sed -i.bak 's|/Users/[^/]*/|/Users/username/|g' "$file"
    rm -f "$file.bak"
  done
  
  # Sanitize any other config files that might contain email addresses
  find "$STOW_DIR" -type f \( -name "*.conf" -o -name "*.config" -o -name "*.json" -o -name "*.yaml" -o -name "*.yml" \) -exec grep -l "@" {} \; 2>/dev/null | while read -r file; do
    echo "  📧  Sanitizing emails in $file"
    sed -i.bak 's/[a-zA-Z0-9._%+-]*@[a-zA-Z0-9.-]*\.[a-zA-Z]{2,}/user@domain.com/g' "$file"
    rm -f "$file.bak"
  done
}

backup_config() {
  local src="$HOME/.config"
  local dest="$STOW_DIR/config"
  mkdir -p "$dest"

  # Files that should go in config-root (directly in ~/.config)
  local config_root_files=(".aliases" ".gitignore" ".stow-local-ignore" "Makefile")
  mkdir -p "$dest/config-root"
  
  for file in "${config_root_files[@]}"; do
    if [[ -f "$src/$file" ]]; then
      echo "📝  Backing up $file → $dest/config-root/"
      rsync -a --exclude-from=.rsyncignore \
        "$src/$file" "$dest/config-root/"
    fi
  done

  # Backup directories normally
  for dir in "$src"/*/; do
    [[ -d "$dir" ]] || continue
    name="$(basename "$dir")"

    echo "📝  Backing up $name → $dest/$name"
    mkdir -p "$dest/$name"

    rsync -a --delete \
      --exclude-from=.rsyncignore \
      "$dir" "$dest/$name/"
  done
}

backup_home() {
  local dest="$STOW_DIR/home"
  mkdir -p "$dest"

  for file in .zshrc .gitconfig .bashrc .asdfrc; do
    src_file="$HOME/$file"
    if [[ -f "$src_file" ]]; then
      echo "📝  Backing up $file → $dest/"
      rsync -a --delete \
        --exclude-from=.rsyncignore \
        "$src_file" "$dest/"
    else
      echo "⚠️  Skipping $file — not found in \$HOME"
    fi
  done
}

backup_config
backup_home

# Sanitize sensitive information
echo -e "\n🔒  \033[1;34mSanitizing sensitive information...\033[0m"
sanitize_files

echo -e "\n✅  \033[1;32mBackup complete!\033[0m"

# Git operations
echo -e "\n📝  \033[1;34mCommitting changes to git...\033[0m"

# Get truncated hostname (e.g., "fvmac" from "fvmac.local")
HOSTNAME=$(hostname | cut -d'.' -f1)
DATE=$(date '+%Y-%m-%d %H:%M')

# Check if there are changes to commit
if git diff --quiet && git diff --cached --quiet; then
  echo "ℹ️  No changes to commit"
else
  # Confirmation prompt with timeout
  echo -e "\n🤔  \033[1;33mCommit and push changes? (y/N) [20s timeout]\033[0m"
  if read -t 20 -r response; then
    if [[ "$response" =~ ^[Yy]$ ]]; then
      # Add all changes
      git add .
      
      # Commit with descriptive message
      COMMIT_MSG="backup: $HOSTNAME - $DATE"
      git commit -m "$COMMIT_MSG"
      
      echo "✅  Committed: $COMMIT_MSG"
      
      # Push to remote
      echo -e "\n🚀  \033[1;34mPushing to remote repository...\033[0m"
      if git push; then
        echo "✅  Successfully pushed to remote"
      else
        echo "⚠️  Push failed - check your git remote configuration"
      fi
    else
      echo "⏭️  Skipping git operations"
    fi
  else
    echo "⏰  Timeout - skipping git operations"
  fi
fi
