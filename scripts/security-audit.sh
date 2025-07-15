#!/bin/bash

# Security Audit Script for jdots
# Checks for sensitive information in the repository

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

# Check if --source-only flag is provided
SOURCE_ONLY=false
if [[ "$*" == *"--source-only"* ]]; then
    SOURCE_ONLY=true
    echo -e "${BLUE}🔒 Security Audit for Source Directories Only${NC}"
    echo "================================================"
else
    echo -e "${BLUE}🔒 Security Audit for jdots${NC}"
    echo "=================================="
fi

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

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

# Set search directories based on flag
if [ "$SOURCE_ONLY" = true ]; then
    # Only check specific files/directories that will be backed up
    SEARCH_ITEMS=(
        "$HOME/.zshrc"
        "$HOME/.gitconfig" 
        "$HOME/.bashrc"
        "$HOME/.asdfrc"
        "$HOME/.config"
    )
    echo -e "\n${BLUE}Checking specific files/directories that will be backed up${NC}"
else
    SEARCH_DIRS=("$REPO_ROOT")
    echo -e "\n${BLUE}Checking entire repository${NC}"
fi

echo -e "\n${BLUE}1. Checking for sensitive patterns...${NC}"

# Patterns to search for
declare -a patterns=(
    "password"
    "secret"
    "key"
    "token"
    "api_key"
    "private_key"
    "access_token"
    "bearer"
    "authorization"
    "credential"
    "auth_token"
    "session_id"
    "cookie"
    "jwt"
    "ssh-rsa"
    "ssh-ed25519"
    "-----BEGIN"
    "-----END"
)

# Files to exclude from search
declare -a exclude_patterns=(
    "*.git*"
    "*.md"
    "*.txt"
    "*.log"
    "*.tmp"
    "*.cache"
    "node_modules"
    ".git"
    "stow-packages"
    "scripts/security-audit.sh"
    "scripts/verify-backup.sh"
    "notes/ide/settings.json"
    "notes/ide/UserRules"
)

# Build exclude string
exclude_string=""
for pattern in "${exclude_patterns[@]}"; do
    exclude_string="$exclude_string --exclude=$pattern"
done
# Add additional excludes for plugin, test, notes, and script directories
exclude_string="$exclude_string --exclude=stow-packages/config/zsh/plugins --exclude=stow-packages/config/nvim/lua/plugins --exclude=stow-packages/config/nvim/lua/config --exclude=notes --exclude=scripts/security-audit.sh --exclude=scripts/verify-backup.sh"

# Search for sensitive patterns
sensitive_found=false
if [ "$SOURCE_ONLY" = true ]; then
    # Check specific files and directories
    for item in "${SEARCH_ITEMS[@]}"; do
        if [ ! -e "$item" ]; then
            echo -e "${YELLOW}Warning: $item does not exist, skipping...${NC}"
            continue
        fi
        
        for pattern in "${patterns[@]}"; do
            if command_exists grep; then
                # Use grep to search for patterns (case insensitive)
                results=$(grep -r -i "$pattern" "$item" $exclude_string 2>/dev/null || true)
                if [ -n "$results" ]; then
                    # Filter out false positives
                    filtered_results=""
                    while IFS= read -r line; do
                        if [ -n "$line" ]; then
                            # Skip lines that are just comments or documentation
                            if [[ "$line" =~ ^[[:space:]]*# ]] || [[ "$line" =~ ^[[:space:]]*// ]] || [[ "$line" =~ ^[[:space:]]*/\* ]] || [[ "$line" =~ ^[[:space:]]*\* ]]; then
                                continue
                            fi
                            
                            # Skip lines that don't actually define sensitive values
                            # For "password", "secret", "key" - only flag if they look like assignments
                            if [[ "$pattern" =~ ^(password|secret|key)$ ]]; then
                                if [[ "$line" =~ [=:][[:space:]]*['\"]?[[:alnum:]]{8,}['\"]? ]] || [[ "$line" =~ [=:][[:space:]]*['\"]?[[:xdigit:]]{16,}['\"]? ]]; then
                                    filtered_results="${filtered_results}${line}"$'\n'
                                fi
                            # For other patterns, be more lenient but still check for assignments
                            elif [[ "$line" =~ [=:][[:space:]]*['\"]?[[:alnum:]]{8,}['\"]? ]] || [[ "$line" =~ [=:][[:space:]]*['\"]?[[:xdigit:]]{16,}['\"]? ]]; then
                                filtered_results="${filtered_results}${line}"$'\n'
                            fi
                        fi
                    done <<< "$results"
                    
                    if [ -n "$filtered_results" ]; then
                        echo -e "${RED}Found '$pattern' in $item:${NC}"
                        echo "$filtered_results" | while IFS= read -r line; do
                            if [ -n "$line" ]; then
                                echo "  $line"
                            fi
                        done
                        sensitive_found=true
                        ((issues_found++))
                    fi
                fi
            fi
        done
    done
else
    # Check entire repository
    for search_dir in "${SEARCH_DIRS[@]}"; do
        if [ ! -d "$search_dir" ]; then
            echo -e "${YELLOW}Warning: Directory $search_dir does not exist, skipping...${NC}"
            continue
        fi
        
        for pattern in "${patterns[@]}"; do
            if command_exists grep; then
                # Use grep to search for patterns (case insensitive)
                results=$(grep -r -i "$pattern" "$search_dir" $exclude_string 2>/dev/null || true)
                if [ -n "$results" ]; then
                    # Filter out false positives
                    filtered_results=""
                    while IFS= read -r line; do
                        if [ -n "$line" ]; then
                            # Skip lines that are just comments or documentation
                            if [[ "$line" =~ ^[[:space:]]*# ]] || [[ "$line" =~ ^[[:space:]]*// ]] || [[ "$line" =~ ^[[:space:]]*/\* ]] || [[ "$line" =~ ^[[:space:]]*\* ]]; then
                                continue
                            fi
                            
                            # Skip lines that don't actually define sensitive values
                            # For "password", "secret", "key" - only flag if they look like assignments
                            if [[ "$pattern" =~ ^(password|secret|key)$ ]]; then
                                if [[ "$line" =~ [=:][[:space:]]*['\"]?[[:alnum:]]{8,}['\"]? ]] || [[ "$line" =~ [=:][[:space:]]*['\"]?[[:xdigit:]]{16,}['\"]? ]]; then
                                    filtered_results="${filtered_results}${line}"$'\n'
                                fi
                            # For other patterns, be more lenient but still check for assignments
                            elif [[ "$line" =~ [=:][[:space:]]*['\"]?[[:alnum:]]{8,}['\"]? ]] || [[ "$line" =~ [=:][[:space:]]*['\"]?[[:xdigit:]]{16,}['\"]? ]]; then
                                filtered_results="${filtered_results}${line}"$'\n'
                            fi
                        fi
                    done <<< "$results"
                    
                    if [ -n "$filtered_results" ]; then
                        echo -e "${RED}Found '$pattern' in $search_dir:${NC}"
                        echo "$filtered_results" | while IFS= read -r line; do
                            if [ -n "$line" ]; then
                                echo "  $line"
                            fi
                        done
                        sensitive_found=true
                        ((issues_found++))
                    fi
                fi
            fi
        done
    done
fi

if [ "$sensitive_found" = false ]; then
    print_status 0 "No sensitive patterns found"
else
    print_status 1 "Sensitive patterns found - review above"
fi

# Only run full repository checks if not in source-only mode
if [ "$SOURCE_ONLY" = false ]; then
    echo -e "\n${BLUE}2. Checking file permissions...${NC}"

    # Check for overly permissive files
    permissive_files=0
    while IFS= read -r -d '' file; do
        if [ -f "$file" ]; then
            perms=$(stat -f "%Lp" "$file" 2>/dev/null || stat -c "%a" "$file" 2>/dev/null || echo "000")
            if [[ "$perms" == *"777"* ]] || [[ "$perms" == *"666"* ]]; then
                echo -e "${YELLOW}  Warning: $file has permissive permissions ($perms)${NC}"
                ((warnings_found++))
                ((permissive_files++))
            fi
        fi
    done < <(find "$REPO_ROOT" -type f -name "*.sh" -print0 2>/dev/null || true)

    if [ "$permissive_files" -eq 0 ]; then
        print_status 0 "Script permissions are appropriate"
    else
        print_warning "Found $permissive_files files with permissive permissions"
    fi

    echo -e "\n${BLUE}3. Checking for executable files...${NC}"

    # Check for unexpected executable files
    executable_files=0
    while IFS= read -r -d '' file; do
        if [ -f "$file" ]; then
            # Skip expected executable files, git hooks, and forgit plugin executables
            if [[ "$file" == *.sh ]] || [[ "$file" == *.py ]] || [[ "$file" == *.pl ]] || \
               [[ "$file" == */.git/hooks/*.sample ]] || [[ "$file" == */bin/* ]] || \
               [[ "$file" == */run-tests.zsh ]] || [[ "$file" == */test-*.zsh ]] || \
               [[ "$file" == */generate.zsh ]] || [[ "$file" == */tap-* ]] || \
               [[ "$file" == */edit-failed-tests ]] || [[ "$file" == */test-zprof.zsh ]] || \
               [[ "$file" == */forgit/forgit.plugin.zsh ]] || [[ "$file" == */forgit/completions/git-forgit.bash ]]; then
                continue
            fi
            if [ -x "$file" ]; then
                echo -e "${YELLOW}  Warning: Unexpected executable file: $file${NC}"
                ((warnings_found++))
                ((executable_files++))
            fi
        fi
    done < <(find "$REPO_ROOT" -type f -print0 2>/dev/null || true)

    if [ "$executable_files" -eq 0 ]; then
        print_status 0 "No unexpected executable files found"
    else
        print_warning "Found $executable_files unexpected executable files"
    fi

    echo -e "\n${BLUE}4. Checking .gitignore coverage...${NC}"
    
    # Check if .gitignore exists
    if [ -f "$REPO_ROOT/.gitignore" ]; then
        print_status 0 ".gitignore file exists"
    else
        print_status 1 ".gitignore file missing"
        ((issues_found++))
    fi

    # Check for specific patterns in .gitignore
    if [ -f "$REPO_ROOT/.gitignore" ]; then
        if grep -q "\.history\|\.zsh_history\|\.bash_history" "$REPO_ROOT/.gitignore" 2>/dev/null; then
            print_status 0 "History files are ignored"
        else
            print_warning "History files not in .gitignore"
            ((warnings_found++))
        fi

        if grep -q "octopus\|api.*key" "$REPO_ROOT/.gitignore" 2>/dev/null; then
            print_status 0 "Octopus config is ignored"
        else
            print_warning "Octopus config not in .gitignore"
            ((warnings_found++))
        fi
    fi

    echo -e "\n${BLUE}5. Checking for large files...${NC}"
    
    # Check for unexpectedly large files (>10MB)
    large_files=0
    while IFS= read -r -d '' file; do
        if [ -f "$file" ]; then
            size=$(stat -f "%z" "$file" 2>/dev/null || stat -c "%s" "$file" 2>/dev/null || echo "0")
            if [ "$size" -gt 10485760 ]; then  # 10MB in bytes
                echo -e "${YELLOW}  Warning: Large file found: $file ($(numfmt --to=iec-i --suffix=B "$size"))${NC}"
                ((warnings_found++))
                ((large_files++))
            fi
        fi
    done < <(find "$REPO_ROOT" -type f -size +10M -print0 2>/dev/null || true)

    if [ "$large_files" -eq 0 ]; then
        print_status 0 "No unexpectedly large files found"
    else
        print_warning "Found $large_files large files"
    fi

    echo -e "\n${BLUE}6. Checking for symlinks...${NC}"
    
    # Check for broken symlinks
    broken_symlinks=0
    while IFS= read -r -d '' file; do
        if [ -L "$file" ] && [ ! -e "$file" ]; then
            echo -e "${YELLOW}  Warning: Broken symlink found: $file${NC}"
            ((warnings_found++))
            ((broken_symlinks++))
        fi
    done < <(find "$REPO_ROOT" -type l -print0 2>/dev/null || true)

    if [ "$broken_symlinks" -eq 0 ]; then
        print_status 0 "No broken symlinks found"
    else
        print_warning "Found $broken_symlinks broken symlinks"
    fi

    echo -e "\n${BLUE}7. Checking for hidden files...${NC}"
    
    # Check for hidden files (might indicate secrets)
    hidden_files=0
    hidden_file_list=""
    while IFS= read -r -d '' file; do
        if [ -f "$file" ]; then
            basename_file=$(basename "$file")
            if [[ "$basename_file" == .* ]]; then
                echo -e "${YELLOW}  Warning: Hidden file found: $file${NC}"
                hidden_file_list="${hidden_file_list}  $file${NC}"$'\n'
                ((warnings_found++))
                ((hidden_files++))
            fi
        fi
    done < <(find "$REPO_ROOT" -type f -name ".*" -print0 2>/dev/null || true)

    if [ "$hidden_files" -eq 0 ]; then
        print_status 0 "No hidden files found"
    else
        print_warning "Found $hidden_files hidden files"
        if [ "$SOURCE_ONLY" = true ]; then
            echo -e "\n${BLUE}Hidden files found in source directories. These are likely dotfiles and may be safe to backup.${NC}"
            echo -e "${YELLOW}Hidden files:${NC}"
            echo "$hidden_file_list"
            echo -e "${BLUE}Proceeding with backup (hidden files are expected for dotfiles)...${NC}"
        fi
    fi
fi

# Summary
echo -e "\n📊 Security Audit Summary"
echo "=========================="
if [ "$issues_found" -eq 0 ] && [ "$warnings_found" -eq 0 ]; then
    echo -e "${GREEN}✅ Security audit passed with no issues.${NC}"
elif [ "$issues_found" -eq 0 ]; then
    echo -e "${YELLOW}⚠️  Security audit completed with $warnings_found warnings.${NC}"
    echo "   Review the warnings above and address as needed."
else
    echo -e "${RED}❌ Security audit failed with $issues_found issues and $warnings_found warnings.${NC}"
    echo "   Address the issues above before proceeding."
    exit 1
fi 