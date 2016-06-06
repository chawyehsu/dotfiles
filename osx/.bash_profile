export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export TZ=UTC-8
# OSX default PATH is:
#   "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
# Add Homebrew super formulae to PATH:
export PATH="/usr/local/sbin:$PATH"
#
# Import prompt settings
if [ -f ${HOME}/.bash_prompt ]; then
  . ${HOME}/.bash_prompt
fi
# Source bash-completion formula:
if [ -f $(brew --prefix)/etc/bash_completion ]; then
  . $(brew --prefix)/etc/bash_completion
fi
# Solarized color theme for ls command:
#   * make sure installed GNU ls (brew install coreutils)
if brew list --versions coreutils >/dev/null && [ -f ${HOME}/.dir_colors ]; then
  eval `gdircolors ${HOME}/.dir_colors`
  alias ls='gls -F --show-control-chars --color=auto'
fi
# Powerline status: 
#  1) install brewed python (brew install python)
#  2) use brewed python's pip install powerline-status
#if brew list --versions python >/dev/null && powerline-daemon -h >/dev/null; then
#  powerline-daemon -q
#  POWERLINE_BASH_CONTINUATION=1
#  POWERLINE_BASH_SELECT=1
#  . $(brew --prefix)/lib/python2.7/site-packages/powerline/bindings/bash/powerline.sh
#fi
# jenv(java):
#[[ -s "${HOME}/.jenv/bin/jenv-init.sh" ]] && \
#. "${HOME}/.jenv/bin/jenv-init.sh" && \
#. "${HOME}/.jenv/commands/completion.sh"
# nvm(node, npm):
export NVM_DIR="${HOME}/.nvm"
. "$(brew --prefix nvm)/nvm.sh"
# pyenv, pyenv-virtualenv(python):
if which pyenv >/dev/null; then
  eval "$(pyenv init -)";
  # cf. https://github.com/yyuu/pyenv/issues/106#issuecomment-94921352
  alias brew="env PATH=${PATH//$(pyenv root)\/shims:/} brew"
fi
if which pyenv-virtualenv-init >/dev/null; then
  eval "$(pyenv virtualenv-init -)";
fi

# --= Alias =--
alias ..='cd ..'
alias c='clear'
alias q='exit'
alias quit='exit'
alias l='ls'
alias ll='ls -lh'
alias la='ll -A'
alias here='open .'
alias gdf='git diff'
alias gst='git status'
alias cnpm="npm --registry=https://registry.npm.taobao.org \
    --cache=${HOME}/.npm/.cache/cnpm \
    --disturl=https://npm.taobao.org/dist \
    --userconfig=${HOME}/.cnpmrc"

