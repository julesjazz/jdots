#!/bin/bash

# Backup Verification Script for jdots
# Verifies that stow packages are complete and accurate

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

echo -e "${BLUE}🔍 Backup Verification for jdots${NC}"
echo "====================================="

# Function to print status
print_status() {
    local status=$1
    local message=$2
    if [ "$status" -eq 0 ]; then
        echo -e "${GREEN}✅ $message${NC}"
    else
        echo -e "${RED}❌ $message${NC}"
    fi
}

# Function to print warning
print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Function to print info
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Initialize counters
issues_found=0
warnings_found=0

# Check if stow-packages directory exists
if [ ! -d "$REPO_ROOT/stow-packages" ]; then
    echo -e "${RED}❌ stow-packages directory not found${NC}"
    echo -e "${YELLOW}   Run 'make stow-backup' to create backup packages${NC}"
    exit 1
fi

echo -e "\n${BLUE}1. Checking stow package structure...${NC}"

# Check for expected packages
declare -a expected_packages=(
    "config"
    "home"
)

for package in "${expected_packages[@]}"; do
    if [ -d "$REPO_ROOT/stow-packages/$package" ]; then
        print_status 0 "$package package exists"
        
        # Count files in package
        file_count=$(find "$REPO_ROOT/stow-packages/$package" -type f | wc -l)
        if [ "$file_count" -gt 0 ]; then
            print_status 0 "$package package contains $file_count files"
        else
            print_warning "$package package is empty"
            ((warnings_found++))
        fi
    else
        print_status 1 "$package package missing"
        ((issues_found++))
    fi
done

echo -e "\n${BLUE}2. Checking for expected configurations...${NC}"

# Check for expected config directories in stow packages
declare -a expected_configs=(
          "config/zsh"
      "config/bash"
      "config/nushell"
      "config/nvim"
    "config/git"
    "config/starship.toml"
    "home/.aliases"
)

for config in "${expected_configs[@]}"; do
    if [ -e "$REPO_ROOT/stow-packages/$config" ]; then
        print_status 0 "$config exists in backup"
    else
        print_warning "$config not found in backup"
        ((warnings_found++))
    fi
done

echo -e "\n${BLUE}3. Comparing with live configurations...${NC}"

# Compare stow packages with live configs
if [ -d "$HOME/.config" ]; then
    print_info "Comparing stow packages with live .config directory..."
    
    # Get list of directories in live .config
    live_configs=$(find "$HOME/.config" -maxdepth 1 -type d -name ".*" -prune -o -type d -print | sed 's|.*/||' | sort)
    backup_configs=$(find "$REPO_ROOT/stow-packages/config" -maxdepth 1 -type d -name ".*" -prune -o -type d -print | sed 's|.*/||' | sort)
    
    # Find missing in backup
    missing_in_backup=0
    for config in $live_configs; do
        if [ -n "$config" ] && [ "$config" != "config" ]; then
            if [ ! -d "$REPO_ROOT/stow-packages/config/$config" ]; then
                echo -e "${YELLOW}  Warning: $config exists in live config but not in backup${NC}"
                ((warnings_found++))
                ((missing_in_backup++))
            fi
        fi
    done
    
    if [ "$missing_in_backup" -eq 0 ]; then
        print_status 0 "All live configs are backed up"
    else
        print_warning "Found $missing_in_backup config(s) missing from backup"
    fi
else
    print_warning "$HOME/.config directory not found"
    ((warnings_found++))
fi

echo -e "\n${BLUE}4. Checking file integrity...${NC}"

# Check for empty or corrupted files
empty_files=0
large_files=0

while IFS= read -r -d '' file; do
    if [ -f "$file" ]; then
        # Check for empty files
        if [ ! -s "$file" ]; then
            echo -e "${YELLOW}  Warning: Empty file: $file${NC}"
            ((warnings_found++))
            ((empty_files++))
        fi
        
        # Check for very large files (>10MB)
        size=$(stat -f "%z" "$file" 2>/dev/null || stat -c "%s" "$file" 2>/dev/null || echo "0")
        if [ "$size" -gt 10485760 ]; then  # 10MB in bytes
            echo -e "${YELLOW}  Warning: Large file: $file ($(numfmt --to=iec-i --suffix=B "$size"))${NC}"
            ((warnings_found++))
            ((large_files++))
        fi
    fi
done < <(find "$REPO_ROOT/stow-packages" -type f -print0 2>/dev/null || true)

if [ "$empty_files" -eq 0 ]; then
    print_status 0 "No empty files found"
else
    print_warning "Found $empty_files empty file(s)"
fi

if [ "$large_files" -eq 0 ]; then
    print_status 0 "No unexpectedly large files found"
else
    print_warning "Found $large_files large file(s)"
fi

echo -e "\n${BLUE}5. Checking backup timestamps...${NC}"

# Check when backup was last updated
if [ -d "$REPO_ROOT/stow-packages" ]; then
    backup_time=$(stat -f "%m" "$REPO_ROOT/stow-packages" 2>/dev/null || stat -c "%Y" "$REPO_ROOT/stow-packages" 2>/dev/null || echo "0")
    current_time=$(date +%s)
    time_diff=$((current_time - backup_time))
    
    if [ "$time_diff" -lt 86400 ]; then  # Less than 24 hours
        print_status 0 "Backup is recent (updated $(date -r "$backup_time" '+%Y-%m-%d %H:%M:%S'))"
    elif [ "$time_diff" -lt 604800 ]; then  # Less than 7 days
        print_warning "Backup is $(($time_diff / 86400)) days old"
        ((warnings_found++))
    else
        print_status 1 "Backup is very old ($(($time_diff / 86400)) days)"
        ((issues_found++))
    fi
fi

echo -e "\n${BLUE}6. Checking for sensitive files in backup...${NC}"

# Check for sensitive files that shouldn't be in backup
declare -a sensitive_patterns=(
    "*.key"
    "*.pem"
    "*.p12"
    "*.pfx"
    "*.crt"
    "*.csr"
    "*.env"
    "*history*"
    "*password*"
    "*secret*"
    "*token*"
)

sensitive_found=0
for pattern in "${sensitive_patterns[@]}"; do
    while IFS= read -r -d '' file; do
        if [ -f "$file" ]; then
            echo -e "${RED}  Error: Sensitive file found in backup: $file${NC}"
            ((issues_found++))
            ((sensitive_found++))
        fi
    done < <(find "$REPO_ROOT/stow-packages" -name "$pattern" -print0 2>/dev/null || true)
done

if [ "$sensitive_found" -eq 0 ]; then
    print_status 0 "No sensitive files found in backup"
else
    print_status 1 "Found $sensitive_found sensitive file(s) in backup"
fi

echo -e "\n${BLUE}7. Checking backup size...${NC}"

# Calculate backup size
if [ -d "$REPO_ROOT/stow-packages" ]; then
    backup_size=$(du -sh "$REPO_ROOT/stow-packages" 2>/dev/null | cut -f1)
    print_info "Backup size: $backup_size"
    
    # Check if backup is reasonable size (less than 100MB)
    size_bytes=$(du -sb "$REPO_ROOT/stow-packages" 2>/dev/null | cut -f1)
    if [ "$size_bytes" -lt 104857600 ]; then  # 100MB in bytes
        print_status 0 "Backup size is reasonable"
    else
        print_warning "Backup is very large ($backup_size)"
        ((warnings_found++))
    fi
fi

echo -e "\n${BLUE}📊 Backup Verification Summary${NC}"
echo "=================================="

if [ "$issues_found" -eq 0 ] && [ "$warnings_found" -eq 0 ]; then
    echo -e "${GREEN}🎉 Backup verification passed! All backups are complete and secure.${NC}"
    exit 0
elif [ "$issues_found" -eq 0 ]; then
    echo -e "${YELLOW}⚠️  Backup verification completed with $warnings_found warnings.${NC}"
    echo -e "${YELLOW}   Backups are functional but could be improved.${NC}"
    exit 0
else
    echo -e "${RED}❌ Backup verification failed with $issues_found issues and $warnings_found warnings.${NC}"
    echo -e "${RED}   Please address the issues above before relying on backups.${NC}"
    exit 1
fi 