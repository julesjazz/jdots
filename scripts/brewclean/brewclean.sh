#!/bin/bash

# Brew Cleanup Script
# This script performs a comprehensive cleanup of Homebrew

echo "🧹 Starting Homebrew cleanup..."

# Show disk usage before cleanup
echo "💿 Disk usage before cleanup:"
du -sh $(brew --prefix) 2>/dev/null || echo "Could not determine Homebrew disk usage"

# Update Homebrew
echo "📦 Updating Homebrew..."
brew update

# Upgrade all packages
echo "⬆️  Upgrading all packages..."
brew upgrade

# Clean up old versions
echo "🗑️  Cleaning up old versions..."
brew cleanup

# Remove orphaned dependencies
echo "🔍 Removing orphaned dependencies..."
brew autoremove

# Clean up cache
echo "💾 Cleaning cache..."
brew cleanup --prune=all

# Check for issues
echo "🔧 Checking for issues..."
brew doctor

# Show disk usage after cleanup
echo "💿 Disk usage after cleanup:"
du -sh $(brew --prefix) 2>/dev/null || echo "Could not determine Homebrew disk usage"

# Show what would be cleaned up (dry run)
echo "🗑️  Space that could be freed with additional cleanup:"
brew cleanup --dry-run

# Generate brew list
echo "📋 Generating brew list..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BREW_LIST_PATH="$SCRIPT_DIR/brewlist.txt"
CURRENT_DATE=$(date)

# Get current brew lists
CURRENT_FORMULAS=$(brew list --formula | sort)
CURRENT_CASKS=$(brew list --cask | sort)

# Check if previous brew list exists
if [[ -f "$BREW_LIST_PATH" ]]; then
    echo "📊 Comparing with previous brew list..."
    
    # Extract previous formulas and casks
    PREVIOUS_FORMULAS=$(awk '/^# Brew formulas/,/^# Brew Casks/ {if ($0 !~ /^#/ && NF > 0) print $1}' "$BREW_LIST_PATH" | sort)
    PREVIOUS_CASKS=$(awk '/^# Brew Casks/,/^# Generated on:/ {if ($0 !~ /^#/ && NF > 0) print $1}' "$BREW_LIST_PATH" | sort)
    
    # Find added and removed items
    ADDED_FORMULAS=$(comm -13 <(echo "$PREVIOUS_FORMULAS") <(echo "$CURRENT_FORMULAS"))
    REMOVED_FORMULAS=$(comm -23 <(echo "$PREVIOUS_FORMULAS") <(echo "$CURRENT_FORMULAS"))
    ADDED_CASKS=$(comm -13 <(echo "$PREVIOUS_CASKS") <(echo "$CURRENT_CASKS"))
    REMOVED_CASKS=$(comm -23 <(echo "$PREVIOUS_CASKS") <(echo "$CURRENT_CASKS"))
    
    # Create changelog entry
    {
        echo "# Brew Cleanup - $CURRENT_DATE"
        echo ""
        
        if [[ -n "$ADDED_FORMULAS" ]]; then
            echo "## Added Formulas"
            echo "$ADDED_FORMULAS" | sed 's/^/- /'
            echo ""
        fi
        
        if [[ -n "$REMOVED_FORMULAS" ]]; then
            echo "## Removed Formulas"
            echo "$REMOVED_FORMULAS" | sed 's/^/- /'
            echo ""
        fi
        
        if [[ -n "$ADDED_CASKS" ]]; then
            echo "## Added Casks"
            echo "$ADDED_CASKS" | sed 's/^/- /'
            echo ""
        fi
        
        if [[ -n "$REMOVED_CASKS" ]]; then
            echo "## Removed Casks"
            echo "$REMOVED_CASKS" | sed 's/^/- /'
            echo ""
        fi
        
        if [[ -z "$ADDED_FORMULAS$REMOVED_FORMULAS$ADDED_CASKS$REMOVED_CASKS" ]]; then
            echo "No changes detected since last run."
            echo ""
        fi
        
        echo "---"
        echo ""
        
        # Append the full current list
        cat "$BREW_LIST_PATH"
        
    } > "${BREW_LIST_PATH}.new"
    
    mv "${BREW_LIST_PATH}.new" "$BREW_LIST_PATH"
    
else
    # First run - create initial list
    {
        echo "# Brew Cleanup - $CURRENT_DATE"
        echo ""
        echo "## Initial Brew List"
        echo ""
        echo "# Brew formulas ----------------------------------------"
        echo ""
        echo "$CURRENT_FORMULAS" | column -c 1
        echo ""
        echo "# Brew Casks ----------------------------------------"
        echo ""
        echo "$CURRENT_CASKS" | column -c 1
        echo ""
        echo "# Generated on: $CURRENT_DATE"
    } > "$BREW_LIST_PATH"
fi

echo "✅ Homebrew cleanup complete!"
echo "📄 Brew list saved to: $(realpath "$BREW_LIST_PATH")" 