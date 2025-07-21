# Nushell Environment Configuration
# This file is sourced after config.nu

# Additional environment variables
$env.EDITOR = "nvim"
$env.VISUAL = "nvim"
$env.PAGER = "less"

# ASDF environment variables
$env.ASDF_DIR = $env.HOME + "/.asdf"
$env.ASDF_DATA_DIR = $env.HOME + "/.asdf"

# Development environment
$env.RUST_BACKTRACE = "1"
$env.CARGO_INCREMENTAL = "1"

# AWS configuration (if using AWS CLI)
if ($env.HOME + "/.aws" | path exists) {
    $env.AWS_CONFIG_FILE = $env.HOME + "/.aws/config"
    $env.AWS_SHARED_CREDENTIALS_FILE = $env.HOME + "/.aws/credentials"
}

# Python configuration
if (which python3 | is-not-empty) {
    $env.PYTHONPATH = $env.XDG_DATA_HOME + "/python"
}

# Node.js configuration
if (which node | is-not-empty) {
    $env.NODE_PATH = $env.XDG_DATA_HOME + "/node_modules"
}

# Go configuration
if (which go | is-not-empty) {
    $env.GOPATH = $env.XDG_DATA_HOME + "/go"
    $env.GOROOT = "/usr/local/go"
    $env.PATH = ($env.PATH | split row (char esep) | prepend [$env.GOPATH + "/bin", $env.GOROOT + "/bin"])
}

# Ruby configuration
if (which ruby | is-not-empty) {
    $env.GEM_HOME = $env.XDG_DATA_HOME + "/gem"
    $env.GEM_PATH = $env.XDG_DATA_HOME + "/gem"
    $env.PATH = ($env.PATH | split row (char esep) | prepend ($env.GEM_HOME + "/bin"))
}

# Starship environment variables
$env.STARSHIP_SHELL = "nu"
$env.STARSHIP_CONFIG = $env.XDG_CONFIG_HOME + "/shells/starship/starship.toml"
$env.NU_CONFIG_DIR = $env.XDG_CONFIG_HOME + "/shells/nushell"

# Custom functions for environment management
def reload-env [] {
    source ~/.config/shells/nushell/config.nu
    echo "Environment reloaded"
}

def show-env [key?: string] {
    if ($key | is-empty) {
        $env | sort-by name
    } else {
        $env | get $key
    }
}

# Starship environment functions
def starship-env [] {
    # Show starship-related environment variables
    $env | where name =~ "STARSHIP" | sort-by name
}

# ASDF utility functions
def asdf-list [] {
    # List all installed ASDF tools
    if (which asdf | is-not-empty) {
        asdf list
    } else {
        echo "ASDF not found"
    }
}

def asdf-current [] {
    # Show current ASDF tool versions
    if (which asdf | is-not-empty) {
        asdf current
    } else {
        echo "ASDF not found"
    }
}

def asdf-env [] {
    # Show ASDF-related environment variables
    $env | where name =~ "ASDF" | sort-by name
} 