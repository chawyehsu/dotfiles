# reuse .bashrc settings
[ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc"

# zle keybinds
bindkey "^[A" history-search-backward
bindkey "^[B" history-search-forward
bindkey "^[1~" beginning-of-line
bindkey "^[4~" end-of-line
bindkey "^[s" backward-word
bindkey "^[f" forward-word
bindkey "^[e" history-search-backward
bindkey "^[d" history-search-forward
bindkey "^[h" backward-char
bindkey "^[l" forward-char
bindkey "^[b" beginning-of-line
bindkey "^[n" end-of-line
bindkey "^[3;3~" kill-word
bindkey "^[^H" backward-kill-word
