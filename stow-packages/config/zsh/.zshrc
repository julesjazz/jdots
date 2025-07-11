# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
# zmodload zsh/zprof
# Set zsh config directory
export ZDOTDIR="$HOME/.config/zsh"

# Homebrew PATH setup
eval "$(/opt/homebrew/bin/brew shellenv)"

# Performance optimizations
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit
  compdump
else
  compinit -C
fi

# History Configuration
HISTFILE=~/.config/.history
HISTSIZE=10000
SAVEHIST=10000
# History sharing and format
setopt SHARE_HISTORY                # Share history between all sessions
setopt INC_APPEND_HISTORY          # Append to history file immediately
unsetopt EXTENDED_HISTORY          # Remove timestamps for bash compatibility

# Duplicate handling
setopt HIST_IGNORE_ALL_DUPS        # Remove older duplicate entries
setopt HIST_SAVE_NO_DUPS          # Don't write duplicates to file

# Formatting
setopt HIST_IGNORE_SPACE          # Don't store commands starting with space
setopt HIST_REDUCE_BLANKS         # Remove superfluous blanks
setopt HIST_VERIFY               # Don't execute immediately on expansion
setopt HIST_NO_FUNCTIONS         # Don't store function definitions

# Custom filtering (zsh only)
zshaddhistory() {
  [[ $? -ne 0 ]] && return 1  # Skip failed commands
  return 0
}

# Load aliases
if [[ -f ~/.config/.aliases ]]; then
  source ~/.config/.aliases
fi

# Plugin loading function
load_plugin() {
  local plugin_path="$1"
  if [[ -f "$plugin_path" ]]; then
    source "$plugin_path"
  fi
}

# Load plugins
load_plugin ~/.config/zsh/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh
load_plugin ~/.config/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
load_plugin ~/.config/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
load_plugin ~/.config/zsh/plugins/z/z.sh
load_plugin ~/.config/zsh/plugins/fd/fd.plugin.zsh
load_plugin ~/.config/zsh/plugins/forgit/forgit.plugin.zsh

# FZF configuration (built-in)
if command -v fzf >/dev/null 2>&1; then
  # Auto-completion
  [[ $- == *i* ]] && source "$(brew --prefix)/opt/fzf/shell/completion.zsh" 2> /dev/null

  # Key bindings
  source "$(brew --prefix)/opt/fzf/shell/key-bindings.zsh" 2> /dev/null

  # FZF configuration
  export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
fi

# Lazy load starship for better startup performance
if [[ -z $STARSHIP_SHELL ]]; then
  eval "$(starship init zsh --print-full-init)"
fi
# Starship prompt
eval "$(starship init zsh)"
# zprof
