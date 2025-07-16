# ~/.bashrc
# This file sources the main bash configuration from ~/.config/bash/.bashrc

# Source the main bash configuration
if [[ -f ~/.config/bash/.bashrc ]]; then
    source ~/.config/bash/.bashrc
else
    echo "Warning: ~/.config/bash/.bashrc not found"
fi 