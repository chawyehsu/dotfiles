export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export TZ=UTC-8

# Solarized color theme for ls command:
if [ -x /usr/bin/dircolors ]; then
  eval `dircolors ${HOME}/.dir_colors`
fi

# --= Alias =--
alias ls='ls -F --show-control-chars --color=auto'
alias ll='ls -lh'
alias la='ll -A'
alias l='ls'
alias ..='cd ..'
alias c='clear'
alias q='exit'
alias quit='exit'
alias gdf='git diff'
alias gst='git status'
