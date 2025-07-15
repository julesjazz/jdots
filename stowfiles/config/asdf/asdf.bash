# Bash completion for asdf

_asdf_completions()
{
  local cur prev opts plugin_names plugin_commands

  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"
  opts="help plugin list list-all install uninstall global local current which where latest reshim update info exec env version"

  plugin_names="$(asdf plugin list 2>/dev/null)"
  plugin_commands="add remove update list list-all"

  case "$prev" in
    asdf)
      COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
      ;;
    plugin)
      COMPREPLY=( $(compgen -W "${plugin_commands}" -- ${cur}) )
      ;;
    global|local|install|uninstall|where|reshim|which|latest)
      COMPREPLY=( $(compgen -W "${plugin_names}" -- ${cur}) )
      ;;
    *)
      ;;
  esac

  return 0
}

complete -F _asdf_completions asdf
