#!/bin/bash

# Test script to verify Starship integration with Nushell
# This script checks if Nushell and Starship are properly configured

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

echo "🚀 Testing Nushell + Starship Integration"
echo "=========================================="
echo ""

# Check if nu is installed
if command -v nu &> /dev/null; then
    print_success "Nu is installed: $(which nu)"
    print_success "Nu version: $(nu --version | head -n1)"
else
    print_error "Nu is not installed"
    echo "Install with: brew install nushell"
    exit 1
fi

# Check if starship is installed
if command -v starship &> /dev/null; then
    print_success "Starship is installed: $(which starship)"
    print_success "Starship version: $(starship --version | head -n1)"
else
    print_error "Starship is not installed"
    echo "Install with: brew install starship"
    exit 1
fi

# Check if nushell config exists
NUSHELL_CONFIG="$HOME/.config/nushell/config.nu"
if [[ -f "$NUSHELL_CONFIG" ]]; then
    print_success "Nushell config exists: $NUSHELL_CONFIG"
else
    print_warning "Nushell config not found: $NUSHELL_CONFIG"
    echo "Deploy stow packages with: make stow-deploy"
fi

# Check if starship config exists
STARSHIP_CONFIG="$HOME/.config/starship.toml"
if [[ -f "$STARSHIP_CONFIG" ]]; then
    print_success "Starship config exists: $STARSHIP_CONFIG"
else
    print_warning "Starship config not found: $STARSHIP_CONFIG"
    echo "Deploy stow packages with: make stow-deploy"
fi

# Check if starship cache directory exists
STARSHIP_CACHE="$HOME/.cache/starship"
if [[ -d "$STARSHIP_CACHE" ]]; then
    print_success "Starship cache directory exists: $STARSHIP_CACHE"
    
    # Check if nushell init script exists
    NUSHELL_INIT="$STARSHIP_CACHE/init.nu"
    if [[ -f "$NUSHELL_INIT" ]]; then
        print_success "Starship Nushell init script exists: $NUSHELL_INIT"
    else
        print_warning "Starship Nushell init script not found: $NUSHELL_INIT"
        echo "This will be created when you first run nushell"
    fi
else
    print_warning "Starship cache directory not found: $STARSHIP_CACHE"
    echo "This will be created when you first run nushell"
fi

echo ""
echo "🧪 Testing Nushell with Starship..."
echo ""

# Test nu with a simple command
if nu -c "starship-status" 2>/dev/null; then
    print_success "Nu Starship integration is working!"
else
    print_warning "Nu Starship integration test failed"
    echo "This might be normal if you haven't run nu yet"
fi

echo ""
echo "📋 Next Steps:"
echo "1. Run 'nu' to start Nu with Starship"
echo "2. Use 'starship-status' to check Starship configuration"
echo "3. Use 'starship-config' to edit Starship config"
echo "4. Use 'starship-reload' to reload Starship configuration"
echo ""
echo "�� Test completed!" 