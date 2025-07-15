#!/bin/bash

# Package Filter Script
# Filters packages from package-list.txt based on platform and criteria

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_LIST="$SCRIPT_DIR/../system_packages/package-list.txt"

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

# Filter packages for specific platform
filter_packages() {
    local platform="$1"
    local output_file="$2"
    local include_notes="${3:-false}"
    
    if [[ ! -f "$PACKAGE_LIST" ]]; then
        print_error "Package list not found: $PACKAGE_LIST"
        exit 1
    fi
    
    print_status "Filtering packages for platform: $platform"
    
    # Create output file
    if [[ -n "$output_file" ]]; then
        > "$output_file"
        echo "# Filtered package list for $platform" >> "$output_file"
        echo "# Generated on: $(date)" >> "$output_file"
        echo "# Platform: $platform" >> "$output_file"
        echo "" >> "$output_file"
    fi
    
    local count=0
    
    while IFS= read -r line; do
        # Skip comments and empty lines
        if [[ "$line" =~ ^[[:space:]]*# ]] || [[ -z "${line// }" ]]; then
            if [[ "$include_notes" == "true" ]]; then
                echo "$line" >> "$output_file"
            fi
            continue
        fi
        
        # Skip section headers
        if [[ "$line" =~ ^[[:space:]]*= ]]; then
            if [[ "$include_notes" == "true" ]]; then
                echo "$line" >> "$output_file"
            fi
            continue
        fi
        
        # Parse package line: package_name [platforms] [notes]
        if [[ "$line" =~ ^[[:space:]]*([^[:space:]]+)[[:space:]]+([^[:space:]]+)(.*)$ ]]; then
            local package_name="${BASH_REMATCH[1]}"
            local platforms="${BASH_REMATCH[2]}"
            local notes="${BASH_REMATCH[3]}"
            
            # Check if package is available for this platform
            if [[ "$platforms" == "all" ]] || [[ "$platforms" == *"$platform"* ]]; then
                count=$((count + 1))
                if [[ -n "$output_file" ]]; then
                    echo "$package_name$notes" >> "$output_file"
                else
                    echo "$package_name$notes"
                fi
            fi
        fi
    done < "$PACKAGE_LIST"
    
    print_success "Found $count packages for $platform"
}

# Show available platforms
show_platforms() {
    echo "Available platforms:"
    echo "  macos   - macOS (Homebrew)"
    echo "  debian  - Debian/Ubuntu (APT)"
    echo "  redhat  - Fedora/RHEL (DNF/YUM)"
    echo "  all     - All platforms"
}

# Show help
show_help() {
    echo "📦 Package Filter Script"
    echo "========================"
    echo ""
    echo "Usage: $0 [OPTIONS] [PLATFORM]"
    echo ""
    echo "Options:"
    echo "  -o, --output FILE    Output to file instead of stdout"
    echo "  -n, --notes          Include comments and section headers"
    echo "  -p, --platforms      Show available platforms"
    echo "  -h, --help           Show this help message"
    echo ""
    echo "Platforms:"
    echo "  macos                Filter for macOS packages"
    echo "  debian               Filter for Debian/Ubuntu packages"
    echo "  redhat               Filter for Fedora/RHEL packages"
    echo "  all                  Show all packages"
    echo ""
    echo "Examples:"
    echo "  $0 macos                    # Show macOS packages"
    echo "  $0 -o macos-packages.txt macos  # Save to file"
    echo "  $0 -n debian                # Include comments"
    echo "  $0 --platforms              # Show available platforms"
    echo ""
}

# Main execution
main() {
    local platform=""
    local output_file=""
    local include_notes="false"
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -o|--output)
                output_file="$2"
                shift 2
                ;;
            -n|--notes)
                include_notes="true"
                shift
                ;;
            -p|--platforms)
                show_platforms
                exit 0
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            macos|debian|redhat|all)
                platform="$1"
                shift
                ;;
            *)
                print_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    if [[ -z "$platform" ]]; then
        # Auto-detect platform if not specified
        platform=$(get_os_family)
        if [[ "$platform" == "unknown" ]]; then
            print_error "Could not detect platform. Please specify platform manually."
            show_platforms
            exit 1
        fi
        print_status "Auto-detected platform: $platform"
    fi
    
    filter_packages "$platform" "$output_file" "$include_notes"
}

# Run main function
main "$@" 