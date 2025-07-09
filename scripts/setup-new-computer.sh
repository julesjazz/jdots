#!/bin/bash

# New Computer Setup Script for jdots
# This script sets up jdots on a new computer by installing brew packages and configuring dotfiles

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
HOSTNAME=$(hostname | sed 's/\.local.*$//')

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

# Function to check if we're on macOS
check_macos() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_warning "This script is designed for macOS. Some features may not work on other systems."
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 0
        fi
    fi
}

# Function to check if Homebrew is installed
check_homebrew() {
    if ! command -v brew &> /dev/null; then
        print_warning "Homebrew is not installed. Installing now..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH if needed
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            export PATH="/opt/homebrew/bin:$PATH"
            print_status "Added Homebrew to PATH for this session"
        fi
        
        print_success "Homebrew installed successfully"
    else
        print_success "Homebrew is already installed"
    fi
}

# Function to install brew packages from brewlist.txt
install_brew_packages() {
    print_status "Installing brew packages from brewlist.txt..."
    
    BREW_INSTALL_SCRIPT="$PROJECT_ROOT/scripts/brewclean/install-brew-packages.sh"
    
    if [[ -f "$BREW_INSTALL_SCRIPT" ]]; then
        chmod +x "$BREW_INSTALL_SCRIPT"
        "$BREW_INSTALL_SCRIPT"
    else
        print_error "Brew installation script not found: $BREW_INSTALL_SCRIPT"
        return 1
    fi
}

# Function to install stow dependencies
install_stow_deps() {
    print_status "Installing stow dependencies..."
    
    STOW_DEPS_SCRIPT="$PROJECT_ROOT/scripts/stow/install-dependencies.sh"
    
    if [[ -f "$STOW_DEPS_SCRIPT" ]]; then
        chmod +x "$STOW_DEPS_SCRIPT"
        "$STOW_DEPS_SCRIPT"
    else
        print_error "Stow dependencies script not found: $STOW_DEPS_SCRIPT"
        return 1
    fi
}

# Function to set up stow packages
setup_stow() {
    print_status "Setting up stow packages..."
    
    cd "$PROJECT_ROOT"
    
    # Backup existing configs
    print_status "Backing up existing configs..."
    make stow-backup
    
    # Deploy stow packages
    print_status "Deploying stow packages..."
    make stow-deploy
    
    print_success "Stow setup completed"
}

# Function to set up shell configurations
setup_shells() {
    print_status "Setting up shell configurations..."
    
    # Check if zsh is available and set as default
    if command -v zsh &> /dev/null; then
        CURRENT_SHELL=$(echo $SHELL)
        if [[ "$CURRENT_SHELL" != *"zsh" ]]; then
            print_status "Setting zsh as default shell..."
            chsh -s $(which zsh)
            print_success "zsh set as default shell. Please restart your terminal."
        else
            print_success "zsh is already the default shell"
        fi
    fi
    
    # Check if fish is available
    if command -v fish &> /dev/null; then
        print_success "fish shell is available"
    else
        print_warning "fish shell is not installed"
    fi
}

# Function to verify installation
verify_setup() {
    print_status "Verifying setup..."
    
    # Check key tools
    local tools=("git" "nvim" "fzf" "fd" "ripgrep" "stow" "starship")
    local missing_tools=()
    
    for tool in "${tools[@]}"; do
        if command -v "$tool" &> /dev/null; then
            print_success "$tool is installed"
        else
            print_warning "$tool is not installed"
            missing_tools+=("$tool")
        fi
    done
    
    # Check stow status
    cd "$PROJECT_ROOT"
    print_status "Checking stow package status..."
    make stow-status
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        print_warning "Some tools are missing: ${missing_tools[*]}"
        print_status "You may need to install them manually or check the brew installation"
    else
        print_success "All key tools are installed"
    fi
}

# Function to show next steps
show_next_steps() {
    echo ""
    echo "🎉 Setup completed!"
    echo "=================="
    echo ""
    echo "Next steps:"
    echo "1. Restart your terminal to ensure all changes take effect"
    echo "2. If you set zsh as default shell, you may need to log out and back in"
    echo "3. Install Oh My Zsh if desired:"
    echo "   sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\""
    echo "4. Check your dotfiles are working:"
    echo "   make stow-status"
    echo "5. Run health check:"
    echo "   make health-check"
    echo ""
    echo "Useful commands:"
    echo "  make help           - Show all available commands"
    echo "  make brewclean      - Clean up Homebrew"
    echo "  make maintenance    - Full system maintenance"
    echo ""
}

# Main execution
main() {
    echo "🚀 jdots New Computer Setup"
    echo "==========================="
    echo ""
    
    # Check if we're on macOS
    check_macos
    
    # Check if we're in the right directory
    if [[ ! -f "$PROJECT_ROOT/Makefile" ]]; then
        print_error "Makefile not found. Please run this script from the jdots project root."
        exit 1
    fi
    
    # Check if Homebrew is installed
    check_homebrew
    
    # Install brew packages
    install_brew_packages
    
    # Install stow dependencies
    install_stow_deps
    
    # Set up stow packages
    setup_stow
    
    # Set up shell configurations
    setup_shells
    
    # Verify the setup
    verify_setup
    
    # Show next steps
    show_next_steps
}

# Run main function
main "$@" 