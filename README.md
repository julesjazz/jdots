# jdots

A comprehensive dotfiles repository managed with GNU Stow for consistent development environments across machines.

## 🚀 Quick Start

### Prerequisites
- Git
- Internet connection for package downloads

### Setup on New Machine
```bash
# Clone the repository
git clone <your-repo-url> ~/jdots
cd ~/jdots

# Install all dependencies automatically
make stow-install-deps

# Restore your dotfiles
make stow-restore

# Deploy with stow (optional)
make stow-deploy
```

## 📁 Repository Structure

```
jdots/
├── scripts/
│   ├── stow/           # Stow management scripts
│   │   ├── backup-config.sh
│   │   ├── restore-config.sh
│   │   ├── add-new-configs.sh
│   │   ├── install-dependencies.sh
│   │   └── SETUP.md
│   └── brewclean/      # Homebrew maintenance
├── stow-packages/      # Stow packages (generated)
│   ├── config/         # Maps to ~/.config
│   └── home/           # Maps to ~
├── notes/              # Documentation and notes
└── Makefile           # Main management interface
```

## 🛠️ Available Commands

### Stow Management
```bash
make stow-backup      # Backup current configs to stow packages
make stow-restore     # Restore configs from stow packages
make stow-deploy      # Deploy stow packages (create symlinks)
make stow-clean       # Remove stow symlinks
make stow-status      # Show stow package status
make stow-add-new     # Add new config directories
make stow-install-deps # Install all dependencies
```

### System Maintenance
```bash
make brewclean        # Homebrew cleanup and maintenance
make brewclean-dry    # Homebrew cleanup (dry run)
make brewupdate       # Update Homebrew packages
make brewdoctor       # Run Homebrew doctor
make maintenance      # Full system maintenance
```

### Help
```bash
make help             # Show all available commands
```

## 🔧 Supported Applications

### Shells
- **Zsh** - Primary shell with Oh My Zsh and custom plugins
- **Fish** - Alternative shell with shared aliases
- **Bash** - Fallback shell configuration

### Development Tools
- **Neovim** - Modern Vim with Lua configuration
- **Git** - Version control configuration
- **FZF** - Fuzzy finder integration
- **FD** - Fast alternative to find
- **Ripgrep** - Fast grep alternative

### System Tools
- **Starship** - Cross-shell prompt
- **GNU Stow** - Dotfiles management
- **Tree** - Directory visualization

### Platform-Specific
- **PowerShell** - Windows/macOS PowerShell configuration
- **iTerm2** - Terminal emulator (macOS)
- **Ghostty** - Modern terminal (macOS)

## 🔒 Security

### Excluded Files
The following files are excluded from backups for security:
- History files (`.history`, `.zsh_history`, `.bash_history`)
- Sensitive configs (Octopus CLI config)
- Cache and temporary files

### Security Best Practices
- No API keys or secrets in repository
- History files excluded from backups
- Sensitive configs in `.gitignore`
- Regular security audits with `grep -r "password\|secret\|key\|token"`

## 🌍 Cross-Platform Support

### Supported Package Managers
- **macOS**: Homebrew
- **Ubuntu/Debian**: apt
- **Fedora/RHEL**: dnf/yum
- **Arch**: pacman

### Platform Detection
The dependency installation script automatically detects your platform and installs appropriate packages.

## 📚 Detailed Documentation

- [Setup Guide](scripts/stow/SETUP.md) - Comprehensive setup instructions
- [Stow Management](scripts/stow/README.md) - Detailed stow usage
- [Brewclean Script](scripts/brewclean/brewclean.md) - Homebrew maintenance

## 🔄 Workflow

### Daily Usage
```bash
# Check status
make stow-status

# Backup changes
make stow-backup

# Deploy to system
make stow-deploy
```

### Adding New Configs
```bash
# Add new configuration directory
make stow-add-new

# Backup and deploy
make stow-backup
make stow-deploy
```

### System Maintenance
```bash
# Full maintenance (cleanup + backup)
make maintenance
```

## 🐛 Troubleshooting

### Common Issues

1. **Permission denied errors**
   ```bash
   chmod +x scripts/stow/*.sh
   ```

2. **Package manager not found**
   - Install a supported package manager (Homebrew, apt, dnf, pacman)

3. **Stow packages not found**
   ```bash
   make stow-backup
   ```

4. **Shell not found**
   - The dependency script will install missing shells automatically

### Getting Help
```bash
make help              # Show all commands
make stow-status       # Check stow status
ls -la stow-packages/  # View stow packages
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- [GNU Stow](https://www.gnu.org/software/stow/) for dotfiles management
- [Oh My Zsh](https://ohmyz.sh/) for zsh framework
- [Starship](https://starship.rs/) for cross-shell prompt
- Various plugin authors for zsh plugins

---

**Happy coding! 🚀**
