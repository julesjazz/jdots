# Dotfiles Setup Guide for New Computers

This guide will help you set up your dotfiles on a new computer.

## Prerequisites

Before running the setup, ensure you have:
- Git installed (or the script will install it for you)
- Internet connection for downloading packages

## Quick Setup (Recommended)

### 1. Clone your dotfiles repository
```bash
git clone <your-repo-url> ~/jdots
cd ~/jdots
```

### 2. Complete setup (Recommended)
```bash
make setup-new
```

This will automatically:
- Install Homebrew if not already installed
- Install all brew formulas and casks from `brewlist.txt`
- Install required shells and development tools
- Set up your dotfiles with GNU Stow
- Configure shell settings

### 3. Alternative: Manual setup
If you prefer to install packages manually:
```bash
make stow-install-deps
```

This will automatically:
- Detect your package manager (Homebrew, apt, yum, dnf, pacman)
- Install required shells (zsh, fish, bash)
- Install development tools (git, neovim, fzf, fd, ripgrep)
- Install system tools (tree, stow, starship)
- Install platform-specific tools (PowerShell, iTerm2, Ghostty on macOS)

### 3. Restore your dotfiles
```bash
make stow-restore
```

This will:
- Backup any existing config files
- Restore your dotfiles from the stow packages
- Set up both `.config` and home directory files

### 4. Deploy with GNU Stow (Optional)
```bash
make stow-deploy
```

This creates symlinks from your stow packages to the actual config locations.

## Manual Setup (Alternative)

If you prefer to install packages manually:

### macOS (with Homebrew)
```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install required packages
brew install zsh fish bash git neovim fzf fd ripgrep tree stow starship powershell

# Install optional packages
brew install --cask iterm2 ghostty
```

### Ubuntu/Debian
```bash
sudo apt update
sudo apt install zsh fish bash git neovim fzf fd-find ripgrep tree stow

# Install Starship
curl -sS https://starship.rs/install.sh | sh

# Install PowerShell (optional)
wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb"
sudo dpkg -i packages-microsoft-prod.deb
sudo apt update
sudo apt install powershell
```

### Fedora/RHEL
```bash
sudo dnf install zsh fish bash git neovim fzf fd-find ripgrep tree stow

# Install Starship
curl -sS https://starship.rs/install.sh | sh

# Install PowerShell (optional)
sudo dnf install powershell
```

## Post-Setup Configuration

### 1. Set zsh as default shell (optional)
```bash
chsh -s $(which zsh)
```

### 2. Install Oh My Zsh (if not already installed)
```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### 3. Restart your terminal
Close and reopen your terminal to ensure all changes take effect.

## Verification

Check that everything is working:

```bash
# Check shell versions
zsh --version
fish --version
bash --version

# Check tools
nvim --version
fzf --version
fd --version
rg --version
stow --version
starship --version

# Check stow status
make stow-status
```

## Troubleshooting

### Common Issues

1. **Permission denied errors**
   - Make sure scripts are executable: `chmod +x scripts/stow/*.sh`

2. **Package manager not found**
   - Install a supported package manager (Homebrew, apt, yum, dnf, pacman)

3. **Stow packages not found**
   - Run `make stow-backup` first to create the stow packages

4. **Shell not found**
   - The dependency script will install missing shells automatically

### Getting Help

- Check the status: `make stow-status`
- View help: `make help`
- Check stow packages: `ls -la stow-packages/`

## Maintenance

### Regular maintenance
```bash
# Full system maintenance (Homebrew cleanup + stow backup)
make maintenance

# Just Homebrew cleanup
make brewclean

# Install missing brew packages from brewlist.txt
make brew-install

# Just stow backup
make stow-backup
```

### Adding new configs
```bash
# Add new configuration directories
make stow-add-new

# Backup and deploy
make stow-backup
make stow-deploy
```

## File Structure

After setup, your dotfiles will be organized as:

```
stow-packages/
├── config/           # Maps to ~/.config
│   ├── zsh/
│   ├── bash/
│   ├── fish/
│   ├── nvim/
│   ├── powershell/
│   ├── gitlab/
│   ├── octopus/
│   ├── ghostty/
│   ├── .aliases
│   └── starship.toml
└── home/             # Maps to ~
    ├── .zshrc
    └── .bashrc
```

This structure allows for easy management with GNU Stow and maintains separation between `.config` files and home directory files. 