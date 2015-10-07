# export
export JRE7_HOME='/d/usr/Java/jre1.7.0_79/bin'

# Git Bash
PS1='\[\033]0;Git Bash: \w\007\]\[\033[32m\]\h \[\033[33m\]\W\[\033[36m\]`__git_ps1`\[\033[0m\]\n$'

# Hide useless folders
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

alias open='explorer'
alias here='open .'

alias java7='$JRE7_HOME/java'

alias python='winpty python'
alias python3='winpty python3'

# for gradle
alias initJavaProject='mkdir -p src/main/{java,resources} src/test/{java,resources}'
