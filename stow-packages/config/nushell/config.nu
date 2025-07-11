# Nushell Configuration for jdots
# This config integrates with the existing shell setup and shared history

# Environment variables
$env.XDG_CONFIG_HOME = $env.HOME + "/.config"
$env.XDG_DATA_HOME = $env.HOME + "/.local/share"
$env.XDG_CACHE_HOME = $env.HOME + "/.cache"

# Homebrew setup
$env.PATH = ($env.PATH | split row (char esep) | prepend "/opt/homebrew/bin")

# History configuration - shared with bash/zsh
$env.HISTFILE = $env.XDG_CONFIG_HOME + "/.history"
$env.HISTSIZE = 10000

# Starship prompt
$env.STARSHIP_SHELL = "nu"

# Load shared aliases
if ($env.XDG_CONFIG_HOME + "/.aliases" | path exists) {
    source ($env.XDG_CONFIG_HOME + "/.aliases")
}

# Custom completions
$env.config.completions.external = {
    enable = true
    max_results = 100
    completer = {|spans|
        carapace $spans.0 nushell $spans | from json
    }
}

# Keybindings
$env.config.keybindings = [
    {
        name: completion_menu
        modifier: none
        keycode: tab
        mode: [emacs vi_normal vi_insert]
        event: {
            until: [
                { send: menu name: completion_menu }
                { send: menunext }
            ]
        }
    }
    {
        name: history_menu
        modifier: control
        keycode: char_r
        mode: [emacs vi_insert vi_normal]
        event: { send: menu name: history_menu }
    }
    {
        name: help_menu
        keycode: f1
        mode: [emacs vi_insert vi_normal]
        event: { send: menu name: help_menu }
    }
]

# Environment configuration
$env.config.env_conversions = {
    "PATH" = {
        from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
}

# Table configuration
$env.config.table = {
    mode: rounded
    index_mode: always
    show_empty: true
    padding: { left: 1, right: 1 }
    trim: {
        methodology: wrapping
        wrapping_try_keep_words: true
    }
}

# Prompt configuration
$env.config.render_right_prompt_on_last_line = true

# Initialize starship
if (which starship | is-empty) {
    echo "Starship not found. Install with: brew install starship"
} else {
    # Create cache directory if it doesn't exist
    mkdir ($env.XDG_CACHE_HOME + "/starship") | ignore
    
    # Generate starship init script
    starship init nu | save --force ($env.XDG_CACHE_HOME + "/starship/init.nu")
    
    # Source the starship init script
    source ($env.XDG_CACHE_HOME + "/starship/init.nu")
    
    # Set starship environment variables
    $env.STARSHIP_SHELL = "nu"
    $env.STARSHIP_CONFIG = $env.XDG_CONFIG_HOME + "/starship.toml"
}

# Custom commands and aliases
alias ll = ls -la
alias la = ls -a
alias l = ls -l



# Git aliases (if forgit is available)
if (which git | is-not-empty) {
    alias gco = git checkout
    alias gst = git status
    alias ga = git add
    alias gc = git commit
    alias gp = git push
    alias gl = git pull
}

# FZF integration
if (which fzf | is-not-empty) {
    $env.FZF_DEFAULT_OPTS = "--height 40% --layout=reverse --border"
}

# Z integration (smart directory jumping)
if ($env.XDG_CONFIG_HOME + "/.z" | path exists) {
    $env._Z_DATA = $env.XDG_CONFIG_HOME + "/.z"
    $env._Z_NO_RESOLVE_SYMLINKS = "1"
}

# History sharing function
def share-history [] {
    # This function can be used to manually sync history with bash/zsh
    let bash_history = ($env.HOME + "/.bash_history")
    let zsh_history = ($env.HOME + "/.zsh_history")
    
    if ($bash_history | path exists) {
        open $bash_history | lines | where ($it | str length) > 0 | each { |line|
            if ($line | str starts-with "#") { continue }
            $line | str replace "^[0-9]+:" "" | str trim
        } | where ($it | str length) > 0 | uniq | save --append $env.HISTFILE
    }
    
    if ($zsh_history | path exists) {
        open $zsh_history | lines | where ($it | str length) > 0 | each { |line|
            if ($line | str starts-with ":") { continue }
            $line | str replace "^: [0-9]+:[0-9]*;" "" | str trim
        } | where ($it | str length) > 0 | uniq | save --append $env.HISTFILE
    }
}

# Starship utility functions
def starship-config [] {
    # Open starship config in editor
    if ($env.STARSHIP_CONFIG | path exists) {
        nvim $env.STARSHIP_CONFIG
    } else {
        echo "Starship config not found at: ($env.STARSHIP_CONFIG)"
    }
}

def starship-reload [] {
    # Reload starship configuration
    if (which starship | is-not-empty) {
        starship init nu | save --force ($env.XDG_CACHE_HOME + "/starship/init.nu")
        source ($env.XDG_CACHE_HOME + "/starship/init.nu")
        echo "Starship configuration reloaded"
    } else {
        echo "Starship not found"
    }
}

def starship-status [] {
    # Show starship status and configuration
    echo "🚀 Starship Status:"
    echo $"  Shell: ($env.STARSHIP_SHELL)"
    echo $"  Config: ($env.STARSHIP_CONFIG)"
    echo $"  Cache: ($env.XDG_CACHE_HOME + "/starship/init.nu")"
    
    if (which starship | is-not-empty) {
        echo $"  Version: (starship --version | str trim)"
    } else {
        echo "  Status: Not installed"
    }
}

# Welcome message
echo "🐚 Nushell loaded with jdots configuration"
echo $"History file: ($env.HISTFILE)"
echo $"Config home: ($env.XDG_CONFIG_HOME)"
echo "🚀 Starship prompt enabled" 