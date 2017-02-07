# setup prompt
function set_bash_prompt() {
  # color table
  local   RESET="\[\033[0m\]"
  local   BLACK="\[\033[0;30m\]"
  local     RED="\[\033[0;31m\]"
  local   GREEN="\[\033[0;32m\]"
  local  YELLOW="\[\033[0;33m\]"
  local    BLUE="\[\033[0;34m\]"
  local MAGENTA="\[\033[0;35m\]"
  local    CYAN="\[\033[0;36m\]"
  local   WHITE="\[\033[0;37m\]"
  # terminal title
  local TERM_TITLE="\[\e]0; \w\a\]"

  # python virtualenv state
  if [ -z "$VIRTUAL_ENV" ]; then
    VIRTUALENV=""
  else
    VIRTUALENV=" ${BLUE}[$(basename $VIRTUAL_ENV)]${RESET}"
  fi

  # show git dirty state
  export GIT_PS1_SHOWDIRTYSTATE=1

  PS1="${TERM_TITLE}${GREEN}\h: ${YELLOW}\W${CYAN}"
  PS1="$PS1$(__git_ps1)"
  PS1="$PS1${RESET}${VIRTUALENV}\n\$ "
}

PROMPT_COMMAND=set_bash_prompt
