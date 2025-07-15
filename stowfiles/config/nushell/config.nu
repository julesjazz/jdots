# Nushell Configuration for jdots
# This config integrates with the existing shell setup and shared history

# Environment variables
$env.XDG_CONFIG_HOME = $env.HOME + "/.config"
$env.XDG_DATA_HOME = $env.HOME + "/.local/share"
$env.XDG_CACHE_HOME = $env.HOME + "/.cache"

# Homebrew setup
$env.PATH = ($env.PATH | split row (char esep) | prepend "/opt/homebrew/bin")

# ASDF version manager setup
if ($env.HOME + "/.asdf/asdf.sh" | path exists) {
    # Source ASDF and add to PATH
    source ($env.HOME + "/.asdf/asdf.sh")
    $env.PATH = ($env.PATH | split row (char esep) | prepend ($env.HOME + "/.asdf/shims"))
}

# History configuration - shared with bash/zsh
$env.HISTFILE = $env.XDG_CONFIG_HOME + "/.history"
$env.HISTSIZE = 10000

# Starship prompt
$env.STARSHIP_SHELL = "nu"

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

# Initialize starship
if (which starship | is-empty) {
    echo "Starship not found. Install with: brew install starship"
} else {
    # Set starship environment variables
    $env.STARSHIP_SHELL = "nu"
    $env.STARSHIP_CONFIG = $env.XDG_CONFIG_HOME + "/starship.toml"
    
    # Create custom starship prompt function for nushell
    def create_starship_prompt [] {
        starship prompt --cmd-duration $env.CMD_DURATION_MS $'--status=($env.LAST_EXIT_CODE)'
    }
    
    # Set the prompt
    $env.PROMPT_COMMAND = { create_starship_prompt }
    
    # Set the right prompt (if needed)
    $env.PROMPT_COMMAND_RIGHT = { "" }
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

# def starship-status [] {
#     # Show starship status and configuration
#     echo "🚀 Starship Status:"
#     echo $"  Shell: ($env.STARSHIP_SHELL)"
#     echo $"  Config: ($env.STARSHIP_CONFIG)"
#     echo $"  Cache: ($env.XDG_CACHE_HOME + "/starship/init.nu")"
    
#     if (which starship | is-not-empty) {
#         echo $"  Version: (starship --version | str trim)"
#     } else {
#         echo "  Status: Not installed"
#     }
# }

# Welcome message
echo "🐚 Nushell loaded with jdots configuration"
echo $"History file: ($env.HISTFILE)"
echo $"Config home: ($env.XDG_CONFIG_HOME)"
echo "🚀 Starship prompt enabled" 