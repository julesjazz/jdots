#!/bin/bash

# Restore .config files from stow packages
# This script restores configuration files from stow packages to ~/.config
# It will backup existing files before overwriting them

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
STOW_DIR="$PROJECT_ROOT/stow-packages"
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$HOME/.config.backup.$(date +%Y%m%d_%H%M%S)"

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

# Function to backup existing config before restoring
backup_existing() {
    local app_name="$1"
    local config_source_dir="$CONFIG_DIR/$app_name"
    local backup_app_dir="$BACKUP_DIR/$app_name"
    
    # Backup .config version
    if [[ -d "$config_source_dir" ]]; then
        log_info "Backing up existing $app_name configuration from .config..."
        mkdir -p "$backup_app_dir"
        cp -r "$config_source_dir"/* "$backup_app_dir/" 2>/dev/null || true
        log_success "Backed up existing $app_name configuration to $backup_app_dir"
    fi
    
    # Backup home directory files for bash and zsh
    if [[ "$app_name" == "bash" ]] || [[ "$app_name" == "zsh" ]]; then
        local home_file="$HOME/.${app_name}rc"
        if [[ -f "$home_file" ]]; then
            log_info "Backing up existing ~/.${app_name}rc..."
            mkdir -p "$BACKUP_DIR"
            cp "$home_file" "$BACKUP_DIR/" 2>/dev/null || true
            log_success "Backed up existing ~/.${app_name}rc to $BACKUP_DIR"
        fi
    fi
}

# Function to restore config files for a specific application
restore_config() {
    local app_name="$1"
    local config_source_dir="$STOW_DIR/config/$app_name"
    local home_source_dir="$STOW_DIR/home"
    local config_target_dir="$CONFIG_DIR/$app_name"
    
    log_info "Restoring $app_name configuration..."
    
    # Backup existing config
    backup_existing "$app_name"
    
    # Create target directory
    mkdir -p "$config_target_dir"
    
    # Copy files based on application
    case "$app_name" in
        "zsh")
            # Restore zsh config files to .config
            if [[ -d "$config_source_dir" ]]; then
                cp -r "$config_source_dir"/* "$config_target_dir/" 2>/dev/null || log_warning "No .config files to restore for zsh"
            fi
            # Restore home directory .zshrc
            if [[ -f "$home_source_dir/.zshrc" ]]; then
                cp "$home_source_dir/.zshrc" "$HOME/"
                log_success "Restored ~/.zshrc"
            fi
            ;;
        "bash")
            # Restore bash config files to .config
            if [[ -d "$config_source_dir" ]]; then
                cp -r "$config_source_dir"/* "$config_target_dir/" 2>/dev/null || log_warning "No .config files to restore for bash"
            fi
            # Restore home directory .bashrc
            if [[ -f "$home_source_dir/.bashrc" ]]; then
                cp "$home_source_dir/.bashrc" "$HOME/"
                log_success "Restored ~/.bashrc"
            fi
            ;;
        *)
            # For other apps, just restore from .config
            if [[ -d "$config_source_dir" ]]; then
                cp -r "$config_source_dir"/* "$config_target_dir/" 2>/dev/null || log_warning "No files to restore for $app_name"
            else
                log_warning "Stow package for $app_name does not exist, skipping"
                return 0
            fi
            ;;
    esac
    
    log_success "Restored $app_name configuration"
}

# Function to restore global config files
restore_global_config() {
    local source_dir="$STOW_DIR/config"
    
    if [[ ! -d "$source_dir" ]]; then
        log_warning "Global stow package does not exist, skipping"
        return 0
    fi
    
    log_info "Restoring global configuration files..."
    
    # Backup existing global configs
    if [[ -f "$CONFIG_DIR/.aliases" ]]; then
        mkdir -p "$BACKUP_DIR"
        cp "$CONFIG_DIR/.aliases" "$BACKUP_DIR/" 2>/dev/null || true
    fi
    if [[ -f "$CONFIG_DIR/starship.toml" ]]; then
        mkdir -p "$BACKUP_DIR"
        cp "$CONFIG_DIR/starship.toml" "$BACKUP_DIR/" 2>/dev/null || true
    fi
    
    # Copy global config files
    cp "$source_dir/.aliases" "$CONFIG_DIR/" 2>/dev/null || log_warning "No .aliases found in stow package"
    cp "$source_dir/starship.toml" "$CONFIG_DIR/" 2>/dev/null || log_warning "No starship.toml found in stow package"
    
    log_success "Restored global configuration files"
}

# Function to clean up backup directory if empty
cleanup_backup() {
    if [[ -d "$BACKUP_DIR" ]]; then
        if [[ -z "$(ls -A "$BACKUP_DIR")" ]]; then
            rmdir "$BACKUP_DIR"
            log_info "Removed empty backup directory"
        else
            log_info "Backup directory preserved at: $BACKUP_DIR"
        fi
    fi
}

# Main restore process
main() {
    log_info "Starting .config restore from stow packages..."
    
    # Check if stow directory exists
    if [[ ! -d "$STOW_DIR" ]]; then
        log_error "Stow directory does not exist: $STOW_DIR"
        log_error "Run 'make stow-backup' first to create stow packages"
        exit 1
    fi
    
    # Create backup directory
    mkdir -p "$BACKUP_DIR"
    
    # Restore application-specific configs
    local apps=("zsh" "fish" "nvim" "bash" "powershell" "gitlab" "ghostty")
    
    for app in "${apps[@]}"; do
        restore_config "$app"
    done
    
    # Restore global config files
    restore_global_config
    
    # Clean up empty backup directory
    cleanup_backup
    
    log_success "Restore completed successfully!"
    log_info "Original configurations backed up to: $BACKUP_DIR"
}

# Run main function
main "$@" 