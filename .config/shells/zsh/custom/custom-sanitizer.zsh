# ~/.config/shells/zsh/custom-sanitizer.zsh

autoload -Uz add-zsh-hook

# Always ensure EXTENDED_HISTORY is off
disable_extended_history() {
  unsetopt EXTENDED_HISTORY
}
add-zsh-hook precmd disable_extended_history

# Sanitize last 100 lines of HISTFILE
sanitize_last_100_history_lines() {
  local file="${HISTFILE:-$HOME/.bash_history}"
  [[ -f "$file" ]] || return 0

  local tmpfile
  tmpfile=$(mktemp)
  tail -n 100 "$file" | sed -E 's/^: [0-9]+:[0-9]+;//' > "$tmpfile"
  head -n -100 "$file" > "${file}.head" 2>/dev/null || true
  cat "${file}.head" "$tmpfile" > "${file}.new"
  mv "${file}.new" "$file"
  rm -f "${file}.head" "$tmpfile"
}

# Wrapper: sanitize in background if running bash
bash_sanitizer_wrapper() {
  [[ -n "$_JDOTS_BASH_HISTORY_CLEANED" ]] && exec command bash "$@"
  export _JDOTS_BASH_HISTORY_CLEANED=1

  sanitize_last_100_history_lines &!
  exec command bash "$@"
}
alias bash=bash_sanitizer_wrapper