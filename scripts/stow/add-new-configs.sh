#!/bin/bash

# Add new configuration directories to existing stow packages
# This script scans ~/.config for new directories and adds them to stow packages
# It will prompt for confirmation before adding each new directory

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

# Function to check if a directory should be ignored
should_ignore() {
    local dir_name="$1"
    
    # Directories to ignore
    local ignore_dirs=(
        "iterm2"           # Contains runtime data and sockets
        "cache"            # Cache directories
        "logs"             # Log directories
        "temp"             # Temporary directories
        "tmp"              # Temporary directories
        "sessions"         # Session files
        "undo"             # Undo files
        "swap"             # Swap files
        "backup"           # Backup files
        "spell"            # Spell files
        "netrwhist"        # Netrw history
        ".history"         # History files
        ".zcompdump"       # Zsh completion dump
        ".zsh_history"     # Zsh history
    )
    
    for ignore_dir in "${ignore_dirs[@]}"; do
        if [[ "$dir_name" == "$ignore_dir" ]]; then
            return 0  # Should ignore
        fi
    done
    
    return 1  # Should not ignore
}

# Function to check if a directory contains configuration files
has_config_files() {
    local dir_path="$1"
    
    # Look for common config file patterns
    local config_patterns=(
        "*.conf"
        "*.config"
        "*.json"
        "*.toml"
        "*.yaml"
        "*.yml"
        "*.ini"
        "*.cfg"
        "*.rc"
        "*.fish"
        "*.ps1"
        "*.lua"
        "*.vim"
        "*.gitignore"
        "Dockerfile"
        "Makefile"
        "README.md"
        "LICENSE"
    )
    
    for pattern in "${config_patterns[@]}"; do
        if find "$dir_path" -maxdepth 1 -name "$pattern" -type f | grep -q .; then
            return 0  # Has config files
        fi
    done
    
    # Check for subdirectories that might contain configs
    if find "$dir_path" -maxdepth 1 -type d | grep -q .; then
        return 0  # Has subdirectories
    fi
    
    return 1  # No config files
}

# Function to add a new configuration directory
add_new_config() {
    local dir_name="$1"
    local source_dir="$CONFIG_DIR/$dir_name"
    local config_target_dir="$STOW_DIR/config/$dir_name"
    local home_target_dir="$STOW_DIR/home"
    
    log_info "Adding new configuration: $dir_name"
    
    # Create target directories
    mkdir -p "$config_target_dir"
    mkdir -p "$home_target_dir"
    
    # Handle different application types
    case "$dir_name" in
        "zsh"|"bash")
            # Copy to .config
            cp -r "$source_dir"/* "$config_target_dir/" 2>/dev/null || log_warning "No files to copy for $dir_name .config"
            
            # Also copy home directory file if it exists
            local home_file="$HOME/.${dir_name}rc"
            if [[ -f "$home_file" ]]; then
                cp "$home_file" "$home_target_dir/"
                log_success "Added ~/.${dir_name}rc to home stow package"
            fi
            
            log_success "Added $dir_name configuration to stow packages"
            ;;
        *)
            # For other apps, just copy to .config
            cp -r "$source_dir"/* "$config_target_dir/" 2>/dev/null || log_warning "No files to copy for $dir_name"
            log_success "Added $dir_name configuration to stow package"
            ;;
    esac
}

# Function to prompt user for confirmation
confirm_add() {
    local dir_name="$1"
    local source_dir="$CONFIG_DIR/$dir_name"
    
    echo
    log_info "Found new configuration directory: $dir_name"
    echo "Location: $source_dir"
    
    # Show what's in the directory
    if [[ -d "$source_dir" ]]; then
        echo "Contents:"
        ls -la "$source_dir" | head -10
        if [[ $(ls -1 "$source_dir" | wc -l) -gt 10 ]]; then
            echo "... and $(($(ls -1 "$source_dir" | wc -l) - 10)) more items"
        fi
    fi
    
    echo
    read -p "Add this configuration to stow packages? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        return 0  # User confirmed
    else
        return 1  # User declined
    fi
}

# Main process to find and add new configs
main() {
    log_info "Scanning for new configuration directories..."
    
    # Check if stow directory exists
    if [[ ! -d "$STOW_DIR" ]]; then
        log_error "Stow directory does not exist: $STOW_DIR"
        log_error "Run 'make stow-backup' first to create stow packages"
        exit 1
    fi
    
    # Get list of existing stow packages (check config subdirectories)
    local existing_packages=()
    if [[ -d "$STOW_DIR/config" ]]; then
        while IFS= read -r -d '' package; do
            existing_packages+=("$(basename "$package")")
        done < <(find "$STOW_DIR/config" -maxdepth 1 -type d -print0)
    fi
    
    # Get list of directories in ~/.config
    local config_dirs=()
    if [[ -d "$CONFIG_DIR" ]]; then
        while IFS= read -r -d '' dir; do
            local dir_name="$(basename "$dir")"
            if [[ ! " ${existing_packages[*]} " =~ " ${dir_name} " ]]; then
                config_dirs+=("$dir_name")
            fi
        done < <(find "$CONFIG_DIR" -maxdepth 1 -type d -print0)
    fi
    
    if [[ ${#config_dirs[@]} -eq 0 ]]; then
        log_success "No new configuration directories found!"
        return 0
    fi
    
    log_info "Found ${#config_dirs[@]} new configuration directory(ies):"
    
    local added_count=0
    
    for dir_name in "${config_dirs[@]}"; do
        local source_dir="$CONFIG_DIR/$dir_name"
        
        # Skip if should be ignored
        if should_ignore "$dir_name"; then
            log_warning "Skipping $dir_name (ignored directory)"
            continue
        fi
        
        # Skip if no config files
        if ! has_config_files "$source_dir"; then
            log_warning "Skipping $dir_name (no configuration files found)"
            continue
        fi
        
        # Prompt user for confirmation
        if confirm_add "$dir_name"; then
            add_new_config "$dir_name"
            ((added_count++))
        else
            log_info "Skipped $dir_name (user declined)"
        fi
    done
    
    if [[ $added_count -gt 0 ]]; then
        log_success "Added $added_count new configuration(s) to stow packages!"
        log_info "Run 'make stow-deploy' to deploy the new configurations"
    else
        log_info "No new configurations were added"
    fi
}

# Run main function
main "$@" 