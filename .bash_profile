# correct timezone and date
export TZ=UTC-8

# auto startup ssh-agent
if [ -f "${HOME}/.pre-script/ssh-agent.run" ] ; then
  source "${HOME}/.pre-script/ssh-agent.run"
fi

# export ~/.solarized-dark.dircolors
if [ -f "${HOME}/.pre-script/solarized-dark.dircolorsdb" ] ; then
  eval `dircolors ${HOME}/.pre-script/solarized-dark.dircolorsdb`
fi

# source ~/.bashrc
if [ -f "${HOME}/.bashrc" ] ; then
  source "${HOME}/.bashrc"
fi
