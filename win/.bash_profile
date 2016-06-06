export TZ=UTC-8
# auto startup ssh-agent:
source "${HOME}/.ssh/ssh-agent.run"
# Solarized color theme for ls command:
eval `dircolors ${HOME}/.dir_colors`
# Import prompt settings:
source ${HOME}/.bash_prompt

# --= Alias =--
alias ..='cd ..'
alias c='clear'
alias q='exit'
alias quit='exit'
# ls command alias
# There are too many unconcerned files or directories
# in the Windows Users' home folder.
alias ls='ls -F --show-control-chars --color=auto --ignore={\
.VirtualBox*,\
.IdeaIC14*,\
navdb.csv,\
NTUSER*,\
ntuser*,\
AppData*,\
Application\ Data*,\
Local\ Settings*,\
My\ Documents*,\
NetHood*,\
PrintHood*,\
Recent*,\
SendTo*,\
Templates*,\
Cookies*,\
OneDrive*,\
3D\ Objects,\
Thumbs.db,\
desktop.ini,\
「开始」菜单*}'
alias ll='ls -lh'
alias la='ll -A'
alias l='ls'
# explorer helper, quick terminal->explorer
alias open='explorer'
alias here='open .'
# git alias
alias gdf='git diff'
alias gst='git status'
# PYTHON ENV
# cf. http://hackercodex.com/guide/python-development-environment-on-mac-osx/
# pip should only run if there is a virtualenv currently activated
export PIP_REQUIRE_VIRTUALENV=true
gpip() {
    PIP_REQUIRE_VIRTUALENV="" pip "$@"
}
gpip3() {
    PIP_REQUIRE_VIRTUALENV="" winpty pip3 "$@"
}
alias py='winpty py'
# JAVA ENV
# System-wide is the newest version of Java with JDK, in Mintty
# add old java7 support with Java JRE 7 portable
export JRE7_HOME='/d/usr/Java/jre1.7.0_79/bin'
alias java7='winpty $JRE7_HOME/java'
alias java='winpty java'
# This alias is a helper for initializing
# the directory structure of a gradle project
alias initJavaProject='mkdir -p src/main/{java,resources} \
src/test/{java,resources}'
# other Windows commands
alias ipconfig='winpty ipconfig'
alias ifconfig='ipconfig'
alias nslookup='winpty nslookup'
alias ping='winpty ping'

# if has .bashrc source it
if [ -f "${HOME}/.bashrc" ] ; then
  source "${HOME}/.bashrc"
fi

