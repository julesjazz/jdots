# ~/.zshrc
# This file sources the main zsh configuration from ~/.config/zsh/.zshrc

# Source the main zsh configuration
if [[ -f ~/.config/zsh/.zshrc ]]; then
    source ~/.config/zsh/.zshrc
else
    echo "Warning: ~/.config/zsh/.zshrc not found"
fi 