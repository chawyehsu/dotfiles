# /etc/skel/.bashrc
#######################################################
#  Core Requirements:
#    Windows: Git-Bash
#      macOS: Homebrew, coreutils
#      Linux:
#######################################################

# Test for an interactive shell.
[[ $- != *i* ]] && return

export LANG=en_US.UTF-8
export TZ=UTC-8
# Always display git dirty state
export GIT_PS1_SHOWDIRTYSTATE=1
# Enable Node.js (chalk) color, see https://github.com/chalk/chalk#chalksupportscolor
export FORCE_COLOR=1
# Pipenv environment
export PIPENV_DEFAULT_PYTHON_VERSION=3
export PIPENV_SHELL_FANCY=1
# Xterm colors
if [[ "$TERM" == "xterm" ]]; then
  export TERM=xterm-256color
fi

case "$OSTYPE" in
  darwin*)
    # macOS default PATH:
    #   "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

    # Add Homebrew super formulae directory to PATH:
    if [[ -d "/usr/local/sbin" ]]; then
      export PATH="/usr/local/sbin:$PATH"
    fi

    # Add ~/.local/bin to PATH:
    if [[ -d "$HOME/.local/bin" ]]; then
      export PATH="$HOME/.local/bin:$PATH"
    fi

    # bash-completion:
    if [[ -f "/usr/local/etc/bash_completion" ]]; then
      . /usr/local/etc/bash_completion
    fi

    # Programming-Languages-Specific settings
    # ---------------------------------------
    # Python: Add miniconda
    if [[ -f "/usr/local/Caskroom/miniconda/base/etc/profile.d/conda.sh" ]]; then
      . "/usr/local/Caskroom/miniconda/base/etc/profile.d/conda.sh"
    elif [[ -d "/usr/local/Caskroom/miniconda/base/bin" ]]; then
      export PATH="/usr/local/Caskroom/miniconda/base/bin:$PATH"
    fi
    # Ruby: Add rbenv
    command -v rbenv >/dev/null 2>&1 && eval "$(rbenv init -)"
    ;;
  linux*)
    # Add ~/.local/bin to PATH:
    if [[ -d "$HOME/.local/bin" ]]; then
      export PATH="$HOME/.local/bin:$PATH"
    fi

    # Add git-prompt (Arch Linux):
    if [[ -f "/usr/share/git/completion/git-prompt.sh" ]]; then
      . /usr/share/git/completion/git-prompt.sh
    fi

    # Programming-Languages-Specific settings
    # ---------------------------------------
    # Python: Add miniconda
    if [[ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]]; then
      . "$HOME/miniconda3/etc/profile.d/conda.sh"
    elif [[ -d "$HOME/miniconda3/bin" ]]; then
      export PATH="$HOME/miniconda3/bin:$PATH"
    fi
esac

# Dircolors. Note for macOS: install GNU gdircolors with `brew install coreutils`
command -v gdircolors >/dev/null 2>&1 || alias gdircolors="dircolors"
[[ -f "$HOME/.dircolorsdb" ]] && eval "$(gdircolors -b $HOME/.dircolorsdb)"

# nvm (Need refactoring)
export NVM_DIR="$HOME/.nvm"
[ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/usr/local/opt/nvm/etc/bash_completion" ] && . "/usr/local/opt/nvm/etc/bash_completion"  # This loads nvm

###################
#     Aliases     #
###################
lsoption="-F --show-control-chars --group-directories-first --color=auto"
# Provide an uniform `ls` command on all platforms
case "$OSTYPE" in
  darwin*)
    # Note for macOS: install GNU ls with `brew install coreutils`
    alias ls="gls $lsoption"
    ;;
  linux*)
    alias ls="ls $lsoption"
    ;;
  msys*)
    # There are too many unconcerned files and directories in Windows users' home, ignore them.
    alias ls="ls $lsoption --ignore={navdb.csv,NTUSER*,ntuser*,Application\ Data,Local\ Settings,My\ Documents,NetHood,PrintHood,Recent,SendTo,Templates,Cookies,3D\ Objects,Thumbs.db,desktop.ini,Start\ Menu,「开始」菜单}"
    ;;
esac
unset lsoption

alias l="ls"
alias la="ls -A"
alias ll="ls -lh"
alias lla="ls -lhA"
alias c="clear"
alias :q="exit"
alias ..="cd .."
alias ...="cd ../.."
alias gdf="git diff"
alias gst="git status"
alias myip="curl -s https://api.ip.sb/ip"
# Provide an uniform `cls` command on all platforms
alias cls="clear"

# Platform-Specific aliases
# -------------------------
case "$OSTYPE" in
  darwin*)
    alias here="open ."
    ;;
  msys*)
    # winpty fixes
    alias ipconfig="winpty ipconfig"
    alias nslookup="winpty nslookup"
    alias ping="winpty ping"
    alias java="winpty java"
    alias python="winpty python"
    alias pip="winpty pip"
    # Emulate ifconfig on Windows MSYS
    alias ifconfig="ipconfig"
    # Open window is only available on macOS, emulate it on Windows MSYS,
    # but not on Linux, since I don't use GUI on Linux.
    alias open="explorer"
    alias here="open ."
    ;;
esac

#---------------------------------------#
# SSH Agent on Windows (Git-Bash/MSYS2) #
#---------------------------------------#
# ref: https://help.github.com/articles/working-with-ssh-key-passphrases/#auto-launching-ssh-agent-on-git-for-windows
if [[ $OSTYPE == "msys" ]] && [[ -x "$(command -v ssh)" ]]; then
  # ensure .ssh path
  if [[ ! -d "${USERPROFILE//\\//}/.ssh" ]]; then
    mkdir -p "${USERPROFILE//\\//}/.ssh" >| /dev/null
  fi
  # we use $USERPROFILE instead of $HOME to locate SSH keys and SSH ENV,
  # so we can share ssh keys between Win32-OpenSSH and openssh(Git-Bash & MSYS2)
  # but be aware of that Win32-OpenSSH does not use SSH ENV
  SSH_ENV_PATH="${USERPROFILE//\\//}/.ssh/agent.env"

  # test ssh is Win32-OpenSSH or not
  if [[ ! "$(ssh -V 2>&1)" == *Windows* ]]; then
    [[ -f "$SSH_ENV_PATH" ]] && . "$SSH_ENV_PATH" >| /dev/null
    # agent_run_state:
    #   0=agent running w/ key;
    #   1=agent w/o key;
    #   2=agent not running.
    agent_run_state=$(ssh-add -l >| /dev/null 2>&1; echo $?)
    if [ ! "$SSH_AUTH_SOCK" ] || [ $agent_run_state = 2 ]; then
      (umask 077; ssh-agent >| "$SSH_ENV_PATH") && . "$SSH_ENV_PATH" >| /dev/null
      ssh-add
    elif [ "$SSH_AUTH_SOCK" ] && [ $agent_run_state = 1 ]; then
      ssh-add
    fi
  else
    ssh-agent >| /dev/null
    ssh-add
  fi

  unset SSH_ENV_PATH
fi

# The h404bi's styled prompt on bash shell
# ----------------------------------------
function stylish_bash_prompt () {
  # Color table
  local   RESET="\[\033[0m\]"
  local   BLACK="\[\033[0;30m\]"
  local     RED="\[\033[0;31m\]"
  local   GREEN="\[\033[0;32m\]"
  local  YELLOW="\[\033[0;33m\]"
  local    BLUE="\[\033[0;34m\]"
  local MAGENTA="\[\033[0;35m\]"
  local    CYAN="\[\033[0;36m\]"
  local   WHITE="\[\033[0;37m\]"
  # Terminal title
  local TERM_TITLE="\[\e]0; \w\a\]"

  # Distribution detection
  if [[ "$(uname -r)" == *Microsoft ]]; then
    DIST="${MAGENTA}(WSL)${RESET}"
  elif [[ $MSYSTEM ]]; then
    DIST="${MAGENTA}($MSYSTEM)${RESET}"
  else
    DIST=""
  fi

  # git-prompt
  if [[ -x "$(command -v __git_ps1)" ]]; then
    GITPS1="$(__git_ps1 ' (%s)')"
  else
    GITPS1=""
  fi

  # Python virtualenv state (Deprecated, since we use conda envs...)
  if [[ -z "${VIRTUAL_ENV}" ]]; then
    VIRTUALENV=""
  else
    VIRTUALENV=" ${BLUE}[$(basename ${VIRTUAL_ENV})]${RESET}"
  fi

  # PS1 command substitution issue with newline:
  #   https://stackoverflow.com/questions/33220492/
  #   https://stackoverflow.com/questions/21517281/
  PS1="${TERM_TITLE}${GREEN}\h${DIST}: ${YELLOW}\W${CYAN}${GITPS1}${RESET}${VIRTUALENV}"$'\n\$ '
}
stylish_bash_prompt
