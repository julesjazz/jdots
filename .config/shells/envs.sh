# ~/.config/shells/envs.sh
# TODO: further refine with conditionals for posix shells and exports per ansible profiles

# ── XDG base dirs ───────────────────────────────────────────────────────────────
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

# ── Prepend common developer paths to PATH ──────────────────────────────────────
prepend_paths=(
  "/opt/homebrew/bin"
  "/usr/local/bin"
  "$HOME/.cargo/bin"
  "$HOME/.asdf/shims"
)
for dir in "${prepend_paths[@]}"; do
  case ":$PATH:" in *":$dir:"*) ;; *) PATH="$dir:$PATH" ;; esac
done
export PATH

# ── CLI tool config ─────────────────────────────────────────────────────────────
if [ -d "$XDG_CONFIG_HOME/shells/tldr" ]; then
  export TEALDEER_CONFIG_DIR="$XDG_CONFIG_HOME/shells/tldr"
  alias tldr='tldr'
fi
export _Z_DATA="$XDG_DATA_HOME/.z"

# ── Editor & pager ──────────────────────────────────────────────────────────────
export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="less"

# ── Homebrew environment ────────────────────────────────────────────────────────
eval "$(/opt/homebrew/bin/brew shellenv)"

# ── ASDF version manager ────────────────────────────────────────────────────────
. "$HOME/.asdf/asdf.sh"

# ── Obsidian vaults ──────────────────────────────────────────────────────────────
export OBSIDIAN_VAULTS_DIR="$HOME/.config/obsidian"

# ── 1Pass location ──────────────────────────────────────────────────────────────
export OP_CONFIG_DIR="$XDG_CONFIG_HOME/infra/op"

# ── Shared history file ─────────────────────────────────────────────────────────
HISTFILE="$XDG_CONFIG_HOME/shells/.history"
HISTSIZE=10000
SAVEHIST=10000
# pipe into full history file
if [[ -n "$BASH_VERSION" || -n "$ZSH_VERSION" ]]; then
  history() {
    if [[ ! -t 1 ]]; then
      # Pipe or redirect: read full history file, strip Zsh timestamps
      sed 's/^: [0-9]*:[0-9]*;//' "$HISTFILE"
    else
      builtin history "$@"
    fi
  }
fi

# ── Interactive shell logic ─────────────────────────────────────────────────────
case "$-" in
  *i*)
    # Load aliases
    [ -f "$XDG_CONFIG_HOME/shells/.aliases" ] && source "$XDG_CONFIG_HOME/shells/.aliases"

    # FZF
    fzf_base="$(brew --prefix)/opt/fzf/shell"
    __fzf_full_history() {
        sed 's/^: [0-9]*:[0-9]*;//' "$HISTFILE" | fzf
    }
    if [ -n "$ZSH_VERSION" ]; then
      # Starship + completions for Zsh
      eval "$(starship init zsh --print-full-init)"
      source "$fzf_base/completion.zsh" 2> /dev/null
    elif [ -n "$BASH_VERSION" ]; then
      # Starship + completions for Bash
      eval "$(starship init bash)"
      [ -f "$HOME/.asdf/completions/asdf.bash" ] && . "$HOME/.asdf/completions/asdf.bash"
      source "$fzf_base/completion.bash" 2> /dev/null
    fi

    # Key bindings (shared)
    source "$fzf_base/key-bindings.zsh" 2> /dev/null
    ;;
esac

# ── Starship config path (always exported) ──────────────────────────────────────
export STARSHIP_CONFIG="$XDG_CONFIG_HOME/shells/starship/starship.toml"