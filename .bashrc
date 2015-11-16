#===== Git Bash Prompt =====
source ~/.bash_prompt

#===== ls command alias =====
# There are too many unconcerned files or directories in Windows Users home folder.
alias ls='ls --color=auto --ignore={\
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
Thumbs.db,\
desktop.ini,\
「开始」菜单*}'

alias ll='ls -lhF'
alias la='ll -A'

#===== explorer helper =====
alias open='explorer'
alias here='open .'

#===== Git alias =====
alias gdf='git diff'
alias gst='git status'

#===========================
#===== PYTHON ENV =====
# If we set PY_PYTHON=3, then `py` will use Python3 as the default Python
# export PY_PYTHON=3
# via http://hackercodex.com/guide/python-development-environment-on-mac-osx/
# pip should only run if there is a virtualenv currently activated
export PIP_REQUIRE_VIRTUALENV=true
gpip(){
    PIP_REQUIRE_VIRTUALENV="" winpty pip "$@"
}
gpip3(){
    PIP_REQUIRE_VIRTUALENV="" winpty pip3 "$@"
}
alias py='winpty py'

#===== JAVA ENV =====
export JRE7_HOME='/d/usr/Java/jre1.7.0_79/bin'
alias java7='$JRE7_HOME/java'
# This alias is a helper for initializing the directory structure of a gradle project
alias initJavaProject='mkdir -p src/main/{java,resources} src/test/{java,resources}'
