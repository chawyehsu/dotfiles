# shellcheck disable=SC2148
# /etc/skel/.bash_profile

# ~/.bash_profile: This file is sourced by bash(1) for login shells.

# The following line runs your .bashrc.
# shellcheck disable=SC1090
[ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc"
