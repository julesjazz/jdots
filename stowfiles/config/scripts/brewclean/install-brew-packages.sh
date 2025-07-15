#!/bin/bash

# Brew Package Installation Script
# This script installs brew formulas and casks listed in brewlist.txt

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MASTER_BREW_LIST_PATH="$SCRIPT_DIR/brewlist.txt"
HOSTNAME=$(hostname | sed 's/\.local.*$//')
COMPUTER_BREW_LIST_PATH="$SCRIPT_DIR/brewlist-${HOSTNAME}.txt"

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

# Function to check if Homebrew is installed
check_homebrew() {
    if ! command -v brew &> /dev/null; then
        print_error "Homebrew is not installed!"
        echo "Please install Homebrew first:"
        echo "/bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        exit 1
    fi
    print_success "Homebrew is installed"
}

# Function to determine which brew list file to use
determine_brew_list_file() {
    # Check if computer-specific list exists
    if [[ -f "$COMPUTER_BREW_LIST_PATH" ]]; then
        BREW_LIST_PATH="$COMPUTER_BREW_LIST_PATH"
        print_status "Using computer-specific brew list: $COMPUTER_BREW_LIST_PATH"
    elif [[ -f "$MASTER_BREW_LIST_PATH" ]]; then
        BREW_LIST_PATH="$MASTER_BREW_LIST_PATH"
        print_status "Using master brew list: $MASTER_BREW_LIST_PATH"
    else
        print_error "No brew list file found!"
        echo "Expected files:"
        echo "  $COMPUTER_BREW_LIST_PATH (computer-specific)"
        echo "  $MASTER_BREW_LIST_PATH (master list)"
        exit 1
    fi
}

# Function to extract formulas and casks from brewlist.txt
extract_packages() {
    if [[ ! -f "$BREW_LIST_PATH" ]]; then
        print_error "Brew list file not found at: $BREW_LIST_PATH"
        exit 1
    fi

    print_status "Extracting packages from $BREW_LIST_PATH..."

    # Extract formulas (everything between "Brew formulas" and "Brew Casks")
    FORMULAS=$(awk '/^# Brew formulas/,/^# Brew Casks/ {if ($0 !~ /^#/ && NF > 0) print $1}' "$BREW_LIST_PATH" | sort -u)
    
    # Extract casks (everything after "Brew Casks")
    CASKS=$(awk '/^# Brew Casks/,/^$/ {if ($0 !~ /^#/ && NF > 0) print $1}' "$BREW_LIST_PATH" | sort -u)

    # Remove empty lines and clean up
    FORMULAS=$(echo "$FORMULAS" | grep -v '^$' | sort -u)
    CASKS=$(echo "$CASKS" | grep -v '^$' | sort -u)

    print_success "Found $(echo "$FORMULAS" | wc -l | tr -d ' ') formulas and $(echo "$CASKS" | wc -l | tr -d ' ') casks"
}

# Function to check which packages are already installed
check_installed_packages() {
    print_status "Checking currently installed packages..."

    # Get currently installed formulas and casks
    INSTALLED_FORMULAS=$(brew list --formula 2>/dev/null | sort)
    INSTALLED_CASKS=$(brew list --cask 2>/dev/null | sort)

    # Find missing formulas
    MISSING_FORMULAS=$(comm -23 <(echo "$FORMULAS") <(echo "$INSTALLED_FORMULAS"))
    
    # Find missing casks
    MISSING_CASKS=$(comm -23 <(echo "$CASKS") <(echo "$INSTALLED_CASKS"))

    if [[ -n "$MISSING_FORMULAS" ]]; then
        print_warning "Missing formulas:"
        echo "$MISSING_FORMULAS" | sed 's/^/  - /'
        echo ""
    else
        print_success "All formulas are already installed"
    fi

    if [[ -n "$MISSING_CASKS" ]]; then
        print_warning "Missing casks:"
        echo "$MISSING_CASKS" | sed 's/^/  - /'
        echo ""
    else
        print_success "All casks are already installed"
    fi
}

# Function to install missing packages
install_missing_packages() {
    local total_missing=$(( $(echo "$MISSING_FORMULAS" | wc -l | tr -d ' ') + $(echo "$MISSING_CASKS" | wc -l | tr -d ' ') ))
    
    if [[ $total_missing -eq 0 ]]; then
        print_success "All packages are already installed!"
        return 0
    fi

    print_status "Installing $total_missing missing packages..."

    # Update Homebrew first
    print_status "Updating Homebrew..."
    brew update

    # Install missing formulas
    if [[ -n "$MISSING_FORMULAS" ]]; then
        print_status "Installing missing formulas..."
        echo "$MISSING_FORMULAS" | while read -r formula; do
            if [[ -n "$formula" ]]; then
                print_status "Installing formula: $formula"
                if brew install "$formula"; then
                    print_success "Installed: $formula"
                else
                    print_error "Failed to install: $formula"
                fi
            fi
        done
    fi

    # Install missing casks
    if [[ -n "$MISSING_CASKS" ]]; then
        print_status "Installing missing casks..."
        echo "$MISSING_CASKS" | while read -r cask; do
            if [[ -n "$cask" ]]; then
                print_status "Installing cask: $cask"
                if brew install --cask "$cask"; then
                    print_success "Installed: $cask"
                else
                    print_error "Failed to install: $cask"
                fi
            fi
        done
    fi
}

# Function to verify installation
verify_installation() {
    print_status "Verifying installation..."

    # Check formulas again
    INSTALLED_FORMULAS=$(brew list --formula 2>/dev/null | sort)
    STILL_MISSING_FORMULAS=$(comm -23 <(echo "$FORMULAS") <(echo "$INSTALLED_FORMULAS"))
    
    # Check casks again
    INSTALLED_CASKS=$(brew list --cask 2>/dev/null | sort)
    STILL_MISSING_CASKS=$(comm -23 <(echo "$CASKS") <(echo "$INSTALLED_CASKS"))

    if [[ -n "$STILL_MISSING_FORMULAS" || -n "$STILL_MISSING_CASKS" ]]; then
        print_warning "Some packages could not be installed:"
        if [[ -n "$STILL_MISSING_FORMULAS" ]]; then
            echo "Formulas:"
            echo "$STILL_MISSING_FORMULAS" | sed 's/^/  - /'
        fi
        if [[ -n "$STILL_MISSING_CASKS" ]]; then
            echo "Casks:"
            echo "$STILL_MISSING_CASKS" | sed 's/^/  - /'
        fi
        return 1
    else
        print_success "All packages successfully installed!"
        return 0
    fi
}

# Main execution
main() {
    echo "🍺 Brew Package Installation Script"
    echo "=================================="
    echo ""

    # Check if Homebrew is installed
    check_homebrew

    # Determine which brew list file to use
    determine_brew_list_file

    # Show detected hostname for debugging
    print_status "Detected hostname: $HOSTNAME"

    # Extract packages from brewlist.txt
    extract_packages

    # Check which packages are missing
    check_installed_packages

    # Ask for confirmation before installing
    if [[ -n "$MISSING_FORMULAS" || -n "$MISSING_CASKS" ]]; then
        echo ""
        read -p "Do you want to install the missing packages? (y/N): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            install_missing_packages
            verify_installation
        else
            print_warning "Installation cancelled by user"
            exit 0
        fi
    fi

    echo ""
    print_success "Brew package installation script completed!"
}

# Run main function
main "$@" 