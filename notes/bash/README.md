# Bash Stow Package

This directory contains the stow package for managing bash configuration files.

## Structure

```
bash/
├── .bashrc        # Bash configuration for non-login shells
├── .bash_aliases  # Bash aliases (if exists)
├── .bash_profile  # Bash profile for login shells (if exists)
└── README.md      # This file
```

## Usage

### Initial Setup

1. Run the setup script to move your existing bash files:
   ```bash
   ./scripts/setup-config-stow.sh
   ```

2. Stow the bash package:
   ```bash
   stow bash
   ```

### Managing Bash Configuration

- **Stow bash config**: `stow bash`
- **Unstow bash config**: `stow -D bash`
- **Restow (refresh)**: `stow -R bash`
- **Dry run**: `stow -n bash`

## Bash Configuration Files

### `.bashrc`
- Executed for non-login shells
- Contains interactive shell configuration
- Aliases, functions, and environment setup

### `.bash_aliases`
- Contains bash aliases
- Sourced by `.bashrc` if it exists

### `.bash_profile`
- Executed for login shells
- Contains login-specific configuration
- Usually sources `.bashrc` for interactive shells

## XDG Base Directory Compliance

For modern applications that follow the XDG Base Directory specification, you can also set:

```bash
# Add to your .bashrc
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
```

## Integration with Other Shells

If you use multiple shells, consider creating a shared configuration:

```bash
# In .bashrc
if [[ -f ~/.config/aliases ]]; then
    source ~/.config/aliases
fi
```

## Troubleshooting

### Bash Not Loading Configuration
If bash isn't loading your configuration:

1. Check if the symlinks are correct:
   ```bash
   ls -la ~/.bashrc
   ```

2. Verify the file is being sourced:
   ```bash
   bash -x -i -c "echo 'Testing bash configuration'"
   ```

### Conflicts with Other Shells
If you have conflicts with zsh or other shells:

1. Check your shell priority in `/etc/shells`
2. Ensure your login shell is set correctly:
   ```bash
   chsh -s /bin/bash
   ```

## Version Control

This bash package is designed to be version controlled with git. The `.stow-local-ignore` file in the parent directory handles common exclusions. 