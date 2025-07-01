# FD (find alternative) plugin for zsh
# Provides aliases and configurations for fd command

# Check if fd is available
if ! command -v fd >/dev/null 2>&1; then
    return 0
fi

# Aliases for common fd operations
alias fdf='fd --type f'                    # Find files only
alias fdd='fd --type d'                    # Find directories only
alias fdh='fd --hidden'                    # Include hidden files
alias fdi='fd --ignore-case'               # Case insensitive search
alias fdfh='fd --type f --hidden'          # Find hidden files
alias fddh='fd --type d --hidden'          # Find hidden directories

# Function to find and edit files
fde() {
    local file
    file=$(fd --type f --hidden --exclude .git | fzf --preview 'bat --style=numbers --color=always --line-range :500 {}')
    if [[ -n "$file" ]]; then
        ${EDITOR:-vim} "$file"
    fi
}

# Function to find and change to directory
fdc() {
    local dir
    dir=$(fd --type d --hidden --exclude .git | fzf)
    if [[ -n "$dir" ]]; then
        cd "$dir"
    fi
}

# Function to find and open files with default application
fdo() {
    local file
    file=$(fd --type f --hidden --exclude .git | fzf)
    if [[ -n "$file" ]]; then
        open "$file"
    fi
}

# Export fd as default finder for fzf if available
if command -v fzf >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
fi 