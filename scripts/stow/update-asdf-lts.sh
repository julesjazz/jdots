#!/bin/bash
set -euo pipefail

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

# Function to update a tool to latest version
update_tool() {
    local tool=$1
    local version_pattern=$2
    
    log_info "Updating $tool..."
    
    # Get latest version
    local latest_version
    if [[ "$version_pattern" == "lts" ]]; then
        # For tools that support LTS keyword
        latest_version=$(asdf list all $tool | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | tail -1)
    else
        # For tools that need manual version detection
        latest_version=$(asdf list all $tool | grep -E "$version_pattern" | tail -1)
    fi
    
    if [[ -z "$latest_version" ]]; then
        log_warning "Could not determine latest version for $tool, skipping..."
        return 1
    fi
    
    # Install latest version
    if asdf install $tool $latest_version 2>/dev/null; then
        asdf set $tool $latest_version
        log_success "$tool updated to $latest_version"
    else
        log_warning "Failed to install $tool $latest_version, keeping current version"
    fi
}

log_info "Starting asdf tools update to latest LTS/stable versions..."

# Update asdf plugins first
log_info "Updating asdf plugins..."
asdf plugin update --all

# Update tools that support LTS keyword
update_tool "nodejs" "lts"

# Update tools that need manual version detection
update_tool "python" "^[0-9]+\.[0-9]+\.[0-9]+$"
update_tool "terraform" "^[0-9]+\.[0-9]+\.[0-9]+$"
update_tool "k9s" "^[0-9]+\.[0-9]+\.[0-9]+$"
update_tool "golang" "^[0-9]+\.[0-9]+\.[0-9]+$"
update_tool "rust" "^[0-9]+\.[0-9]+\.[0-9]+$"
update_tool "kubectl" "^[0-9]+\.[0-9]+\.[0-9]+$"
update_tool "helm" "^[0-9]+\.[0-9]+\.[0-9]+$"
update_tool "awscli" "^[0-9]+\.[0-9]+\.[0-9]+$"
update_tool "azure-cli" "^[0-9]+\.[0-9]+\.[0-9]+$"

# Reshim all tools
log_info "Reshimming asdf tools..."
asdf reshim

log_success "asdf tools update completed!"
echo ""
log_info "Current asdf tool versions:"
asdf current 