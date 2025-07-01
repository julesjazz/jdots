# jdots

A comprehensive dotfiles and system configuration management system using GNU stow and Homebrew maintenance scripts.

## Overview

jdots provides automated management of your `.config` files and system maintenance tasks through a simple Makefile interface. It uses GNU stow for configuration file management and includes Homebrew cleanup scripts for system maintenance.

## Quick Start

```bash
# Show all available commands
make help

# Initial setup (backup + deploy configurations)
make stow-init

# Full system maintenance (brew cleanup + config backup)
make maintenance
```

## Configuration Management (Stow)

Manage your `.config` files with GNU stow:

```bash
# Backup current .config files to stow packages
make stow-backup

# Deploy stow packages to ~/.config
make stow-deploy

# Add new configuration directories
make stow-add-new

# Check status of stow packages
make stow-status

# Clean up stow packages (remove symlinks)
make stow-clean

# Full workflow: backup, add new, deploy
make stow-full
```

**Supported Applications:**
- zsh, fish, bash, powershell
- nvim, gitlab, octopus, ghostty
- Global files (.aliases, starship.toml)

## System Maintenance (Homebrew)

Maintain your Homebrew installation:

```bash
# Comprehensive Homebrew cleanup and maintenance
make brewclean

# Homebrew cleanup (dry run - show what would be cleaned)
make brewclean-dry

# Update and upgrade Homebrew packages
make brewupdate

# Run Homebrew doctor to check for issues
make brewdoctor
```

## Project Structure

```
jdots/
├── Makefile                 # Main interface for all commands
├── .stow-local-ignore      # Stow ignore patterns
├── stow-packages/          # Stow configuration packages
├── scripts/
│   ├── stow/              # Stow management scripts
│   │   ├── backup-config.sh
│   │   ├── restore-config.sh
│   │   ├── add-new-configs.sh
│   │   └── README.md
│   └── brewclean/         # Homebrew maintenance scripts
│       ├── brewclean.sh
│       ├── brewclean.md
│       └── brewlist.txt
└── notes/                 # Documentation and notes
```

## Features

- **Smart filtering**: Automatically excludes cache files, logs, and temporary files
- **Safe operations**: Backs up existing files before overwriting
- **Interactive prompts**: Asks for confirmation before adding new configurations
- **Status monitoring**: Shows deployment status of all stow packages
- **Comprehensive cleanup**: Homebrew maintenance with changelog tracking
- **Error handling**: Graceful handling of missing files and directories

## Best Practices

1. **Regular maintenance**: Run `make maintenance` weekly
2. **Backup before changes**: Use `make stow-backup` before modifying configurations
3. **Check status**: Use `make stow-status` to verify package deployment
4. **Version control**: Commit stow packages to git for backup and sharing

## Troubleshooting

- **Permission issues**: Ensure scripts are executable (`chmod +x scripts/*/*.sh`)
- **Stow conflicts**: Use `make stow-clean` before redeploying
- **Missing files**: Run `make stow-backup` to recreate packages
- **Homebrew issues**: Use `make brewdoctor` to diagnose problems

## Requirements

- GNU stow
- Homebrew (for brewclean commands)
- bash/zsh shell
- macOS (for Homebrew commands)

## License

This project is for personal use and configuration management.
