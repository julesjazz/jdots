# zmodload zsh/zprof  # Uncomment this and bottom to enable profiling

# ── Zsh Environment & Path Setup ───────────────────────────────────────────────
# Define XDG_CONFIG_HOME before sourcing envs.sh to avoid circular dependency
export XDG_CONFIG_HOME="$HOME/.config"

# shared source for all shells
ENV_SHARED="$XDG_CONFIG_HOME/shells/envs.sh"
[ -f "$ENV_SHARED" ] && source "$ENV_SHARED"
# Set zsh config directory
export ZDOTDIR="$HOME/.config/shells/zsh"
export ZSH_CONFIG_DIR="$HOME/.config/shells/zsh"
export ZSH_PLUGINS_DIR="$ZSH_CONFIG_DIR/plugins"

# Define .zcompdump variables 
ZCOMPDUMP_DIR="$HOME/.config/shells/zsh"
ZCOMPDUMP_BASENAME=".zcompdump"
ZCOMPDUMP_ACTIVE="${ZCOMPDUMP_DIR}/${ZCOMPDUMP_BASENAME}-${HOST}-${ZSH_VERSION}"
ZCOMPDUMP_MAX_AGE_DAYS=1

# sessions redirect
export ZSH_SESSION_FILE="$XDG_CONFIG_HOME/shells/.zsh_sessions"

# ── History Configuration ───────────────────────────────────────────────────────
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

# ── Plugin Loader ───────────────────────────────────────────────────────────────
load_plugin() {
  local plugin_path="$1"
  [[ -f "$plugin_path" ]] && source "$plugin_path"
}

# ── Plugin Loading ──────────────────────────────────────────────────────────────
# Load zsh-defer first
source "$ZSH_PLUGINS_DIR/zsh-defer/zsh-defer.plugin.zsh"
# Plugin loading using zsh-defer where applicable
load_plugin "$ZSH_PLUGINS_DIR/zsh-you-should-use/you-should-use.plugin.zsh"
load_plugin "$ZSH_PLUGINS_DIR/colored-man-pages/colored-man-pages.plugin.zsh"
zsh-defer load_plugin "$ZSH_PLUGINS_DIR/forgit/forgit.plugin.zsh"
zsh-defer load_plugin "$ZSH_PLUGINS_DIR/z/z.sh"
zsh-defer load_plugin "$ZSH_PLUGINS_DIR/zsh-history-substring-search/zsh-history-substring-search.plugin.zsh"
zsh-defer load_plugin "$ZSH_CONFIG_DIR/custom/custom-sanitizer.zsh"
# Configure zsh-syntax-highlighting
if [[ -f "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh" ]]; then
  # Must be loaded last for proper highlighting
  ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)
  ZSH_HIGHLIGHT_PATTERNS+=('rm -rf *' 'fg=white,bold,bg=red')
fi
# Configure zsh-history-substring-search
if [[ -f "$ZSH_PLUGINS_DIR/zsh-history-substring-search/zsh-history-substring-search.plugin.zsh" ]]; then
  # Bind up and down arrow keys
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
  bindkey '^P' history-substring-search-up
  bindkey '^N' history-substring-search-down
fi
# Configure z (smart directory jumping)
if [[ -f "$XDG_CONFIG_HOME/shells/.z" ]]; then
  # z configuration
  export _Z_DATA="$XDG_CONFIG_HOME/shells/.z"
  export _Z_NO_RESOLVE_SYMLINKS=1
fi

# ── Performance Optimizations ───────────────────────────────────────────────────
autoload -Uz compinit

# Starship prompt, replace lazy load if desired
# eval "$(starship init zsh)"

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
# zsh-defer() { eval "$1" &! }
# zsh-defer "compinit -C"
# Initialize completions (cached if .zcompdump exists and is valid)
zsh-defer compinit -C

# ── Autocomplete Configuration ─────────────────────────────────────────────────
load_plugin ~/.config/shells/zsh/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh
# autocomplete options
if [[ -f ~/.config/shells/zsh/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh ]]; then
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