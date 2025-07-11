# Stow Configuration Management

This directory contains scripts for managing `.config` files using GNU stow. These scripts provide a comprehensive solution for backing up, restoring, and managing configuration files across different applications.

## Scripts Overview

### 1. `backup-config.sh`
Backs up `.config` files to stow packages while excluding cache files, logs, and temporary files.

**What it does:**
- Scans `~/.config` for configuration directories
- Copies relevant files to stow packages in `stow-packages/`
- Excludes cache files, logs, and temporary files
- Creates proper stow directory structure

**Supported applications:**
- zsh (excludes `.zcompdump*`, `.zsh_history`)
- nu (excludes cache files)
- nvim (excludes `lazyvim.json`, `.neoconf.json`, cache files)
- bash (excludes `.bashrc.backup`)
- powershell
- gitlab
- octopus
- ghostty
- Global files (`.aliases`, `starship.toml`)

### 2. `restore-config.sh`
Restores `.config` files from stow packages to `~/.config`.

**What it does:**
- Backs up existing configurations before overwriting
- Restores files from stow packages to `~/.config`
- Preserves original files in timestamped backup directory
- Handles both application-specific and global configurations

### 3. `add-new-configs.sh`
Scans for new configuration directories and adds them to stow packages.

**What it does:**
- Identifies new directories in `~/.config`
- Prompts for confirmation before adding each directory
- Checks for configuration files before adding
- Ignores cache directories and temporary files

## Usage

### Using Makefile (Recommended)

```bash
# Show available commands
make help

# Initial setup
make stow-init

# Backup current .config files
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

### Direct Script Usage

```bash
# Backup configurations
./scripts/stow/backup-config.sh

# Restore configurations
./scripts/stow/restore-config.sh

# Add new configurations
./scripts/stow/add-new-configs.sh
```

## Directory Structure

After running the backup script, the stow packages will be organized as follows:

```
stow-packages/
├── bash/
│   └── .config/
│       └── bash/
│           └── .bashrc
├── nushell/
│   └── .config/
│       └── nushell/
│           ├── config.nu
│           └── env.nu
├── nvim/
│   └── .config/
│       └── nvim/
│           ├── init.lua
│           ├── stylua.toml
│           └── lua/
├── powershell/
│   └── .config/
│       └── powershell/
│           ├── profile.ps1
│           └── Sync-History.ps1
├── zsh/
│   └── .config/
│       └── zsh/
│           ├── .zshrc
│           ├── history
│           └── plugins/
├── gitlab/
│   └── .config/
│       └── gitlab/
│           └── config.yml
├── octopus/
│   └── .config/
│       └── octopus/
│           └── cli_config.json
├── ghostty/
│   └── .config/
│       └── ghostty/
│           └── config
└── global/
    └── .config/
        ├── .aliases
        └── starship.toml
```

## Excluded Files

The following types of files are automatically excluded from stow packages:

- Cache files (`.zcompdump*`, etc.)
- Log files (`*.log`)
- Temporary files (`*.tmp`, `*.temp`)
- Backup files (`*.backup`)
- Session files (`sessions/`, `undo/`, `swap/`)
- Runtime data (`AppSupport/`, `sockets/`)
- **History files** (`.history`, `.zsh_history`, `history`) - **Excluded for privacy/security**
- Documentation files (`README.md`, `LICENSE`)

## Best Practices

1. **Always backup before making changes**: Use `make stow-backup` before modifying configurations
2. **Check status regularly**: Use `make stow-status` to verify package deployment
3. **Add new configs incrementally**: Use `make stow-add-new` when adding new applications
4. **Clean up when needed**: Use `make stow-clean` to remove symlinks if issues arise
5. **Version control**: Commit stow packages to git for backup and sharing

## Troubleshooting

### Common Issues

1. **Permission denied**: Ensure scripts are executable (`chmod +x scripts/stow/*.sh`)
2. **Stow conflicts**: Use `make stow-clean` before redeploying
3. **Missing files**: Run `make stow-backup` to recreate packages
4. **Symlink issues**: Check if target directories exist and have proper permissions

### Recovery

If something goes wrong:

1. Run `make stow-clean` to remove all symlinks
2. Run `make stow-restore` to restore from backup
3. Check the backup directory created by restore script
4. Re-run `make stow-deploy` if needed

## Integration with Git

The stow packages are designed to work with version control:

- Stow packages are in `stow-packages/` directory
- Use `.stow-local-ignore` to exclude unwanted files
- Commit packages to git for backup and sharing across machines
- Use `make stow-full` for complete workflow automation 