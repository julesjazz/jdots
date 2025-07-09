#!/bin/bash

# Cursor IDE Settings Backup Script
# This script backs up Cursor IDE settings without affecting normal operations

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
HOSTNAME=$(hostname | sed 's/\.local.*$//')

# Cursor settings paths
CURSOR_SETTINGS_PATHS=(
    "$HOME/Library/Application Support/Cursor/User/settings.json"
    "$HOME/.config/Cursor/User/settings.json"
    "$HOME/.cursor/settings.json"
)

# Cursor extensions and other config paths
CURSOR_CONFIG_PATHS=(
    "$HOME/Library/Application Support/Cursor/User/extensions"
    "$HOME/.config/Cursor/User/extensions"
    "$HOME/Library/Application Support/Cursor/User/keybindings.json"
    "$HOME/.config/Cursor/User/keybindings.json"
    "$HOME/Library/Application Support/Cursor/User/snippets"
    "$HOME/.config/Cursor/User/snippets"
)

# Backup directory
BACKUP_DIR="$PROJECT_ROOT/backups/cursor"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Function to create backup directory
create_backup_dir() {
    if [[ ! -d "$BACKUP_DIR" ]]; then
        print_status "Creating backup directory..."
        mkdir -p "$BACKUP_DIR"
        print_success "Created backup directory: $BACKUP_DIR"
    fi
}

# Function to backup Cursor settings
backup_cursor_settings() {
    print_status "Backing up Cursor settings..."
    
    local found_settings=false
    local backup_files=()
    
    # Backup settings.json files
    for settings_path in "${CURSOR_SETTINGS_PATHS[@]}"; do
        if [[ -f "$settings_path" ]]; then
            print_status "Found settings at: $settings_path"
            
            # Create backup filename
            local filename=$(basename "$settings_path")
            local backup_filename="cursor-settings-${HOSTNAME}-${TIMESTAMP}.json"
            local backup_path="$BACKUP_DIR/$backup_filename"
            
            # Create backup
            cp "$settings_path" "$backup_path"
            backup_files+=("$backup_path")
            found_settings=true
            
            print_success "Backed up: $filename → $backup_filename"
            
            # Show file size
            local size=$(du -h "$backup_path" | cut -f1)
            print_status "Backup size: $size"
        fi
    done
    
    # Backup other config files and directories
    for config_path in "${CURSOR_CONFIG_PATHS[@]}"; do
        if [[ -e "$config_path" ]]; then
            print_status "Found config at: $config_path"
            
            # Create backup filename
            local basename_path=$(basename "$config_path")
            local backup_filename="cursor-${basename_path}-${HOSTNAME}-${TIMESTAMP}"
            local backup_path="$BACKUP_DIR/$backup_filename"
            
            if [[ -d "$config_path" ]]; then
                # Directory backup
                cp -r "$config_path" "$backup_path"
                print_success "Backed up directory: $basename_path → $backup_filename"
            else
                # File backup
                cp "$config_path" "$backup_path"
                print_success "Backed up file: $basename_path → $backup_filename"
            fi
            
            backup_files+=("$backup_path")
            found_settings=true
            
            # Show size
            local size=$(du -sh "$backup_path" | cut -f1)
            print_status "Backup size: $size"
        fi
    done
    
    if [[ "$found_settings" == false ]]; then
        print_warning "No Cursor settings found in common locations:"
        echo "Settings files:"
        for path in "${CURSOR_SETTINGS_PATHS[@]}"; do
            echo "  - $path"
        done
        echo "Config directories:"
        for path in "${CURSOR_CONFIG_PATHS[@]}"; do
            echo "  - $path"
        done
        return 1
    fi
    
    # Create a symlink to the latest backup
    if [[ ${#backup_files[@]} -gt 0 ]]; then
        local latest_backup="${backup_files[0]}"
        local latest_link="$BACKUP_DIR/cursor-settings-${HOSTNAME}-latest"
        
        # Remove existing symlink if it exists
        if [[ -L "$latest_link" ]]; then
            rm "$latest_link"
        fi
        
        # Create new symlink
        ln -sf "$(basename "$latest_backup")" "$latest_link"
        print_success "Created latest symlink: $(basename "$latest_link")"
    fi
    
    return 0
}

# Function to list existing backups
list_backups() {
    print_status "Existing Cursor backups:"
    echo ""
    
    if [[ ! -d "$BACKUP_DIR" ]]; then
        print_warning "No backup directory found"
        return
    fi
    
    local backup_count=0
    
    # List all backup files
    for file in "$BACKUP_DIR"/cursor-*; do
        if [[ -e "$file" ]]; then
            local filename=$(basename "$file")
            local size=$(du -sh "$file" | cut -f1)
            local date=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$file" 2>/dev/null || stat -c "%y" "$file" 2>/dev/null || echo "Unknown")
            
            if [[ "$filename" == *"-latest" ]]; then
                echo "📄 $filename (latest) - $size - $date"
            else
                echo "📄 $filename - $size - $date"
            fi
            
            ((backup_count++))
        fi
    done
    
    if [[ $backup_count -eq 0 ]]; then
        print_warning "No backup files found"
    else
        echo ""
        print_success "Found $backup_count backup file(s)"
    fi
}

# Function to clean old backups
clean_old_backups() {
    print_status "Cleaning old backups..."
    
    if [[ ! -d "$BACKUP_DIR" ]]; then
        print_warning "No backup directory found"
        return
    fi
    
    # Keep the latest 5 backups per hostname
    local keep_count=5
    local cleaned_count=0
    
    # Find all backup files for current hostname (excluding latest symlink)
    local backup_files=()
    for file in "$BACKUP_DIR"/cursor-*-${HOSTNAME}-*; do
        if [[ -e "$file" && "$file" != *"-latest" ]]; then
            backup_files+=("$file")
        fi
    done
    
    # Sort by modification time (newest first)
    if [[ ${#backup_files[@]} -gt $keep_count ]]; then
        # Sort files by modification time (newest first)
        IFS=$'\n' sorted_files=($(sort -r -k1,1 < <(for f in "${backup_files[@]}"; do echo "$(stat -f "%m" "$f" 2>/dev/null || stat -c "%Y" "$f" 2>/dev/null || echo "0") $f"; done) | cut -d' ' -f2-))
        unset IFS
        
        # Remove old files
        for ((i=keep_count; i<${#sorted_files[@]}; i++)); do
            local file="${sorted_files[$i]}"
            print_status "Removing old backup: $(basename "$file")"
            rm -rf "$file"
            ((cleaned_count++))
        done
        
        print_success "Cleaned $cleaned_count old backup file(s)"
    else
        print_status "No old backups to clean (keeping ${#backup_files[@]} files)"
    fi
}

# Function to show backup info
show_backup_info() {
    echo "📁 Cursor IDE Settings Backup"
    echo "============================="
    echo ""
    print_status "Backup directory: $BACKUP_DIR"
    print_status "Hostname: $HOSTNAME"
    print_status "Timestamp: $TIMESTAMP"
    echo ""
    
    # Show Cursor settings locations
    print_status "Cursor settings locations:"
    for path in "${CURSOR_SETTINGS_PATHS[@]}"; do
        if [[ -f "$path" ]]; then
            local size=$(du -h "$path" | cut -f1)
            echo "  ✅ $path ($size)"
        else
            echo "  ❌ $path (not found)"
        fi
    done
    
    echo ""
    print_status "Cursor config locations:"
    for path in "${CURSOR_CONFIG_PATHS[@]}"; do
        if [[ -e "$path" ]]; then
            local size=$(du -sh "$path" | cut -f1)
            if [[ -d "$path" ]]; then
                echo "  ✅ $path (directory, $size)"
            else
                echo "  ✅ $path (file, $size)"
            fi
        else
            echo "  ❌ $path (not found)"
        fi
    done
    echo ""
}

# Function to show help
show_help() {
    echo "📁 Cursor IDE Settings Backup Script"
    echo "===================================="
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  backup        - Create a new backup of Cursor settings"
    echo "  list          - List existing backups"
    echo "  clean         - Clean old backups (keep latest 5)"
    echo "  info          - Show backup information"
    echo "  help          - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 backup     # Create a new backup"
    echo "  $0 list       # List existing backups"
    echo "  $0 clean      # Clean old backups"
    echo ""
}

# Main execution
main() {
    case "${1:-help}" in
        "backup")
            show_backup_info
            create_backup_dir
            backup_cursor_settings
            echo ""
            print_success "Cursor settings backup completed!"
            ;;
        "list")
            list_backups
            ;;
        "clean")
            clean_old_backups
            ;;
        "info")
            show_backup_info
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            print_error "Unknown command: $1"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@" 