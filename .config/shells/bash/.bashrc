# ~/.config/shells/bashrc

# ── Set Config Path ─────────────────────────────────────────────────────────────
export BASH_CONFIG_DIR="$HOME/.config/shells/bash"

# ── Source Shared Environment ───────────────────────────────────────────────────
ENV_SHARED="$HOME/.config/shells/envs.sh"
[ -f "$ENV_SHARED" ] && source "$ENV_SHARED"

# ── Exit if not interactive ─────────────────────────────────────────────────────
# case $- in *i*) ;; *) return ;; esac
# # optional: add wrap later
# if [[ $- == *i* ]]; then
#   # prompt, key bindings, fzf, etc.
# fi

# ── History Configuration ───────────────────────────────────────────────────────
HISTFILE="$XDG_CONFIG_HOME/shells/.history"
HISTSIZE=10000
HISTFILESIZE=10000
HISTCONTROL=ignoreboth:erasedups

shopt -s histappend        # Append history, don't overwrite
shopt -s histreedit        # Re-edit failed history substitutions
shopt -s histverify        # Don't auto-run history expansions
shopt -s checkwinsize      # Adjust LINES and COLUMNS after each command

# ── Custom History Filtering Functions (Optional) ───────────────────────────────
history_filter() {
    local cmd="$1"
    [[ -z "${cmd//[[:space:]]/}" ]] && return 1
    [[ "$cmd" =~ ^[[:space:]] ]] && return 1
    return 0
}

deduplicate_history() {
    local temp_hist
    temp_hist=$(mktemp)
    local seen_commands=()

    if [[ -f "$HISTFILE" ]]; then
        while IFS= read -r line; do
            local cmd=$(echo "$line" | sed 's/^[0-9]*: [0-9]*:[0-9]*;//' | sed 's/^[[:space:]]*[0-9]*[[:space:]]*//')
            [[ -z "${cmd//[[:space:]]/}" ]] && continue
            local found=0
            for seen_cmd in "${seen_commands[@]}"; do
                if [[ "$cmd" == "$seen_cmd" ]]; then
                    found=1; break
                fi
            done
            if [[ $found -eq 0 ]]; then
                seen_commands+=("$cmd")
                echo "$line" >> "$temp_hist"
            fi
        done < "$HISTFILE"
        mv "$temp_hist" "$HISTFILE"
    fi
}

clean_history() {
    echo "Cleaning history file..."
    deduplicate_history
    history -r
    echo "History cleaned and reloaded."
}

# ── Prompt Setup ────────────────────────────────────────────────────────────────
# Set a fancy color prompt
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# Set terminal title for xterm/rxvt
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
esac

# ── Color Support ───────────────────────────────────────────────────────────────
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# ── Aliases ─────────────────────────────────────────────────────────────────────
alias rm='rm -i'
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history | tail -n1 | sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# ── Load Aliases ────────────────────────────────────────────────────────────────
[ -f "$XDG_CONFIG_HOME/shells/.aliases" ] && source "$XDG_CONFIG_HOME/shells/.aliases"
[ -f "$BASH_CONFIG_DIR/.aliases" ] && source "$BASH_CONFIG_DIR/.aliases"

# ── Completion Setup ────────────────────────────────────────────────────────────
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi