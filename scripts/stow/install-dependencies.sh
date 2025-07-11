#!/bin/bash

# Install dependencies for dotfiles
# This script checks for and installs required packages for the dotfiles to work

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"

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

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to detect package manager
detect_package_manager() {
    if command_exists brew; then
        echo "brew"
    elif command_exists apt; then
        echo "apt"
    elif command_exists yum; then
        echo "yum"
    elif command_exists dnf; then
        echo "dnf"
    elif command_exists pacman; then
        echo "pacman"
    else
        echo "unknown"
    fi
}

# Function to install packages based on package manager
install_packages() {
    local pkg_manager="$1"
    local packages=("${@:2}")
    
    case "$pkg_manager" in
        "brew")
            log_info "Installing packages with Homebrew..."
            brew install "${packages[@]}"
            ;;
        "apt")
            log_info "Installing packages with apt..."
            sudo apt update
            sudo apt install -y "${packages[@]}"
            ;;
        "yum")
            log_info "Installing packages with yum..."
            sudo yum install -y "${packages[@]}"
            ;;
        "dnf")
            log_info "Installing packages with dnf..."
            sudo dnf install -y "${packages[@]}"
            ;;
        "pacman")
            log_info "Installing packages with pacman..."
            sudo pacman -S --noconfirm "${packages[@]}"
            ;;
        *)
            log_error "Unsupported package manager: $pkg_manager"
            return 1
            ;;
    esac
}

# Function to install shell-specific dependencies
install_shell_deps() {
    local pkg_manager="$1"
    
    log_info "Installing shell dependencies..."
    
    # Zsh dependencies
    if command_exists zsh; then
        log_info "Zsh is installed, checking for Oh My Zsh..."
        if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
            log_warning "Oh My Zsh not found. Install with: sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\""
        fi
    else
        log_warning "Zsh not found. Installing..."
        install_packages "$pkg_manager" zsh
    fi
    
    
    
    # Bash is usually pre-installed
    if command_exists bash; then
        log_success "Bash is installed"
    else
        log_warning "Bash not found. Installing..."
        install_packages "$pkg_manager" bash
    fi
    
    # Nushell dependencies
    if command_exists nu; then
        log_success "Nushell is installed"
    else
        log_warning "Nushell not found. Installing..."
        install_packages "$pkg_manager" nushell
    fi
}

# Function to install development tools
install_dev_tools() {
    local pkg_manager="$1"
    
    log_info "Installing development tools..."
    
    # Git
    if command_exists git; then
        log_success "Git is installed"
    else
        log_warning "Git not found. Installing..."
        install_packages "$pkg_manager" git
    fi
    
    # Neovim
    if command_exists nvim; then
        log_success "Neovim is installed"
    else
        log_warning "Neovim not found. Installing..."
        install_packages "$pkg_manager" neovim
    fi
    
    # FZF (for fuzzy finding)
    if command_exists fzf; then
        log_success "FZF is installed"
    else
        log_warning "FZF not found. Installing..."
        install_packages "$pkg_manager" fzf
    fi
    
    # FD (alternative to find)
    if command_exists fd; then
        log_success "FD is installed"
    else
        log_warning "FD not found. Installing..."
        install_packages "$pkg_manager" fd
    fi
    
    # Ripgrep
    if command_exists rg; then
        log_success "Ripgrep is installed"
    else
        log_warning "Ripgrep not found. Installing..."
        install_packages "$pkg_manager" ripgrep
    fi
}

# Function to install system-specific tools
install_system_tools() {
    local pkg_manager="$1"
    
    log_info "Installing system tools..."
    
    # Tree (for directory visualization)
    if command_exists tree; then
        log_success "Tree is installed"
    else
        log_warning "Tree not found. Installing..."
        install_packages "$pkg_manager" tree
    fi
    
    # GNU Stow
    if command_exists stow; then
        log_success "GNU Stow is installed"
    else
        log_warning "GNU Stow not found. Installing..."
        install_packages "$pkg_manager" stow
    fi
    
    # Starship prompt
    if command_exists starship; then
        log_success "Starship is installed"
    else
        log_warning "Starship not found. Installing..."
        install_packages "$pkg_manager" starship
    fi
}

# Function to install macOS-specific tools
install_macos_tools() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        log_info "Installing macOS-specific tools..."
        
        # Homebrew (if not already installed)
        if ! command_exists brew; then
            log_warning "Homebrew not found. Installing..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        
        # iTerm2 (optional)
        if [[ ! -d "/Applications/iTerm.app" ]]; then
            log_info "iTerm2 not found. You can install it with: brew install --cask iterm2"
        fi
        
        # Ghostty (if using)
        if command_exists ghostty; then
            log_success "Ghostty is installed"
        else
            log_info "Ghostty not found. You can install it with: brew install --cask ghostty"
        fi
    fi
}

# Function to install PowerShell (if on supported platform)
install_powershell() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if command_exists pwsh; then
            log_success "PowerShell is installed"
        else
            log_warning "PowerShell not found. Installing..."
            install_packages "brew" powershell
        fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command_exists pwsh; then
            log_success "PowerShell is installed"
        else
            log_warning "PowerShell not found. Please install manually from: https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell"
        fi
    fi
}

# Main installation process
main() {
    log_info "Starting dependency installation for dotfiles..."
    
    # Detect package manager
    local pkg_manager=$(detect_package_manager)
    if [[ "$pkg_manager" == "unknown" ]]; then
        log_error "No supported package manager found. Please install Homebrew, apt, yum, dnf, or pacman."
        exit 1
    fi
    
    log_info "Detected package manager: $pkg_manager"
    
    # Install dependencies
    install_shell_deps "$pkg_manager"
    install_dev_tools "$pkg_manager"
    install_system_tools "$pkg_manager"
    install_macos_tools
    install_powershell
    
    log_success "Dependency installation completed!"
    log_info "You can now run 'make stow-restore' to restore your dotfiles"
}

# Run main function
main "$@" 