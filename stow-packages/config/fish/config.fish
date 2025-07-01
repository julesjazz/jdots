if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Fish uses its own history format for better integration
# History is stored in ~/.local/share/fish/fish_history



# Homebrew FISH
fish_add_path "/opt/homebrew/bin/"

# Performance and usability
set -g fish_greeting "🐟🐟🐟 Smells fishy 🐟🐟🐟"
set -g fish_history_size 10000
set -g fish_history_ignore_space yes
set -g fish_history_ignore_dups yes

# Better completions
set fish_complete_path_case_sensitive no
set fish_complete_path_case_insensitive yes

# Environment
set -g EDITOR nvim
set -g AWS_PAGER ""

# Auto-merge history from other sessions
function fish_prompt
    history merge
end

# Starship Init - END of FILE
starship init fish | source