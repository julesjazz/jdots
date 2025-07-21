#!/bin/bash

# Simple filetype scanner using tree command
# Usage: ./scan-filetypes.sh [directory]
# Usage: ./scan-filetypes.sh [directory] --debug   (for troubleshooting)
# Outputs to: ./temp/filetypes.txt (creates directory and file if needed)
# Requires: tree command (usually available via: brew install tree or apt install tree)
# Ignores common module/cache directories and shows progress when run in terminal

# Unified ignore patterns for both tree command and safety checks
IGNORE_PATTERNS=(
    # Development and build artifacts
    "node_modules"
    "venv"
    ".venv"
    "env"
    ".env"
    "__pycache__"
    ".pytest_cache"
    ".mypy_cache"
    ".tox"
    "dist"
    "build"
    ".terraform"
    ".npm"
    ".yarn"
    ".pnpm"
    "site-packages"
    "*.egg-info"
    ".next"
    ".nuxt"
    "coverage"
    ".coverage"
    
    # Version control
    ".git"
    ".svn"
    ".hg"
    
    # System and cache files
    ".DS_Store"
    "tmp"
    "temp"
    ".tmp"
    ".temp"
    ".cache"
    "cache"
    
    # Timestamp patterns
    "????????-??????"
    "agenda-????-??-??"
)

# Dangerous system directories that should never be scanned
DANGEROUS_DIRS=(
    "/"
    "/bin"
    "/boot"
    "/dev"
    "/etc"
    "/lib"
    "/lib64"
    "/lost+found"
    "/media"
    "/mnt"
    "/opt"
    "/proc"
    "/root"
    "/run"
    "/sbin"
    "/srv"
    "/sys"
    "/tmp"
    "/usr"
    "/var"
    "/System"
    "/Library"
    "/Applications"
    "/private"
    "/usr/bin"
    "/usr/sbin"
    "/usr/lib"
    "/usr/libexec"
    "/usr/share"
    "/usr/local"
)

# Convert arrays to pipe-separated strings for tree command
TREE_IGNORE_STRING=$(IFS='|'; echo "${IGNORE_PATTERNS[*]}")

# Debug function
debug_tree_output() {
    local dir="${1:-.}"
    
    echo "=== DEBUG: Raw tree output (first 10 lines) ===" >&2
    tree "$dir" -a -f -i --noreport \
        -I "$TREE_IGNORE_STRING" \
        | head -10 >&2
    
    echo "=== DEBUG: After processing (first 10 lines) ===" >&2
    tree "$dir" -a -f -i --noreport \
        -I "$TREE_IGNORE_STRING" \
        | grep -v "^$" \
        | grep -v "^[[:space:]]*$" \
        | while IFS= read -r filepath; do
            filename=$(basename "$filepath")
            echo "$filename"
        done | head -10 >&2
}

scan_filetypes() {
    local dir="${1:-.}"
    
    # Show updated analysis message with count and estimate
    local total_files=$(find "$dir" -type f 2>/dev/null | wc -l)
    local est_seconds=$(echo "$total_files * 0.01" | bc 2>/dev/null || echo "$total_files" | awk '{print $1 * 0.01}')
    echo "Found $total_files files, est $est_seconds seconds processing..." >&2
    
    # Check if tree is available
    if ! command -v tree &> /dev/null; then
        echo "Error: tree command not found. Install with: brew install tree" >&2
        exit 1
    fi
    
    # Create temporary files
    local temp_file=$(mktemp)
    local processed_file=$(mktemp)
    
    # Use tree to get all files, ignoring common directories and timestamp files
    # Use -f for full paths, then extract just the filename
    tree "$dir" -a -f -i --noreport \
        -I "$TREE_IGNORE_STRING" \
        2>/dev/null > "$temp_file"
    
    # Process the tree output to extract filenames
    while IFS= read -r line; do
        # Skip empty lines and directory entries
        [[ -z "$line" ]] && continue
        [[ "$line" =~ ^[[:space:]]*$ ]] && continue
        
        # Extract the filepath from tree output (remove leading spaces and tree characters)
        filepath=$(echo "$line" | sed 's/^[[:space:]]*[├│└]── //')
        
        # Skip if empty or looks like a directory (ends with /)
        [[ -z "$filepath" ]] && continue
        [[ "$filepath" =~ /$ ]] && continue
        
        # Check if it's actually a file (not a directory)
        if [[ -f "$filepath" ]]; then
            filename=$(basename "$filepath" 2>/dev/null)
            [[ -n "$filename" ]] && echo "$filename"
        fi
    done < "$temp_file" > "$processed_file"
    
    # Check if we got any files
    if [[ ! -s "$processed_file" ]]; then
        echo "No files found or tree command failed" >&2
        rm -f "$temp_file" "$processed_file"
        exit 1
    fi
    
    # Create a new temp file for the final processed results
    local final_file=$(mktemp)
    
    # Process each filename to extract file types
    while IFS= read -r filename; do
        # Skip empty lines
        [[ -z "$filename" ]] && continue
        
        # Skip files that look like hashes (32+ hex characters)
        if [[ "$filename" =~ ^[0-9a-f]{32,}$ ]]; then
            continue
        fi
        
        # Skip files that look like timestamps (YYYYMMDD-HHMMSS pattern)
        if [[ "$filename" =~ ^[0-9]{8}-[0-9]{6}$ ]]; then
            continue
        fi
        
        # Handle dotfiles like .gitignore (starts with dot, only one dot)
        if [[ "$filename" =~ ^\..*$ ]] && [[ $(echo "$filename" | grep -o '\.' | wc -l) -eq 1 ]]; then
            echo "$filename"
        # Handle files without extension (no dots at all)
        elif [[ ! "$filename" =~ \. ]]; then
            echo "$filename"
        # Handle files with extension
        else
            echo "${filename##*.}"
        fi
    done < "$processed_file" > "$final_file"
    
    # Check if processing produced any results
    if [[ ! -s "$final_file" ]]; then
        echo "No file types found after processing" >&2
        rm -f "$temp_file" "$processed_file" "$final_file"
        exit 1
    fi
    
    # Create temp directory if it doesn't exist
    mkdir -p ./temp
    
    # Sort and remove duplicates, output to file
    sort -u "$final_file" > ./temp/filetypes.txt
    
    if [[ -t 1 ]]; then
        local unique_types=$(sort -u "$final_file" | wc -l)
        echo "Done! Found $unique_types unique file types. Output saved to ./temp/filetypes.txt" >&2
    fi
    
    # Clean up
    rm -f "$temp_file" "$processed_file" "$final_file"
}

# Safety check function
check_dangerous_directory() {
    local dir="$1"
    local real_path=$(realpath "$dir" 2>/dev/null || echo "$dir")
    
    # Check if directory is in dangerous list
    for dangerous in "${DANGEROUS_DIRS[@]}"; do
        if [[ "$real_path" == "$dangerous" || "$real_path" == "$dangerous/"* ]]; then
            echo "Error: Refusing to scan system directory '$real_path'" >&2
            echo "This could damage your system or take an extremely long time." >&2
            exit 1
        fi
    done
    
    # Special check for home directory on macOS
    if [[ "$real_path" == "$HOME" || "$real_path" == "$HOME/" ]]; then
        echo "Warning-⚠️-⚠️-⚠️: Scanning entire home directory. This may include system files." >&2
        echo "Consider scanning specific subdirectories instead." >&2
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Scan cancelled." >&2
            exit 1
        fi
    fi
}

# Main execution
main() {
    local dir="${1:-.}"
    
    # Check for debug flag
    if [[ "$2" == "--debug" || "$1" == "--debug" ]]; then
        if [[ "$1" == "--debug" ]]; then
            dir="."
        fi
        debug_tree_output "$dir"
        return
    fi
    
    # Check if directory exists
    if [[ ! -d "$dir" ]]; then
        echo "Error: Directory '$dir' not found" >&2
        exit 1
    fi
    
    # Safety check for dangerous directories
    check_dangerous_directory "$dir"
    
    # Show initial progress message
    echo "This may take a moment..." >&2
    
    scan_filetypes "$dir"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi