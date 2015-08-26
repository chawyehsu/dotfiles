# Correct Timezone and date
export TZ=UTC-8

# source the users bashrc if it exists
if [ -f "${HOME}/.bashrc" ] ; then
  source "${HOME}/.bashrc"
fi

# Auto-launching ssh-agent
if [ -f "${HOME}/.autossh" ] ; then
  source "${HOME}/.autossh"
fi
