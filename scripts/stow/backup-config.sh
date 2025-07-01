#!/bin/bash

# Backup .config files to stow packages
# This script copies configuration files from ~/.config to stow packages
# while excluding cache files, logs, and temporary files

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
STOW_DIR="$PROJECT_ROOT/stow-packages"
CONFIG_DIR="$HOME/.config"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Create stow directory if it doesn't exist
mkdir -p "$STOW_DIR"

# Function to copy config files for a specific application
copy_config() {
    local app_name="$1"
    local source_dir="$CONFIG_DIR/$app_name"
    local config_target_dir="$STOW_DIR/config/$app_name"
    local home_target_dir="$STOW_DIR/home"
    
    if [[ ! -d "$source_dir" ]]; then
        log_warning "Directory $source_dir does not exist, skipping $app_name"
        return 0
    fi
    
    log_info "Backing up $app_name configuration..."
    
    # Create target directories
    mkdir -p "$config_target_dir"
    mkdir -p "$home_target_dir"
    
    # Copy files based on application
    case "$app_name" in
        "zsh")
            # Copy zsh config files to .config
            cp "$source_dir/.zshrc" "$config_target_dir/" 2>/dev/null || log_warning "No .zshrc found in config"
            # Also copy plugins directory if it exists, excluding git directories
            if [[ -d "$source_dir/plugins" ]]; then
                # Use rsync to exclude git directories and other unwanted files
                if command -v rsync >/dev/null 2>&1; then
                    rsync -av --exclude='.git' --exclude='*.log' --exclude='*.tmp' --exclude='*.cache' "$source_dir/plugins/" "$config_target_dir/plugins/"
                else
                    # Fallback to cp with find to exclude git directories
                    find "$source_dir/plugins" -type d -name ".git" -exec rm -rf {} + 2>/dev/null || true
                    cp -r "$source_dir/plugins" "$config_target_dir/"
                fi
            fi
            # Note: history file is excluded for privacy/security reasons
            # Copy home directory .zshrc
            cp "$HOME/.zshrc" "$home_target_dir/" 2>/dev/null || log_warning "No ~/.zshrc found"
            ;;
        "bash")
            # Copy bash config files to .config
            cp "$source_dir/.bashrc" "$config_target_dir/" 2>/dev/null || log_warning "No .bashrc found in config"
            # Copy home directory .bashrc
            cp "$HOME/.bashrc" "$home_target_dir/" 2>/dev/null || log_warning "No ~/.bashrc found"
            ;;
        "fish")
            # Copy fish config files, exclude cache files
            cp "$source_dir/config.fish" "$config_target_dir/" 2>/dev/null || log_warning "No config.fish found"
            cp "$source_dir/fish_plugins" "$config_target_dir/" 2>/dev/null || log_warning "No fish_plugins found"
            if [[ -d "$source_dir/conf.d" ]]; then
                cp -r "$source_dir/conf.d" "$config_target_dir/"
            fi
            if [[ -d "$source_dir/functions" ]]; then
                cp -r "$source_dir/functions" "$config_target_dir/"
            fi
            # Exclude: fish_variables, themes/, completions/
            ;;
        "nvim")
            # Copy nvim config files, exclude cache and logs
            cp "$source_dir/init.lua" "$config_target_dir/" 2>/dev/null || log_warning "No init.lua found"
            if [[ -d "$source_dir/lua" ]]; then
                cp -r "$source_dir/lua" "$config_target_dir/"
            fi
            cp "$source_dir/stylua.toml" "$config_target_dir/" 2>/dev/null || log_warning "No stylua.toml found"
            # Exclude: lazyvim.json, .neoconf.json, .gitignore, LICENSE, README.md
            ;;
        "powershell")
            # Copy PowerShell config files
            cp "$source_dir/profile.ps1" "$config_target_dir/" 2>/dev/null || log_warning "No profile.ps1 found"
            cp "$source_dir/Sync-History.ps1" "$config_target_dir/" 2>/dev/null || log_warning "No Sync-History.ps1 found"
            ;;
        "gitlab")
            # Copy gitlab config files
            cp "$source_dir/config.yml" "$config_target_dir/" 2>/dev/null || log_warning "No config.yml found"
            ;;

        "ghostty")
            # Copy ghostty config files
            cp "$source_dir/config" "$config_target_dir/" 2>/dev/null || log_warning "No config found"
            ;;
        *)
            log_warning "Unknown application: $app_name"
            return 1
            ;;
    esac
    
    log_success "Backed up $app_name configuration"
}

# Function to copy global config files
copy_global_config() {
    local config_target_dir="$STOW_DIR/config"
    mkdir -p "$config_target_dir"
    
    log_info "Backing up global configuration files..."
    
    # Copy global config files
    cp "$CONFIG_DIR/.aliases" "$config_target_dir/" 2>/dev/null || log_warning "No .aliases found"
    cp "$CONFIG_DIR/starship.toml" "$config_target_dir/" 2>/dev/null || log_warning "No starship.toml found"
    
    log_success "Backed up global configuration files"
}

# Main backup process
main() {
    log_info "Starting .config backup to stow packages..."
    
    # Backup application-specific configs
    local apps=("zsh" "fish" "nvim" "bash" "powershell" "gitlab" "ghostty")
    
    for app in "${apps[@]}"; do
        copy_config "$app"
    done
    
    # Backup global config files
    copy_global_config
    
    log_success "Backup completed successfully!"
    log_info "Stow packages are ready in: $STOW_DIR"
    log_info "Run 'make stow-deploy' to deploy the configurations"
}

# Run main function
main "$@" 