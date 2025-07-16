# zmodload zsh/zprof  # Uncomment this and bottom to enable profiling

# ── Zsh Environment & Path Setup ────────────────────────────────────────────────
# Set zsh config directory
export ZDOTDIR="$HOME/.config/zsh"

# Homebrew PATH setup
eval "$(/opt/homebrew/bin/brew shellenv)"

# ASDF version manager setup
. "$HOME/.asdf/asdf.sh"
# Add ASDF completions
fpath=(${ASDF_DIR}/completions $fpath)

# ── History Configuration ───────────────────────────────────────────────────────
HISTFILE=~/.config/.history
HISTSIZE=10000
SAVEHIST=10000

setopt SHARE_HISTORY                # Share history between all sessions
setopt INC_APPEND_HISTORY           # Append to history file immediately
setopt HIST_IGNORE_ALL_DUPS         # Remove older duplicate entries
setopt HIST_SAVE_NO_DUPS            # Don't write duplicates to file
setopt HIST_IGNORE_SPACE            # Don't store commands starting with space
setopt HIST_REDUCE_BLANKS           # Remove superfluous blanks
setopt HIST_VERIFY                  # Don't execute immediately on expansion
setopt HIST_NO_FUNCTIONS            # Don't store function definitions
unsetopt EXTENDED_HISTORY           # remove history timestamps

# Custom filtering (zsh only)
zshaddhistory() {
  [[ $? -ne 0 ]] && return 1                          # Skip failed commands
  [[ -z ${1//[[:space:]]/} ]] && return 1             # Skip empty or whitespace-only lines
  return 0
}


# ── Alias Loading ───────────────────────────────────────────────────────────────
if [[ -f ~/.config/.aliases ]]; then
  source ~/.config/.aliases
fi

# ── Plugin Loader ───────────────────────────────────────────────────────────────
load_plugin() {
  local plugin_path="$1"
  if [[ -f "$plugin_path" ]]; then
    source "$plugin_path"
  fi
}

# ── Plugin Loading ──────────────────────────────────────────────────────────────
# (syntax highlighting must be loaded last)
# Load zsh-defer first
source ~/.config/zsh/plugins/zsh-defer/zsh-defer.plugin.zsh

# Plugin loading using zsh-defer where applicable
load_plugin ~/.config/zsh/plugins/zsh-you-should-use/you-should-use.plugin.zsh
load_plugin ~/.config/zsh/plugins/zsh-safe-rm/zsh-safe-rm.plugin.zsh
load_plugin ~/.config/zsh/plugins/colored-man-pages/colored-man-pages.plugin.zsh
zsh-defer load_plugin ~/.config/zsh/plugins/forgit/forgit.plugin.zsh
zsh-defer load_plugin ~/.config/zsh/plugins/z/z.sh
zsh-defer load_plugin ~/.config/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.plugin.zsh

# Configure zsh-syntax-highlighting
if [[ -f ~/.config/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh ]]; then
  # Must be loaded last for proper highlighting
  # This is already loaded above, but we'll ensure it's configured properly
  ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)
  ZSH_HIGHLIGHT_PATTERNS+=('rm -rf *' 'fg=white,bold,bg=red')
fi

# Configure zsh-history-substring-search
if [[ -f ~/.config/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.plugin.zsh ]]; then
  # Bind up and down arrow keys
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
  bindkey '^P' history-substring-search-up
  bindkey '^N' history-substring-search-down
fi

# Configure z (smart directory jumping)
if [[ -f ~/.config/zsh/plugins/z/z.sh ]]; then
  # z configuration
  export _Z_DATA="$HOME/.config/zsh/.z"
  export _Z_NO_RESOLVE_SYMLINKS=1
fi

# ── FZF Configuration ───────────────────────────────────────────────────────────
if command -v fzf >/dev/null 2>&1; then
  # Auto-completion
  [[ $- == *i* ]] && source "$(brew --prefix)/opt/fzf/shell/completion.zsh" 2> /dev/null

  # Key bindings
  source "$(brew --prefix)/opt/fzf/shell/key-bindings.zsh" 2> /dev/null

  # FZF configuration
  export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
fi

# ── ASDF Shim Path ──────────────────────────────────────────────────────────────
export PATH="$HOME/.asdf/shims:$PATH"

# ── Performance Optimizations ───────────────────────────────────────────────────
autoload -Uz compinit

# Interactive Starship Load, insert before zcomp config
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
if [[ -o interactive ]]; then
  eval "$(starship init zsh --print-full-init)"
fi
# Starship prompt, replace lazy load if desired
# eval "$(starship init zsh)"

# Define .zcompdump variables 
ZCOMPDUMP_DIR="$HOME/.config/zsh"
ZCOMPDUMP_BASENAME=".zcompdump"
ZCOMPDUMP_ACTIVE="${ZCOMPDUMP_DIR}/${ZCOMPDUMP_BASENAME}-${HOST}-${ZSH_VERSION}"
ZCOMPDUMP_MAX_AGE_DAYS=1

# Clean up old .zcompdump files, skip the current one
for file in "$ZCOMPDUMP_DIR"/$ZCOMPDUMP_BASENAME*; do
  [[ -e "$file" ]] || continue
  [[ "$file" == "$ZCOMPDUMP_ACTIVE"* ]] && continue
  if [[ $(find "$file" -type f -mtime +$ZCOMPDUMP_MAX_AGE_DAYS 2>/dev/null) ]]; then
    echo "[zsh] Removing stale completion dump: $file"
    rm -f -- "$file"
  fi
done

# # Initialize completions (cached if .zcompdump exists and is valid)
zsh-defer() { eval "$1" &! }
zsh-defer "compinit -C"

# ── Autocomplete Configuration ────────────────────────────────────────────────────────
load_plugin ~/.config/zsh/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh
# autocomplete options
if [[ -f ~/.config/zsh/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh ]]; then
  # Load and configure
  zstyle ':autocomplete:history-search:*' max-lines 10
  zstyle ':autocomplete:*' recent-matches first
  zstyle ':autocomplete:*' default-context ''
  zstyle ':autocomplete:*' min-input 1
  zstyle ':autocomplete:*' list-lines 10
  zstyle ':autocomplete:*' max-lines 10
  zstyle ':autocomplete:*' menu select
  zstyle ':autocomplete:*' select-prompt '2%p'
  zstyle ':autocomplete:*' fzf-completion yes
  zstyle ':autocomplete:tab:*' insert-unambiguous yes
  # 💡 Format history results (hide line numbers)
  zstyle ':autocomplete:history-search:*' format '%h'
  zstyle ':autocomplete:history-incremental-search-backward:*' format '%h'
fi

# zprof               # Uncomment to display profiling results