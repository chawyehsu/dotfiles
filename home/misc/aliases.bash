local lsoption="-F --show-control-chars --group-directories-first --color=auto"
case "${OSTYPE}" in
  darwin*)
    alias ls="gls ${lsoption}"
    ;;
  linux*)
    alias ls="ls ${lsoption}"
    ;;
  msys*)
    # There are too many unconcerned files and directories in Windows Users home.
    alias ls="ls ${lsoption} --ignore={navdb.csv,NTUSER*,ntuser*,Application\ Data,Local\ Settings,My\ Documents,NetHood,PrintHood,Recent,SendTo,Templates,Cookies,3D\ Objects,Thumbs.db,desktop.ini,「开始」菜单}"
    ;;
esac
alias l="ls"
alias ll="ls -lh"
alias la="ll -A"

if [[ ${OSTYPE} == "msys" ]]; then
  alias ipconfig="winpty ipconfig"
  alias nslookup="winpty nslookup"
  alias ping="winpty ping"
  alias java="winpty java"
  alias python="winpty python"
  alias pip="winpty pip"
  alias open="explorer"
  alias ifconfig="ipconfig"
fi

alias here="open ."
alias ..="cd .."
alias cd..="cd .."
alias c="clear"
alias :q="exit"
alias gdf="git diff"
alias gst="git status"
alias ip="curl ip.gs"
