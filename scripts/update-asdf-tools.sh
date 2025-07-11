#!/bin/bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
DRY_RUN=false
UPDATE_PLUGINS=true
SELECTIVE_UPDATE=false
TOOLS_TO_UPDATE=""

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

# Show usage
show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Update asdf tools to latest LTS/stable versions.

OPTIONS:
    -d, --dry-run          Show what would be updated without making changes
    -p, --no-plugins       Skip updating asdf plugins
    -s, --selective TOOLS  Update only specific tools (comma-separated)
    -h, --help             Show this help message

EXAMPLES:
    $0                      # Update all tools
    $0 --dry-run           # Show what would be updated
    $0 --selective "nodejs,python"  # Update only nodejs and python
    $0 --no-plugins        # Update tools without updating plugins

AVAILABLE TOOLS:
    nodejs, python, terraform, k9s, golang, rust, kubectl, helm, awscli, azure-cli
EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -p|--no-plugins)
            UPDATE_PLUGINS=false
            shift
            ;;
        -s|--selective)
            SELECTIVE_UPDATE=true
            TOOLS_TO_UPDATE="$2"
            shift 2
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Function to update a tool to latest version
update_tool() {
    local tool=$1
    local version_pattern=$2
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "Would update $tool..."
        local latest_version
        if [[ "$version_pattern" == "lts" ]]; then
            latest_version=$(asdf list all $tool | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | tail -1)
        else
            latest_version=$(asdf list all $tool | grep -E "$version_pattern" | tail -1)
        fi
        log_info "  Latest version: $latest_version"
        return 0
    fi
    
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

# Define all available tools
declare -A TOOL_PATTERNS=(
    ["nodejs"]="lts"
    ["python"]="^[0-9]+\.[0-9]+\.[0-9]+$"
    ["terraform"]="^[0-9]+\.[0-9]+\.[0-9]+$"
    ["k9s"]="^[0-9]+\.[0-9]+\.[0-9]+$"
    ["golang"]="^[0-9]+\.[0-9]+\.[0-9]+$"
    ["rust"]="^[0-9]+\.[0-9]+\.[0-9]+$"
    ["kubectl"]="^[0-9]+\.[0-9]+\.[0-9]+$"
    ["helm"]="^[0-9]+\.[0-9]+\.[0-9]+$"
    ["awscli"]="^[0-9]+\.[0-9]+\.[0-9]+$"
    ["azure-cli"]="^[0-9]+\.[0-9]+\.[0-9]+$"
)

# Main execution
main() {
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "DRY RUN MODE - No changes will be made"
        echo ""
    fi
    
    log_info "Starting asdf tools update to latest LTS/stable versions..."
    
    # Update asdf plugins first
    if [[ "$UPDATE_PLUGINS" == "true" ]]; then
        if [[ "$DRY_RUN" == "true" ]]; then
            log_info "Would update asdf plugins..."
        else
            log_info "Updating asdf plugins..."
            asdf plugin update --all
        fi
    else
        log_info "Skipping plugin updates..."
    fi
    
    echo ""
    
    # Determine which tools to update
    local tools_to_process
    if [[ "$SELECTIVE_UPDATE" == "true" ]]; then
        IFS=',' read -ra tools_to_process <<< "$TOOLS_TO_UPDATE"
    else
        tools_to_process=("nodejs" "python" "terraform" "k9s" "golang" "rust" "kubectl" "helm" "awscli" "azure-cli")
    fi
    
    # Update each tool
    for tool in "${tools_to_process[@]}"; do
        if [[ -n "${TOOL_PATTERNS[$tool]:-}" ]]; then
            update_tool "$tool" "${TOOL_PATTERNS[$tool]}"
        else
            log_warning "Unknown tool: $tool"
        fi
    done
    
    # Reshim all tools
    if [[ "$DRY_RUN" == "false" ]]; then
        echo ""
        log_info "Reshimming asdf tools..."
        asdf reshim
    fi
    
    log_success "asdf tools update completed!"
    echo ""
    log_info "Current asdf tool versions:"
    asdf current
}

# Run main function
main "$@" 