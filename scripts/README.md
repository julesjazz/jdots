# Scripts Directory

This directory contains various utility scripts for managing your dotfiles and system configuration.

## Scripts Overview

### IDE Backups (`IDEs/`)
Backs up IDE configurations and settings without affecting normal maintenance or new installs.
- VS Code settings backup
- Cursor IDE settings backup (including extensions, keybindings, snippets)
- Extensible for other IDEs (IntelliJ, Sublime, etc.)

### Brew Cleanup (`brewclean/`)
Comprehensive Homebrew package management and synchronization across multiple computers.

### Stow Management (`stow/`)
GNU Stow-based dotfile management for `.config` files and home directory configurations.

### Setup (`setup-new-computer.sh`)
Complete automation for setting up jdots on a new computer.

## IDE Backups

The IDE backup scripts provide a way to backup IDE settings without interfering with normal dotfile operations. Currently supports VS Code and Cursor, with extensible architecture for additional IDEs.

**Note**: IDE configurations are NOT automatically restored during normal maintenance or new computer setup. This is intentional to prevent accidental overwriting of personal settings and sensitive data.

### Features

- **Independent Operation**: Runs separately from normal maintenance
- **Multiple Locations**: Checks common VS Code settings locations
- **Hostname-Based**: Creates computer-specific backups
- **Timestamped**: Each backup includes a timestamp
- **Latest Symlink**: Always points to the most recent backup
- **Automatic Cleanup**: Keeps only the latest 5 backups per computer

### VS Code Settings Locations Checked

- `~/Library/Application Support/Code/User/settings.json` (macOS)
- `~/.config/Code/User/settings.json` (Linux)
- `~/.vscode/settings.json` (Project-specific)

### Current IDE Support

The system currently supports:
- **VS Code**: Settings, extensions, keybindings, snippets
- **Cursor**: Settings, extensions, keybindings, snippets

### Future IDE Support

The system is designed to easily accommodate additional IDEs:
- IntelliJ IDEA
- Sublime Text
- Vim/Neovim
- And more...

### Usage

#### From Makefile (Recommended)
```bash
# Create a new backup
make vscode-backup

# List existing backups
make vscode-backup-list

# Clean old backups (keep latest 5)
make vscode-backup-clean

# Show backup information
make vscode-backup-info
```

#### Direct Script Execution
```bash
# Make script executable
chmod +x scripts/IDEs/backup-vscode.sh

# Create backup
./scripts/IDEs/backup-vscode.sh backup

# List backups
./scripts/IDEs/backup-vscode.sh list

# Clean old backups
./scripts/IDEs/backup-vscode.sh clean

# Show info
./scripts/IDEs/backup-vscode.sh info
```

### Backup File Structure

Backups are stored in `backups/vscode/` with the following naming convention:

```
backups/vscode/
├── vscode-settings-MBP165-004-20250109_143022.json  # Timestamped backup
├── vscode-settings-MBP165-004-20250109_150145.json  # Another backup
├── vscode-settings-MBP165-004-latest.json           # Symlink to latest
└── vscode-settings-work-laptop-20250109_120000.json # Different computer
```

### Why Separate from Normal Maintenance?

IDE settings are often:
- **Personal**: Contains user-specific preferences
- **Dynamic**: Changes frequently during development
- **Large**: Can contain many customizations
- **Sensitive**: May contain API keys or personal data

By keeping IDE backups separate, you can:
- Backup settings independently of dotfile changes
- Maintain a history of settings changes
- Restore specific settings versions if needed
- Keep sensitive data separate from version-controlled dotfiles
- **Manual Control**: Choose when and how to restore settings

### Integration with Other Tools

The IDE backup scripts are designed to work alongside your existing dotfile management:

- **No Interference**: Doesn't affect stow packages or normal maintenance
- **Complementary**: Provides additional backup layer for IDE settings
- **Independent**: Can be run anytime without affecting other operations
- **Manual Restoration**: Requires explicit action to restore settings

### Best Practices

1. **Regular Backups**: Run `make vscode-backup` periodically
2. **Clean Old Backups**: Use `make vscode-backup-clean` to manage space
3. **Check Before Changes**: Use `make vscode-backup-info` to see what will be backed up
4. **Review Backups**: Use `make vscode-backup-list` to see backup history
5. **Manual Restoration**: Manually restore settings when needed, reviewing content first

### Troubleshooting

#### No Settings Found
If no VS Code settings are found, the script will show the locations it checked. Common reasons:
- VS Code not installed
- Settings in a different location
- No settings.json file created yet

#### Permission Issues
Make sure the script is executable:
```bash
chmod +x scripts/backup-vscode.sh
```

#### Backup Directory Issues
The script will create the backup directory if it doesn't exist. If you encounter issues:
```bash
mkdir -p backups/vscode
```

### File Locations

- **Script**: `scripts/IDEs/backup-vscode.sh`
- **Backups**: `backups/vscode/`
- **Makefile Targets**: See `Makefile` for all available commands
- **Documentation**: `scripts/IDEs/README.md` 