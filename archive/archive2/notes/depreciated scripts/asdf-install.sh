#!/bin/bash

# ASDF Installation Script
# Installs ASDF version manager if not already present

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

# Check if ASDF is already installed
check_asdf_installed() {
    if command -v asdf &> /dev/null; then
        print_success "ASDF is already installed"
        asdf --version
        return 0
    else
        print_status "ASDF not found, installing..."
        return 1
    fi
}

# Install ASDF
install_asdf() {
    local asdf_dir="$HOME/.asdf"
    
    if [[ -d "$asdf_dir" ]]; then
        print_warning "ASDF directory already exists at $asdf_dir"
        print_status "Attempting to source existing installation..."
        
        # Try to source existing ASDF
        if [[ -f "$asdf_dir/asdf.sh" ]]; then
            source "$asdf_dir/asdf.sh"
            if command -v asdf &> /dev/null; then
                print_success "ASDF sourced successfully from existing installation"
                return 0
            fi
        fi
    fi
    
    print_status "Installing ASDF..."
    
    # Clone ASDF repository
    git clone https://github.com/asdf-vm/asdf.git "$asdf_dir"
    
    # Checkout latest stable version
    cd "$asdf_dir"
    git checkout "$(git describe --abbrev=0 --tags)"
    
    # Source ASDF
    source "$asdf_dir/asdf.sh"
    
    # Add to shell configuration
    local shell_config=""
    if [[ "$SHELL" == *"zsh"* ]]; then
        shell_config="$HOME/.zshrc"
    elif [[ "$SHELL" == *"bash"* ]]; then
        shell_config="$HOME/.bashrc"
    fi
    
    if [[ -n "$shell_config" ]]; then
        print_status "Adding ASDF to $shell_config..."
        {
            echo ""
            echo "# ASDF version manager"
            echo ". \"$asdf_dir/asdf.sh\""
            echo "fpath=(\${ASDF_DIR}/completions \$fpath)"
        } >> "$shell_config"
    fi
    
    print_success "ASDF installed successfully"
}

# Main execution
main() {
    echo "🔧 ASDF Installation Script"
    echo "==========================="
    echo ""
    
    if check_asdf_installed; then
        print_success "ASDF is ready to use"
        return 0
    else
        install_asdf
        print_success "ASDF installation complete"
        return 0
    fi
}

# Run main function
main "$@" 