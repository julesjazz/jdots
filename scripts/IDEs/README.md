# IDE Backups

This directory contains scripts for backing up IDE configurations and settings. These scripts are designed to work independently of normal dotfile maintenance, allowing you to backup IDE-specific settings without affecting your core dotfile management.

## Current IDEs

### VS Code (`backup-vscode.sh`)
Backs up VS Code settings.json files with the following features:

- **Independent Operation**: Runs separately from normal maintenance
- **Multiple Locations**: Checks common VS Code settings locations
- **Hostname-Based**: Creates computer-specific backups
- **Timestamped**: Each backup includes a timestamp
- **Latest Symlink**: Always points to the most recent backup
- **Automatic Cleanup**: Keeps only the latest 5 backups per computer

#### VS Code Settings Locations Checked
- `~/Library/Application Support/Code/User/settings.json` (macOS)
- `~/.config/Code/User/settings.json` (Linux)
- `~/.vscode/settings.json` (Project-specific)

#### Usage
```bash
# From Makefile (recommended)
make vscode-backup         # Create backup
make vscode-backup-list    # List backups
make vscode-backup-clean   # Clean old backups
make vscode-backup-info    # Show info

# Direct execution
./scripts/IDEs/backup-vscode.sh backup
./scripts/IDEs/backup-vscode.sh list
./scripts/IDEs/backup-vscode.sh clean
./scripts/IDEs/backup-vscode.sh info
```

### Cursor (`backup-cursor.sh`)
Backs up Cursor IDE settings and configurations with the following features:

- **Comprehensive Backup**: Backs up settings, extensions, keybindings, and snippets
- **Multiple Locations**: Checks common Cursor settings locations
- **Hostname-Based**: Creates computer-specific backups
- **Timestamped**: Each backup includes a timestamp
- **Latest Symlink**: Always points to the most recent backup
- **Automatic Cleanup**: Keeps only the latest 5 backups per computer

#### Cursor Settings Locations Checked
- `~/Library/Application Support/Cursor/User/settings.json` (macOS)
- `~/.config/Cursor/User/settings.json` (Linux)
- `~/.cursor/settings.json` (Alternative location)

#### Cursor Config Locations Backed Up
- Extensions directories
- Keybindings files
- Snippets directories

#### Usage
```bash
# From Makefile (recommended)
make cursor-backup         # Create backup
make cursor-backup-list    # List backups
make cursor-backup-clean   # Clean old backups
make cursor-backup-info    # Show info

# Direct execution
./scripts/IDEs/backup-cursor.sh backup
./scripts/IDEs/backup-cursor.sh list
./scripts/IDEs/backup-cursor.sh clean
./scripts/IDEs/backup-cursor.sh info
```

## Future IDEs

This directory is designed to accommodate additional IDE backup scripts. When adding new IDEs, follow these conventions:

### Naming Convention
- Scripts: `backup-{ide-name}.sh`
- Examples: `backup-intellij.sh`, `backup-sublime.sh`, `backup-vim.sh`

### Makefile Integration
Add corresponding Makefile targets following the pattern:
```makefile
{ide}-backup:
	@echo "📁 Creating {IDE} settings backup..."
	@chmod +x scripts/IDEs/backup-{ide}.sh
	@./scripts/IDEs/backup-{ide}.sh backup

{ide}-backup-list:
	@echo "📋 Listing {IDE} backups..."
	@chmod +x scripts/IDEs/backup-{ide}.sh
	@./scripts/IDEs/backup-{ide}.sh list

{ide}-backup-clean:
	@echo "🧹 Cleaning old {IDE} backups..."
	@chmod +x scripts/IDEs/backup-{ide}.sh
	@./scripts/IDEs/backup-{ide}.sh clean

{ide}-backup-info:
	@echo "ℹ️  Showing {IDE} backup info..."
	@chmod +x scripts/IDEs/backup-{ide}.sh
	@./scripts/IDEs/backup-{ide}.sh info
```

### Help Section Update
Add to the "IDE Backups" section in the Makefile help:
```makefile
@echo "  {ide}-backup         - Create {IDE} settings backup"
@echo "  {ide}-backup-list    - List {IDE} backups"
@echo "  {ide}-backup-clean   - Clean old {IDE} backups"
@echo "  {ide}-backup-info    - Show {IDE} backup info"
```

## Common Patterns

### Script Structure
Each IDE backup script should follow this structure:
1. **Setup**: Define paths, colors, hostname
2. **Backup Function**: Main backup logic
3. **List Function**: Show existing backups
4. **Clean Function**: Remove old backups
5. **Info Function**: Show backup information
6. **Help Function**: Display usage information

### Backup File Naming
Use consistent naming across all IDE scripts:
```
{ide}-settings-{hostname}-{timestamp}.json
{ide}-settings-{hostname}-latest.json  # symlink
```

### Backup Directory Structure
```
backups/
├── vscode/
│   ├── vscode-settings-MBP165-004-20250109_143022.json
│   └── vscode-settings-MBP165-004-latest.json
├── cursor/
│   ├── cursor-settings-MBP165-004-20250109_143022.json
│   ├── cursor-extensions-MBP165-004-20250109_143022
│   ├── cursor-keybindings-MBP165-004-20250109_143022.json
│   └── cursor-settings-MBP165-004-latest
├── intellij/
│   ├── intellij-settings-MBP165-004-20250109_143022.json
│   └── intellij-settings-MBP165-004-latest.json
└── sublime/
    ├── sublime-settings-MBP165-004-20250109_143022.json
    └── sublime-settings-MBP165-004-latest.json
```

### Error Handling
- Check if IDE is installed
- Handle missing configuration files gracefully
- Provide clear error messages
- Use consistent color coding for status messages

### Cross-Platform Support
- Check multiple common locations for each IDE
- Handle different path formats (macOS vs Linux)
- Use platform-agnostic commands where possible

## Integration with Main System

IDE backups are designed to be:
- **Independent**: Don't interfere with stow packages or brew operations
- **Complementary**: Provide additional backup layer for IDE-specific settings
- **Optional**: Can be run anytime without affecting core dotfile management
- **Scalable**: Easy to add new IDEs following established patterns

## Important Note: Manual Restoration

**IDE configurations are NOT automatically restored during normal maintenance or new computer setup.** This is by design because:

- IDE settings often contain personal preferences and sensitive data
- Different computers may need different IDE configurations
- Manual restoration allows you to review and selectively apply settings
- Prevents accidental overwriting of current IDE configurations

To restore IDE settings, you'll need to manually copy the desired backup file to the appropriate IDE configuration location.

## Best Practices

1. **Regular Backups**: Run IDE backups periodically
2. **Clean Old Backups**: Use cleanup functions to manage disk space
3. **Check Before Changes**: Use info functions to see what will be backed up
4. **Review Backups**: Use list functions to see backup history
5. **Follow Conventions**: Maintain consistency across all IDE scripts 