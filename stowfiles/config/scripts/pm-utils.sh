#!/bin/bash

# Package Manager Utilities
# Provides OS detection and package manager utilities

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

# Detect operating system family
get_os_family() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ -f /etc/os-release ]]; then
        source /etc/os-release
        case "$ID" in
            "ubuntu"|"debian")
                echo "debian"
                ;;
            "fedora"|"rhel"|"centos"|"rocky"|"alma")
                echo "redhat"
                ;;
            *)
                echo "unknown"
                ;;
        esac
    else
        echo "unknown"
    fi
}

# Get detailed OS information
get_os_info() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macOS $(sw_vers -productVersion)"
    elif [[ -f /etc/os-release ]]; then
        source /etc/os-release
        echo "$PRETTY_NAME"
    else
        echo "Unknown OS"
    fi
}

# Detect package manager
detect_package_manager() {
    local os_family=$(get_os_family)
    
    case "$os_family" in
        "macos")
            if command -v brew >/dev/null 2>&1; then
                echo "brew"
            else
                echo "none"
            fi
            ;;
        "debian")
            if command -v apt >/dev/null 2>&1; then
                echo "apt"
            else
                echo "none"
            fi
            ;;
        "redhat")
            if command -v dnf >/dev/null 2>&1; then
                echo "dnf"
            elif command -v yum >/dev/null 2>&1; then
                echo "yum"
            else
                echo "none"
            fi
            ;;
        *)
            echo "none"
            ;;
    esac
}

# Ensure platform-specific directory exists
ensure_platform_dir() {
    local base_dir="$1"
    local platform_dir=""
    
    case "$(get_os_family)" in
        "macos")
            platform_dir="$base_dir/brew"
            ;;
        "debian")
            platform_dir="$base_dir/apt"
            ;;
        "redhat")
            platform_dir="$base_dir/dnf"
            ;;
        *)
            print_error "Unsupported platform for directory creation"
            return 1
            ;;
    esac
    
    if [[ ! -d "$platform_dir" ]]; then
        print_status "Creating platform directory: $platform_dir"
        mkdir -p "$platform_dir"
        print_success "Created: $platform_dir"
    fi
    
    echo "$platform_dir"
}

# Get platform-specific directory path
get_platform_dir() {
    local base_dir="$1"
    local platform_dir=""
    
    case "$(get_os_family)" in
        "macos")
            platform_dir="$base_dir/brew"
            ;;
        "debian")
            platform_dir="$base_dir/apt"
            ;;
        "redhat")
            platform_dir="$base_dir/dnf"
            ;;
        *)
            print_error "Unsupported platform"
            return 1
            ;;
    esac
    
    echo "$platform_dir"
}

# Test OS detection functions
test_detection() {
    echo "🔍 OS Detection Test"
    echo "==================="
    echo "OS Family: $(get_os_family)"
    echo "OS Info: $(get_os_info)"
    echo "Package Manager: $(detect_package_manager)"
    echo ""
    
    local platform_dir=$(get_platform_dir "./system_packages")
    if [[ $? -eq 0 ]]; then
        echo "Platform Directory: $platform_dir"
    fi
}

# If script is run directly, test detection
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    test_detection
fi 