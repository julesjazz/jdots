#!/bin/bash

# Brew List Sync Script
# This script manages the synchronization between master and computer-specific brew lists

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

# Function to extract formulas and casks from a brew list file
extract_packages_from_file() {
    local file_path="$1"
    local formulas=""
    local casks=""
    
    if [[ -f "$file_path" ]]; then
        formulas=$(awk '/^# Brew formulas/,/^# Brew Casks/ {if ($0 !~ /^#/ && NF > 0) print $1}' "$file_path" | sort -u)
        casks=$(awk '/^# Brew Casks/,/^$/ {if ($0 !~ /^#/ && NF > 0) print $1}' "$file_path" | sort -u)
        
        # Remove empty lines
        formulas=$(echo "$formulas" | grep -v '^$' | sort -u)
        casks=$(echo "$casks" | grep -v '^$' | sort -u)
    fi
    
    echo "$formulas"
    echo "$casks"
}

# Function to sync computer list to master
sync_to_master() {
    print_status "Syncing computer list to master..."
    
    if [[ ! -f "$COMPUTER_BREW_LIST_PATH" ]]; then
        print_error "Computer brew list not found: $COMPUTER_BREW_LIST_PATH"
        return 1
    fi
    
    # Extract packages from computer list
    read -r computer_formulas computer_casks < <(extract_packages_from_file "$COMPUTER_BREW_LIST_PATH")
    
    # Extract packages from master list
    read -r master_formulas master_casks < <(extract_packages_from_file "$MASTER_BREW_LIST_PATH")
    
    # Find new packages in computer list
    new_formulas=$(comm -13 <(echo "$master_formulas") <(echo "$computer_formulas"))
    new_casks=$(comm -13 <(echo "$master_casks") <(echo "$computer_casks"))
    
    if [[ -n "$new_formulas" || -n "$new_casks" ]]; then
        print_status "Found new packages to add to master list:"
        if [[ -n "$new_formulas" ]]; then
            echo "Formulas:"
            echo "$new_formulas" | sed 's/^/  - /'
        fi
        if [[ -n "$new_casks" ]]; then
            echo "Casks:"
            echo "$new_casks" | sed 's/^/  - /'
        fi
        
        # Merge packages
        merged_formulas=$(echo -e "$master_formulas\n$new_formulas" | sort -u | grep -v '^$')
        merged_casks=$(echo -e "$master_casks\n$new_casks" | sort -u | grep -v '^$')
        
        # Create new master list
        {
            echo "# Brew Cleanup - $(date)"
            echo "## Master List - Updated from $HOSTNAME"
            echo ""
            if [[ -n "$new_formulas" || -n "$new_casks" ]]; then
                echo "## Added from $HOSTNAME"
                if [[ -n "$new_formulas" ]]; then
                    echo "### Formulas"
                    echo "$new_formulas" | sed 's/^/- /'
                    echo ""
                fi
                if [[ -n "$new_casks" ]]; then
                    echo "### Casks"
                    echo "$new_casks" | sed 's/^/- /'
                    echo ""
                fi
                echo "---"
                echo ""
            fi
            echo "# Brew formulas ----------------------------------------"
            echo ""
            echo "$merged_formulas" | column -c 1
            echo ""
            echo "# Brew Casks ----------------------------------------"
            echo ""
            echo "$merged_casks" | column -c 1
            echo ""
            echo "# Generated on: $(date)"
            echo "# Updated from: $HOSTNAME"
        } > "$MASTER_BREW_LIST_PATH"
        
        print_success "Master list updated with new packages from $HOSTNAME"
    else
        print_success "No new packages to sync to master"
    fi
}

# Function to sync master list to computer
sync_from_master() {
    print_status "Syncing master list to computer..."
    
    if [[ ! -f "$MASTER_BREW_LIST_PATH" ]]; then
        print_error "Master brew list not found: $MASTER_BREW_LIST_PATH"
        return 1
    fi
    
    # Extract packages from master list
    read -r master_formulas master_casks < <(extract_packages_from_file "$MASTER_BREW_LIST_PATH")
    
    # Extract packages from computer list
    read -r computer_formulas computer_casks < <(extract_packages_from_file "$COMPUTER_BREW_LIST_PATH")
    
    # Find missing packages in computer list
    missing_formulas=$(comm -23 <(echo "$master_formulas") <(echo "$computer_formulas"))
    missing_casks=$(comm -23 <(echo "$master_casks") <(echo "$computer_casks"))
    
    if [[ -n "$missing_formulas" || -n "$missing_casks" ]]; then
        print_status "Found packages in master list that are missing from computer list:"
        if [[ -n "$missing_formulas" ]]; then
            echo "Formulas:"
            echo "$missing_formulas" | sed 's/^/  - /'
        fi
        if [[ -n "$missing_casks" ]]; then
            echo "Casks:"
            echo "$missing_casks" | sed 's/^/  - /'
        fi
        
        # Merge packages
        merged_formulas=$(echo -e "$computer_formulas\n$missing_formulas" | sort -u | grep -v '^$')
        merged_casks=$(echo -e "$computer_casks\n$missing_casks" | sort -u | grep -v '^$')
        
        # Create new computer list
        {
            echo "# Brew Cleanup - $(date)"
            echo "## Computer: $HOSTNAME - Updated from Master"
            echo ""
            if [[ -n "$missing_formulas" || -n "$missing_casks" ]]; then
                echo "## Added from Master"
                if [[ -n "$missing_formulas" ]]; then
                    echo "### Formulas"
                    echo "$missing_formulas" | sed 's/^/- /'
                    echo ""
                fi
                if [[ -n "$missing_casks" ]]; then
                    echo "### Casks"
                    echo "$missing_casks" | sed 's/^/- /'
                    echo ""
                fi
                echo "---"
                echo ""
            fi
            echo "# Brew formulas ----------------------------------------"
            echo ""
            echo "$merged_formulas" | column -c 1
            echo ""
            echo "# Brew Casks ----------------------------------------"
            echo ""
            echo "$merged_casks" | column -c 1
            echo ""
            echo "# Generated on: $(date)"
            echo "# Computer: $HOSTNAME"
            echo "# Synced from: Master"
        } > "$COMPUTER_BREW_LIST_PATH"
        
        print_success "Computer list updated with packages from master"
    else
        print_success "Computer list is already up to date with master"
    fi
}

# Function to show differences between lists
show_differences() {
    print_status "Comparing master and computer brew lists..."
    
    if [[ ! -f "$MASTER_BREW_LIST_PATH" ]]; then
        print_error "Master brew list not found"
        return 1
    fi
    
    if [[ ! -f "$COMPUTER_BREW_LIST_PATH" ]]; then
        print_error "Computer brew list not found"
        return 1
    fi
    
    # Extract packages
    read -r master_formulas master_casks < <(extract_packages_from_file "$MASTER_BREW_LIST_PATH")
    read -r computer_formulas computer_casks < <(extract_packages_from_file "$COMPUTER_BREW_LIST_PATH")
    
    # Find differences
    master_only_formulas=$(comm -23 <(echo "$master_formulas") <(echo "$computer_formulas"))
    computer_only_formulas=$(comm -13 <(echo "$master_formulas") <(echo "$computer_formulas"))
    master_only_casks=$(comm -23 <(echo "$master_casks") <(echo "$computer_casks"))
    computer_only_casks=$(comm -13 <(echo "$master_casks") <(echo "$computer_casks"))
    
    echo ""
    echo "📊 Differences between Master and $HOSTNAME:"
    echo "============================================="
    echo ""
    
    if [[ -n "$master_only_formulas" ]]; then
        echo "📦 Formulas only in Master:"
        echo "$master_only_formulas" | sed 's/^/  - /'
        echo ""
    fi
    
    if [[ -n "$computer_only_formulas" ]]; then
        echo "📦 Formulas only in $HOSTNAME:"
        echo "$computer_only_formulas" | sed 's/^/  - /'
        echo ""
    fi
    
    if [[ -n "$master_only_casks" ]]; then
        echo "🍺 Casks only in Master:"
        echo "$master_only_casks" | sed 's/^/  - /'
        echo ""
    fi
    
    if [[ -n "$computer_only_casks" ]]; then
        echo "🍺 Casks only in $HOSTNAME:"
        echo "$computer_only_casks" | sed 's/^/  - /'
        echo ""
    fi
    
    if [[ -z "$master_only_formulas$computer_only_formulas$master_only_casks$computer_only_casks" ]]; then
        print_success "No differences found between master and computer lists"
    fi
}

# Function to list all brew list files
list_brew_lists() {
    print_status "Available brew list files:"
    print_status "Detected hostname: $HOSTNAME"
    echo ""
    
    if [[ -f "$MASTER_BREW_LIST_PATH" ]]; then
        echo "📄 Master: $(basename "$MASTER_BREW_LIST_PATH")"
    else
        echo "❌ Master: $(basename "$MASTER_BREW_LIST_PATH") (not found)"
    fi
    
    # Find all computer-specific files
    for file in "$SCRIPT_DIR"/brewlist-*.txt; do
        if [[ -f "$file" ]]; then
            computer_name=$(basename "$file" .txt | sed 's/brewlist-//')
            if [[ "$computer_name" == "$HOSTNAME" ]]; then
                echo "💻 Current: $(basename "$file") ($computer_name)"
            else
                echo "💻 Other: $(basename "$file") ($computer_name)"
            fi
        fi
    done
    
    echo ""
}

# Function to show help
show_help() {
    echo "🍺 Brew List Sync Script"
    echo "========================"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  to-master     - Sync computer list to master (add new packages)"
    echo "  from-master   - Sync master list to computer (add missing packages)"
    echo "  diff          - Show differences between master and computer lists"
    echo "  list          - List all available brew list files"
    echo "  help          - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 to-master     # Add new packages from this computer to master"
    echo "  $0 from-master   # Get missing packages from master"
    echo "  $0 diff          # Compare master and computer lists"
    echo ""
}

# Main execution
main() {
    case "${1:-help}" in
        "to-master")
            sync_to_master
            ;;
        "from-master")
            sync_from_master
            ;;
        "diff")
            show_differences
            ;;
        "list")
            list_brew_lists
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            print_error "Unknown command: $1"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@" 