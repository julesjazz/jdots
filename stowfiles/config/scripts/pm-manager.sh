#!/bin/bash

# Package Manager Manager
# Handles all package manager operations with OS detection
# Usage: pm-manager.sh [clean|install|sync] [sync-args]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source the detection functions
source "$SCRIPT_DIR/pm-utils.sh"

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

# Detect package manager and route to appropriate script
route_to_package_manager() {
    local operation="$1"
    shift
    
    PM=$(detect_package_manager)
    OS_INFO=$(get_os_info)
    
    if [[ "$PM" == "none" ]]; then
        print_error "No supported package manager found for: $OS_INFO"
        exit 1
    fi
    
    print_status "Detected OS: $OS_INFO"
    print_status "Using package manager: $PM"
    
    case "$PM" in
        "brew")
            case "$operation" in
                "clean")
                    print_status "Running Homebrew cleanup..."
                    exec "$SCRIPT_DIR/brew-clean.sh"
                    ;;
                "install")
                    print_status "Running Homebrew install..."
                    exec "$SCRIPT_DIR/brew-install.sh"
                    ;;
                "sync")
                    print_status "Running Homebrew sync..."
                    exec "$SCRIPT_DIR/brew-sync.sh" "$@"
                    ;;
                *)
                    print_error "Unknown operation: $operation"
                    exit 1
                    ;;
            esac
            ;;
        "apt")
            case "$operation" in
                "clean")
                    print_error "APT clean not yet implemented"
                    exit 1
                    ;;
                "install")
                    print_error "APT install not yet implemented"
                    exit 1
                    ;;
                "sync")
                    print_error "APT sync not yet implemented"
                    exit 1
                    ;;
                *)
                    print_error "Unknown operation: $operation"
                    exit 1
                    ;;
            esac
            ;;
        "dnf"|"yum")
            case "$operation" in
                "clean")
                    print_error "DNF clean not yet implemented"
                    exit 1
                    ;;
                "install")
                    print_error "DNF install not yet implemented"
                    exit 1
                    ;;
                "sync")
                    print_error "DNF sync not yet implemented"
                    exit 1
                    ;;
                *)
                    print_error "Unknown operation: $operation"
                    exit 1
                    ;;
            esac
            ;;
        *)
            print_error "Unsupported package manager: $PM"
            exit 1
            ;;
    esac
}

# Show help
show_help() {
    echo "📦 Package Manager Manager"
    echo "=========================="
    echo ""
    echo "Usage: $0 [OPERATION] [ARGS...]"
    echo ""
    echo "Operations:"
    echo "  clean                    - Clean up package manager and generate lists"
    echo "  install                  - Install packages from lists"
    echo "  sync [COMMAND] [ARGS]    - Sync package lists"
    echo ""
    echo "Sync Commands:"
    echo "  to-master                - Sync computer list to master"
    echo "  from-master              - Sync master list to computer"
    echo "  diff                     - Show differences between lists"
    echo ""
    echo "Examples:"
    echo "  $0 clean                 # Clean up and generate lists"
    echo "  $0 install               # Install packages from lists"
    echo "  $0 sync to-master        # Sync computer list to master"
    echo "  $0 sync from-master      # Sync master list to computer"
    echo "  $0 sync diff             # Show differences"
    echo ""
}

# Main execution
main() {
    case "${1:-help}" in
        "clean")
            route_to_package_manager "clean"
            ;;
        "install")
            route_to_package_manager "install"
            ;;
        "sync")
            shift
            route_to_package_manager "sync" "$@"
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            print_error "Unknown operation: $1"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@" 