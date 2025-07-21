#!/usr/bin/env bash
# 🔄 rollback-today — Roll back commits made since 8pm MDT today

set -euo pipefail
cd "$(dirname "$0")/.."

echo -e "\n🔄  \033[1;34mChecking for commits made since 8pm MDT today...\033[0m"

# Get today's date and 8pm MDT time
TODAY_8PM="$(date '+%Y-%m-%d') 20:00"

# Find commits since 8pm today
COMMITS_SINCE_8PM=$(git log --oneline --since="$TODAY_8PM" --format="%H")

if [ -z "$COMMITS_SINCE_8PM" ]; then
  echo "ℹ️  No commits found since 8pm MDT today"
  exit 0
fi

echo -e "\n📋  \033[1;33mCommits to be rolled back:\033[0m"
git log --oneline --since="$TODAY_8PM"

# Find the commit just before 8pm today
LAST_GOOD_COMMIT=$(git log --until="$TODAY_8PM" --format="%H" -1)

if [ -z "$LAST_GOOD_COMMIT" ]; then
  echo -e "\n❌  \033[1;31mError: Could not find a commit before 8pm today\033[0m"
  exit 1
fi

echo -e "\n🎯  \033[1;34mWill reset to commit:\033[0m"
git log --oneline -1 "$LAST_GOOD_COMMIT"

# Confirmation prompt
echo -e "\n⚠️  \033[1;33mThis will permanently remove the above commits. Continue? (y/N)\033[0m"
read -r response

if [[ "$response" =~ ^[Yy]$ ]]; then
  echo -e "\n🔄  \033[1;34mRolling back commits...\033[0m"
  
  # Reset to the last good commit
  git reset --hard "$LAST_GOOD_COMMIT"
  
  # Force push to update remote (be careful!)
  echo -e "\n🚀  \033[1;34mForce pushing to remote...\033[0m"
  echo -e "⚠️  \033[1;33mThis will overwrite remote history. Continue? (y/N)\033[0m"
  read -r push_response
  
  if [[ "$push_response" =~ ^[Yy]$ ]]; then
    git push --force-with-lease origin main
    echo -e "\n✅  \033[1;32mRollback complete!\033[0m"
  else
    echo -e "\n⏭️  \033[1;33mLocal rollback complete, but remote not updated\033[0m"
    echo "   Run 'git push --force-with-lease origin main' manually if needed"
  fi
else
  echo -e "\n⏭️  \033[1;33mRollback cancelled\033[0m"
fi