#!/bin/bash

# Simple filetype scanner using tree command
# Usage: ./scan-filetypes.sh [directory] > output.txt
# Usage: ./scan-filetypes.sh [directory] --debug   (for troubleshooting)
# 
# Requires: tree command (usually available via: brew install tree or apt install tree)
# 
# Ignores common module/cache directories and shows progress when run in terminal

# Debug function
debug_tree_output() {
    local dir="${1:-.}"
    
    echo "=== DEBUG: Raw tree output (first 10 lines) ===" >&2
    tree "$dir" -a -f -i --noreport \
        -I "node_modules|.git|venv|.venv|env|.env|__pycache__|.pytest_cache|.mypy_cache|.tox|dist|build|.terraform|.npm|.yarn|.pnpm|site-packages|*.egg-info|.DS_Store|.svn|.hg|tmp|temp|.tmp|.temp|.cache|cache|.next|.nuxt|coverage|.coverage" \
        | head -10 >&2
    
    echo "=== DEBUG: After processing (first 10 lines) ===" >&2
    tree "$dir" -a -f -i --noreport \
        -I "node_modules|.git|venv|.venv|env|.env|__pycache__|.pytest_cache|.mypy_cache|.tox|dist|build|.terraform|.npm|.yarn|.pnpm|site-packages|*.egg-info|.DS_Store|.svn|.hg|tmp|temp|.tmp|.temp|.cache|cache|.next|.nuxt|coverage|.coverage" \
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
        -I "node_modules|.git|venv|.venv|env|.env|__pycache__|.pytest_cache|.mypy_cache|.tox|dist|build|.terraform|.npm|.yarn|.pnpm|site-packages|*.egg-info|.DS_Store|.svn|.hg|tmp|temp|.tmp|.temp|.cache|cache|.next|.nuxt|coverage|.coverage|????????-??????|agenda-????-??-??" \
        2>/dev/null \
        | grep -v "^$" \
        | grep -v "^[[:space:]]*$" \
        | while IFS= read -r filepath; do
            # Only process if it's actually a file (not a directory)
            if [[ -f "$filepath" ]]; then
                filename=$(basename "$filepath" 2>/dev/null)
                [[ -n "$filename" ]] && echo "$filename"
            fi
        done > "$temp_file"
    
    # Check if we got any files
    if [[ ! -s "$temp_file" ]]; then
        echo "No files found or tree command failed" >&2
        rm -f "$temp_file" "$processed_file"
        exit 1
    fi
    
    # Process each filename
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
    done < "$temp_file" > "$processed_file"
    
    # Check if processing produced any results
    if [[ ! -s "$processed_file" ]]; then
        echo "No file types found after processing" >&2
        rm -f "$temp_file" "$processed_file"
        exit 1
    fi
    
    # Sort and remove duplicates
    sort -u "$processed_file"
    
    if [[ -t 1 ]]; then
        local unique_types=$(sort -u "$processed_file" | wc -l)
        echo "Done! Found $unique_types unique file types." >&2
    fi
    
    # Clean up
    rm -f "$temp_file" "$processed_file"
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
    
    # Show initial progress message
    echo "This may take a moment..." >&2
    
    scan_filetypes "$dir"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi