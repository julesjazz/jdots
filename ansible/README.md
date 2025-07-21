# Ansible Dotfiles Setup

This Ansible playbook provides automated setup for the jdots dotfiles configuration.

## Usage

### Prerequisites
- Ansible installed on the target system
- Git (for plugin installation when internet is available)
- Homebrew (macOS) - for package installation
- Package manager (Linux) - apt, yum, dnf, etc.

### Running the Setup

```bash
# From the ansible directory
ansible-playbook -i inventory local.yml

# Run specific tags
ansible-playbook -i inventory local.yml --tags baseline,config
ansible-playbook -i inventory local.yml --tags install
ansible-playbook -i inventory local.yml --tags zsh_plugins,starship
```

### Tags

- `baseline`: Core dotfiles deployment
- `dotfiles`: Project root files
- `install`: Package installation (zsh, bash)
- `config`: Configuration file deployment
- `zsh_plugins`: Zsh plugin installation (requires internet)
- `starship`: Starship prompt installation (requires internet)

### Features

- **Portable**: Works regardless of repository location or name
- **Cross-platform**: Supports macOS (Intel/Apple Silicon) and Linux
- **Platform-aware**: Uses appropriate package managers (Homebrew on macOS, system package manager on Linux)
- **Offline-capable**: Core setup works without internet
- **Conditional**: Internet-dependent features only install when connectivity is available
- **Idempotent**: Safe to run multiple times

### Structure

- `local.yml`: Main playbook for local setup
- `baseline.yml`: Individual tasks for baseline configuration
- `vars/baseline.yml`: Variable definitions
- `inventory`: Local execution configuration
- `templates/`: Template files (if needed)

### Setup Order

1. Deploy core config files to `~/.config`
2. Check for and install zsh/bash if needed (platform-aware)
3. Deploy shell configurations
4. Create symlinks for shell configs
5. Check internet connectivity
6. Install zsh plugins and starship (if internet available)
7. Set zsh as default shell (platform-aware paths)

### Platform Support

- **macOS Intel**: Uses Homebrew, sets shell to `/usr/local/bin/zsh`
- **macOS Apple Silicon**: Uses Homebrew, sets shell to `/opt/homebrew/bin/zsh`
- **Linux**: Uses system package manager, sets shell to `/bin/zsh` 