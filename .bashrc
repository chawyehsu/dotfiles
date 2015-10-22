#===== Git Bash =====
PS1='\[\033]0;Git Bash: \w\007\]\[\033[32m\]\h \[\033[33m\]\W\[\033[36m\]`__git_ps1`\[\033[0m\]\n$'

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

#===========================
#===== PYTHON ENV =====
# If we set PY_PYTHON=3, then `py` will use Python3 as the default Python
# export PY_PYTHON=3
# Because in Mintty terminal we use UTF-8 so set PYTHONIOENCODING to utf-8
export PYTHONIOENCODING=utf-8
alias py='winpty py'
alias python='py'
alias python3='py -3'

#===== JAVA ENV =====
export JRE7_HOME='/d/usr/Java/jre1.7.0_79/bin'
alias java7='$JRE7_HOME/java'
# This alias is a helper for initializing the directory structure of a gradle project
alias initJavaProject='mkdir -p src/main/{java,resources} src/test/{java,resources}'
