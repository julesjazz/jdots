#!/bin/bash

# Brew List Rename Script
# This script helps rename existing brewlist files to match the new hostname format

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOSTNAME=$(hostname | sed 's/\.local.*$//')
OLD_HOSTNAME=$(hostname)

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

echo "🔄 Brew List Rename Helper"
echo "=========================="
echo ""

print_status "Full hostname: $OLD_HOSTNAME"
print_status "Clean hostname: $HOSTNAME"
echo ""

# Check for existing files
OLD_FILE="$SCRIPT_DIR/brewlist-${OLD_HOSTNAME}.txt"
NEW_FILE="$SCRIPT_DIR/brewlist-${HOSTNAME}.txt"

if [[ -f "$OLD_FILE" ]]; then
    print_status "Found old format file: $(basename "$OLD_FILE")"
    
    if [[ -f "$NEW_FILE" ]]; then
        print_warning "New format file already exists: $(basename "$NEW_FILE")"
        echo ""
        echo "Options:"
        echo "1. Keep both files"
        echo "2. Replace new file with old file content"
        echo "3. Merge content from old file into new file"
        echo "4. Delete old file"
        echo ""
        read -p "Choose option (1-4): " -n 1 -r
        echo ""
        
        case $REPLY in
            1)
                print_success "Keeping both files"
                ;;
            2)
                print_status "Replacing new file with old file content..."
                cp "$OLD_FILE" "$NEW_FILE"
                print_success "Replaced $(basename "$NEW_FILE") with content from $(basename "$OLD_FILE")"
                ;;
            3)
                print_status "Merging content..."
                # This would require more complex logic to merge the changelog
                print_warning "Manual merge required - please review both files"
                ;;
            4)
                print_status "Deleting old file..."
                rm "$OLD_FILE"
                print_success "Deleted $(basename "$OLD_FILE")"
                ;;
            *)
                print_error "Invalid option"
                exit 1
                ;;
        esac
    else
        print_status "Renaming file to new format..."
        mv "$OLD_FILE" "$NEW_FILE"
        print_success "Renamed $(basename "$OLD_FILE") to $(basename "$NEW_FILE")"
    fi
else
    print_status "No old format file found"
fi

echo ""
print_status "Current brew list files:"
ls -la "$SCRIPT_DIR"/brewlist-*.txt 2>/dev/null || echo "No brewlist files found"

echo ""
print_success "Rename helper completed!" 