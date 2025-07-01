# GNU Stow Guide

## What is GNU Stow?

GNU Stow is a symlink farm manager that helps organize and manage software packages, configuration files, and dotfiles by creating symbolic links from a central location to their actual destinations.

## Basic Usage

### Syntax
```bash
stow [options] package_name
```

### Common Options
- `-d DIR`: Set stow directory (default: current directory)
- `-t DIR`: Set target directory (default: parent of stow directory)
- `-n`: Dry run (show what would be done)
- `-v`: Verbose output
- `-D`: Delete (unstow) a package
- `-R`: Restow (delete then stow again)

## Dotfiles Management

### Directory Structure
```
~/
├── .stow/
│   ├── git/
│   │   ├── .gitconfig
│   │   └── .gitignore_global
│   ├── zsh/
│   │   ├── .zshrc
│   │   └── .zprofile
│   └── vim/
│       ├── .vimrc
│       └── .vim/
└── .gitconfig -> .stow/git/.gitconfig
```

### Basic Workflow
```bash
# Create stow directory
mkdir ~/.stow

# Create package directories
mkdir ~/.stow/git
mkdir ~/.stow/zsh

# Move existing config files
mv ~/.gitconfig ~/.stow/git/
mv ~/.zshrc ~/.stow/zsh/

# Stow packages
cd ~/.stow
stow git
stow zsh
```

### Unstowing
```bash
cd ~/.stow
stow -D git    # Remove git config symlinks
stow -D zsh    # Remove zsh config symlinks
```

## Best Practices

### 1. Use Package-Based Organization
Organize related files into logical packages:
- `git/` for Git configuration
- `shell/` for shell configurations
- `editor/` for editor configurations
- `tools/` for utility scripts

### 2. Version Control
```bash
# Initialize git in stow directory
cd ~/.stow
git init
git add .
git commit -m "Initial dotfiles setup"
```

### 3. Handle Conflicts
Stow will warn about conflicts. Common solutions:
- Remove existing files: `rm ~/.existing_file`
- Use `--adopt` to adopt existing files into stow
- Use `--no-folding` to prevent directory folding

### 4. Cross-Platform Considerations
```bash
# Platform-specific packages
mkdir ~/.stow/macos
mkdir ~/.stow/linux

# Conditional stowing
if [[ "$OSTYPE" == "darwin"* ]]; then
    stow macos
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    stow linux
fi
```

## Advanced Features

### Ignoring Files
Create `.stowrc` in your stow directory:
```
--ignore=\.DS_Store
--ignore=\.git
--ignore=\.gitignore
```

### Multiple Target Directories
```bash
# Stow to different locations
stow -t ~/.config config_package
stow -t ~/.local/share local_package
```

### Restowing for Updates
```bash
# Update package and restow
stow -R package_name
```

## Troubleshooting

### Common Issues

1. **Permission Denied**
   ```bash
   sudo stow package_name
   ```

2. **Existing Files**
   ```bash
   # Check what would be stowed
   stow -n package_name
   
   # Remove conflicts
   rm conflicting_file
   ```

3. **Broken Symlinks**
   ```bash
   # Find broken symlinks
   find ~ -type l -xtype l
   
   # Clean up
   stow -D package_name
   stow package_name
   ```

### Debugging
```bash
# Verbose output
stow -v package_name

# Dry run
stow -n package_name

# Show stow directory
stow --show-stow-dir
```

## Integration with Git

### Gitignore Template
```gitignore
# Stow-specific
.stow-local-ignores

# OS-specific
.DS_Store
Thumbs.db

# Editor files
*.swp
*.swo
*~
```

### Automated Setup Script
```bash
#!/bin/bash
# setup-dotfiles.sh

STOW_DIR="$HOME/.stow"
PACKAGES=("git" "zsh" "vim")

# Create stow directory
mkdir -p "$STOW_DIR"

# Stow all packages
cd "$STOW_DIR"
for package in "${PACKAGES[@]}"; do
    if [[ -d "$package" ]]; then
        echo "Stowing $package..."
        stow "$package"
    fi
done
```

## Resources

- [Official Documentation](https://www.gnu.org/software/stow/)
- [GitHub Repository](https://github.com/aspiers/stow)
- [Stow Manual](https://www.gnu.org/software/stow/manual/)

## Quick Reference

| Command | Description |
|---------|-------------|
| `stow package` | Stow a package |
| `stow -D package` | Unstow a package |
| `stow -R package` | Restow a package |
| `stow -n package` | Dry run |
| `stow -v package` | Verbose output |
| `stow -t dir package` | Stow to specific target |
| `stow -d dir package` | Use specific stow directory | 