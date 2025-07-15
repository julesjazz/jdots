#!/bin/bash

# New Environment Setup Script
# Follows the process outlined in JDOTS.md

set -e

echo "🚀 Setting up new environment..."

# Step 1: Check and install package manager (Homebrew for macOS)
echo "📦 Checking Homebrew installation..."
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew already installed"
fi

# Step 2: Install asdf, plugins, and tool versions first
echo "🔧 Installing asdf and dependencies..."
if ! command -v asdf &> /dev/null; then
    echo "Installing asdf..."
    git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.13.1
    echo ". $HOME/.asdf/asdf.sh" >> ~/.zshrc
    echo ". $HOME/.asdf/completions/asdf.bash" >> ~/.zshrc
    source ~/.zshrc
fi

# Install asdf plugins and tools (this would need to be customized based on your needs)
echo "Installing asdf plugins and tools..."
# Add your specific asdf plugin installations here

# Step 3: Restore ZSH and Bash configs
echo "🐚 Restoring shell configurations..."
# This will be handled by stow restore

# Step 4: Download ZSH plugins
echo "📥 Downloading ZSH plugins..."
mkdir -p ~/.config/zsh/plugins
# Add plugin downloads here based on your .zshrc

# Step 5: Install and restore Starship
echo "⭐ Installing Starship..."
if ! command -v starship &> /dev/null; then
    curl -sS https://starship.rs/install.sh | sh
fi

# Step 6: Install Homebrew formulas and casks
echo "🍺 Installing Homebrew packages..."
# This would use your brewlist.txt or similar

# Step 7: Restore Git configuration
echo "📝 Restoring Git configuration..."
# This will be handled by stow restore

echo "✅ New environment setup complete!"
echo "Next steps:"
echo "1. Run 'make stow-restore' to restore configurations"
echo "2. Restart your shell or run 'source ~/.zshrc'" 