#!/bin/bash

# Package Manager Backup Cleanup Script
# Cleans up backup files for all supported package managers
# Usage: pm-backup-clean.sh [OPTIONS]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source the detection functions
source "$SCRIPT_DIR/pm-utils.sh"

# Global options (passed from pm-manager.sh)
DRY_RUN=${DRY_RUN:-false}
VERBOSE=${VERBOSE:-false}
QUIET=${QUIET:-false}

# Setup logging if verbose mode is enabled
if [[ "$VERBOSE" == "true" ]]; then
    setup_logging
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Function to prompt for confirmation
prompt_confirmation() {
    local message="$1"
    
    # Skip confirmation in dry-run mode
    if [[ "$DRY_RUN" == "true" ]]; then
        print_warning "DRY RUN: Would prompt: $message"
        return 0
    fi
    
    # Skip confirmation in quiet mode
    if [[ "$QUIET" == "true" ]]; then
        print_warning "QUIET MODE: Skipping confirmation"
        return 1
    fi
    
    echo -e "\n${YELLOW}🤔 $message (y/N) [10s timeout]${NC}"
    if read -t 10 -r response; then
        if [[ "$response" =~ ^[Yy]$ ]]; then
            return 0
        else
            return 1
        fi
    else
        echo "⏰ Timeout - skipping backup cleanup"
        return 1
    fi
}

# Function to clean Homebrew backup files
clean_brew_backups() {
    print_status "Checking for Homebrew backup files..."
    
    local brew_dir=$(get_platform_dir "$SCRIPT_DIR/../system_packages")
    local backup_files=()
    
    # Find backup files in brew directory
    if [[ -d "$brew_dir" ]]; then
        while IFS= read -r -d '' file; do
            backup_files+=("$file")
        done < <(find "$brew_dir" -name "*.backup" -o -name "*.bak" -o -name "*.old" -o -name "*.orig" -print0 2>/dev/null || true)
    fi
    
    if [[ ${#backup_files[@]} -eq 0 ]]; then
        print_success "No Homebrew backup files found"
        return 0
    fi
    
    print_warning "Found ${#backup_files[@]} Homebrew backup files:"
    for file in "${backup_files[@]}"; do
        echo "  - $file"
    done
    
    if prompt_confirmation "Delete these Homebrew backup files?"; then
        for file in "${backup_files[@]}"; do
            if [[ "$DRY_RUN" == "true" ]]; then
                print_warning "DRY RUN: Would delete: $file"
            else
                rm -f "$file"
                print_success "Deleted: $file"
            fi
        done
        if [[ "$DRY_RUN" == "true" ]]; then
            print_warning "DRY RUN: Homebrew backup cleanup simulation complete"
        else
            print_success "Homebrew backup cleanup complete"
        fi
    else
        print_warning "Skipped Homebrew backup cleanup"
    fi
}

# Function to clean APT backup files
clean_apt_backups() {
    print_status "Checking for APT backup files..."
    
    local apt_dir=$(get_platform_dir "$SCRIPT_DIR/../system_packages")
    local backup_files=()
    
    # Find backup files in apt directory
    if [[ -d "$apt_dir" ]]; then
        while IFS= read -r -d '' file; do
            backup_files+=("$file")
        done < <(find "$apt_dir" -name "*.backup" -o -name "*.bak" -o -name "*.old" -o -name "*.orig" -print0 2>/dev/null || true)
    fi
    
    if [[ ${#backup_files[@]} -eq 0 ]]; then
        print_success "No APT backup files found"
        return 0
    fi
    
    print_warning "Found ${#backup_files[@]} APT backup files:"
    for file in "${backup_files[@]}"; do
        echo "  - $file"
    done
    
    if prompt_confirmation "Delete these APT backup files?"; then
        for file in "${backup_files[@]}"; do
            if [[ "$DRY_RUN" == "true" ]]; then
                print_warning "DRY RUN: Would delete: $file"
            else
                rm -f "$file"
                print_success "Deleted: $file"
            fi
        done
        if [[ "$DRY_RUN" == "true" ]]; then
            print_warning "DRY RUN: APT backup cleanup simulation complete"
        else
            print_success "APT backup cleanup complete"
        fi
    else
        print_warning "Skipped APT backup cleanup"
    fi
}

# Function to clean DNF backup files
clean_dnf_backups() {
    print_status "Checking for DNF backup files..."
    
    local dnf_dir=$(get_platform_dir "$SCRIPT_DIR/../system_packages")
    local backup_files=()
    
    # Find backup files in dnf directory
    if [[ -d "$dnf_dir" ]]; then
        while IFS= read -r -d '' file; do
            backup_files+=("$file")
        done < <(find "$dnf_dir" -name "*.backup" -o -name "*.bak" -o -name "*.old" -o -name "*.orig" -print0 2>/dev/null || true)
    fi
    
    if [[ ${#backup_files[@]} -eq 0 ]]; then
        print_success "No DNF backup files found"
        return 0
    fi
    
    print_warning "Found ${#backup_files[@]} DNF backup files:"
    for file in "${backup_files[@]}"; do
        echo "  - $file"
    done
    
    if prompt_confirmation "Delete these DNF backup files?"; then
        for file in "${backup_files[@]}"; do
            if [[ "$DRY_RUN" == "true" ]]; then
                print_warning "DRY RUN: Would delete: $file"
            else
                rm -f "$file"
                print_success "Deleted: $file"
            fi
        done
        if [[ "$DRY_RUN" == "true" ]]; then
            print_warning "DRY RUN: DNF backup cleanup simulation complete"
        else
            print_success "DNF backup cleanup complete"
        fi
    else
        print_warning "Skipped DNF backup cleanup"
    fi
}

# Function to clean general backup files
clean_general_backups() {
    print_status "Checking for general backup files in system_packages..."
    
    local system_packages_dir="$SCRIPT_DIR/../system_packages"
    local backup_files=()
    
    # Find backup files in system_packages directory (excluding platform-specific dirs)
    if [[ -d "$system_packages_dir" ]]; then
        while IFS= read -r -d '' file; do
            # Skip files in platform-specific directories (handled separately)
            if [[ "$file" != */brew/* && "$file" != */apt/* && "$file" != */dnf/* ]]; then
                backup_files+=("$file")
            fi
        done < <(find "$system_packages_dir" -name "*.backup" -o -name "*.bak" -o -name "*.old" -o -name "*.orig" -print0 2>/dev/null || true)
    fi
    
    if [[ ${#backup_files[@]} -eq 0 ]]; then
        print_success "No general backup files found"
        return 0
    fi
    
    print_warning "Found ${#backup_files[@]} general backup files:"
    for file in "${backup_files[@]}"; do
        echo "  - $file"
    done
    
    if prompt_confirmation "Delete these general backup files?"; then
        for file in "${backup_files[@]}"; do
            if [[ "$DRY_RUN" == "true" ]]; then
                print_warning "DRY RUN: Would delete: $file"
            else
                rm -f "$file"
                print_success "Deleted: $file"
            fi
        done
        if [[ "$DRY_RUN" == "true" ]]; then
            print_warning "DRY RUN: General backup cleanup simulation complete"
        else
            print_success "General backup cleanup complete"
        fi
    else
        print_warning "Skipped general backup cleanup"
    fi
}

# Function to clean .config backup files
clean_config_backups() {
    print_status "Checking for backup files in .config directory..."
    
    local config_dir="$SCRIPT_DIR/.."
    local backup_files=()
    
    # Find backup files in .config directory
    if [[ -d "$config_dir" ]]; then
        while IFS= read -r -d '' file; do
            backup_files+=("$file")
        done < <(find "$config_dir" -name "*.backup" -o -name "*.bak" -o -name "*.old" -o -name "*.orig" -print0 2>/dev/null || true)
    fi
    
    if [[ ${#backup_files[@]} -eq 0 ]]; then
        print_success "No .config backup files found"
        return 0
    fi
    
    print_warning "Found ${#backup_files[@]} backup files in .config:"
    for file in "${backup_files[@]}"; do
        echo "  - $file"
    done
    
    if prompt_confirmation "Delete these .config backup files?"; then
        for file in "${backup_files[@]}"; do
            if [[ "$DRY_RUN" == "true" ]]; then
                print_warning "DRY RUN: Would delete: $file"
            else
                rm -f "$file"
                print_success "Deleted: $file"
            fi
        done
        if [[ "$DRY_RUN" == "true" ]]; then
            print_warning "DRY RUN: .config backup cleanup simulation complete"
        else
            print_success ".config backup cleanup complete"
        fi
    else
        print_warning "Skipped .config backup cleanup"
    fi
}

# Main execution
main() {
    echo "🗑️  Package Manager Backup Cleanup"
    echo "=================================="
    echo ""
    
    # Detect OS and package manager
    local os_family=$(get_os_family)
    local package_manager=$(detect_package_manager)
    
    print_status "Detected OS: $os_family"
    print_status "Package Manager: $package_manager"
    echo ""
    
    # Clean platform-specific backups
    case "$package_manager" in
        "brew")
            clean_brew_backups
            ;;
        "apt")
            clean_apt_backups
            ;;
        "dnf"|"yum")
            clean_dnf_backups
            ;;
        *)
            print_warning "No supported package manager detected"
            ;;
    esac
    
    echo ""
    
    # Clean general backup files
    clean_general_backups
    
    echo ""
    
    # Clean .config backup files
    clean_config_backups
    
    echo ""
    print_success "Backup cleanup process complete!"
}

# Run main function
main "$@" 