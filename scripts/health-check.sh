#!/bin/bash

# Health Check Script for jdots
# Verifies that the dotfiles setup is working correctly

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

echo -e "${BLUE}🏥 Health Check for jdots${NC}"
echo "============================="

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

echo -e "\n${BLUE}1. Checking required tools...${NC}"

# Check for required commands
declare -a required_commands=(
    "git"
    "stow"
    "make"
    "bash"
    "zsh"
)

for cmd in "${required_commands[@]}"; do
    if command_exists "$cmd"; then
        print_status 0 "$cmd is available"
    else
        print_status 1 "$cmd is missing"
        ((issues_found++))
    fi
done

# Check for optional but recommended commands
declare -a optional_commands=(
    "fish"
    "nvim"
    "fzf"
    "fd"
    "rg"
    "tree"
    "starship"
)

for cmd in "${optional_commands[@]}"; do
    if command_exists "$cmd"; then
        print_status 0 "$cmd is available"
    else
        print_warning "$cmd is not installed (optional)"
        ((warnings_found++))
    fi
done

echo -e "\n${BLUE}2. Checking repository structure...${NC}"

# Check for required directories
declare -a required_dirs=(
    "scripts"
    "scripts/stow"
    "scripts/brewclean"
    "notes"
)

for dir in "${required_dirs[@]}"; do
    if [ -d "$REPO_ROOT/$dir" ]; then
        print_status 0 "$dir directory exists"
    else
        print_status 1 "$dir directory missing"
        ((issues_found++))
    fi
done

# Check for required files
declare -a required_files=(
    "Makefile"
    "README.md"
    ".gitignore"
    "scripts/stow/backup-config.sh"
    "scripts/stow/restore-config.sh"
    "scripts/stow/add-new-configs.sh"
    "scripts/stow/install-dependencies.sh"
    "scripts/brewclean/brewclean.sh"
)

for file in "${required_files[@]}"; do
    if [ -f "$REPO_ROOT/$file" ]; then
        print_status 0 "$file exists"
    else
        print_status 1 "$file missing"
        ((issues_found++))
    fi
done

echo -e "\n${BLUE}3. Checking script permissions...${NC}"

# Check if scripts are executable
declare -a script_files=(
    "scripts/stow/backup-config.sh"
    "scripts/stow/restore-config.sh"
    "scripts/stow/add-new-configs.sh"
    "scripts/stow/install-dependencies.sh"
    "scripts/brewclean/brewclean.sh"
    "scripts/security-audit.sh"
    "scripts/health-check.sh"
)

for script in "${script_files[@]}"; do
    if [ -f "$REPO_ROOT/$script" ]; then
        if [ -x "$REPO_ROOT/$script" ]; then
            print_status 0 "$script is executable"
        else
            print_warning "$script is not executable"
            ((warnings_found++))
        fi
    fi
done

echo -e "\n${BLUE}4. Checking stow packages...${NC}"

if [ -d "$REPO_ROOT/stow-packages" ]; then
    print_status 0 "stow-packages directory exists"
    
    # Count packages
    package_count=$(find "$REPO_ROOT/stow-packages" -maxdepth 1 -type d | wc -l)
    package_count=$((package_count - 1))  # Subtract 1 for the directory itself
    
    if [ "$package_count" -gt 0 ]; then
        print_status 0 "Found $package_count stow package(s)"
        
        # List packages
        echo "  Packages:"
        for package in "$REPO_ROOT/stow-packages"/*/; do
            if [ -d "$package" ]; then
                package_name=$(basename "$package")
                file_count=$(find "$package" -type f | wc -l)
                echo "    - $package_name ($file_count files)"
            fi
        done
    else
        print_warning "No stow packages found"
        ((warnings_found++))
    fi
else
    print_warning "stow-packages directory not found (run 'make stow-backup' to create)"
    ((warnings_found++))
fi

echo -e "\n${BLUE}5. Checking shell configurations...${NC}"

# Check if shell configs are properly linked
declare -a shell_configs=(
    "$HOME/.zshrc"
    "$HOME/.bashrc"
)

for config in "${shell_configs[@]}"; do
    if [ -f "$config" ]; then
        if [ -L "$config" ]; then
            print_status 0 "$config is a symlink"
        else
            print_status 0 "$config exists (not a symlink)"
        fi
    else
        print_warning "$config not found"
        ((warnings_found++))
    fi
done

# Check .config directory
if [ -d "$HOME/.config" ]; then
    print_status 0 "$HOME/.config directory exists"
    
    # Count symlinks in .config
    symlink_count=$(find "$HOME/.config" -maxdepth 1 -type l | wc -l)
    if [ "$symlink_count" -gt 0 ]; then
        print_status 0 "Found $symlink_count symlink(s) in .config"
    else
        print_warning "No symlinks found in .config"
        ((warnings_found++))
    fi
else
    print_warning "$HOME/.config directory not found"
    ((warnings_found++))
fi

echo -e "\n${BLUE}6. Checking Makefile targets...${NC}"

# Test if Makefile targets work
if [ -f "$REPO_ROOT/Makefile" ]; then
    # Test help target
    if make -f "$REPO_ROOT/Makefile" help >/dev/null 2>&1; then
        print_status 0 "Makefile help target works"
    else
        print_status 1 "Makefile help target failed"
        ((issues_found++))
    fi
    
    # Test stow-status target (if stow-packages exists)
    if [ -d "$REPO_ROOT/stow-packages" ]; then
        if make -f "$REPO_ROOT/Makefile" stow-status >/dev/null 2>&1; then
            print_status 0 "Makefile stow-status target works"
        else
            print_warning "Makefile stow-status target failed"
            ((warnings_found++))
        fi
    fi
else
    print_status 1 "Makefile not found"
    ((issues_found++))
fi

echo -e "\n${BLUE}7. Checking for common issues...${NC}"

# Check for broken symlinks
broken_symlinks=0
while IFS= read -r -d '' link; do
    if [ -L "$link" ] && [ ! -e "$link" ]; then
        echo -e "${YELLOW}  Warning: Broken symlink: $link${NC}"
        ((warnings_found++))
        ((broken_symlinks++))
    fi
done < <(find "$HOME/.config" -type l -print0 2>/dev/null || true)

if [ "$broken_symlinks" -eq 0 ]; then
    print_status 0 "No broken symlinks found"
else
    print_warning "Found $broken_symlinks broken symlink(s)"
fi

# Check for permission issues
if [ -d "$HOME/.config" ]; then
    if [ -r "$HOME/.config" ] && [ -w "$HOME/.config" ]; then
        print_status 0 ".config directory has proper permissions"
    else
        print_status 1 ".config directory has permission issues"
        ((issues_found++))
    fi
fi

echo -e "\n${BLUE}8. Checking for potential conflicts...${NC}"

# Check for conflicting files
declare -a potential_conflicts=(
    "$HOME/.zshrc.old"
    "$HOME/.bashrc.old"
    "$HOME/.config.old"
)

conflicts_found=0
for conflict in "${potential_conflicts[@]}"; do
    if [ -e "$conflict" ]; then
        echo -e "${YELLOW}  Warning: Potential conflict file: $conflict${NC}"
        ((warnings_found++))
        ((conflicts_found++))
    fi
done

if [ "$conflicts_found" -eq 0 ]; then
    print_status 0 "No obvious conflicts found"
fi

echo -e "\n${BLUE}📊 Health Check Summary${NC}"
echo "=========================="

if [ "$issues_found" -eq 0 ] && [ "$warnings_found" -eq 0 ]; then
    echo -e "${GREEN}🎉 Health check passed! Everything looks good.${NC}"
    echo -e "${GREEN}   Your jdots setup is healthy and ready to use.${NC}"
    exit 0
elif [ "$issues_found" -eq 0 ]; then
    echo -e "${YELLOW}⚠️  Health check completed with $warnings_found warnings.${NC}"
    echo -e "${YELLOW}   Your setup is functional but could be improved.${NC}"
    exit 0
else
    echo -e "${RED}❌ Health check failed with $issues_found issues and $warnings_found warnings.${NC}"
    echo -e "${RED}   Please address the issues above before using jdots.${NC}"
    echo -e "\n${BLUE}Suggested fixes:${NC}"
    echo -e "  - Run 'make stow-install-deps' to install missing dependencies"
    echo -e "  - Run 'make stow-backup' to create stow packages"
    echo -e "  - Run 'make stow-deploy' to deploy configurations"
    exit 1
fi 