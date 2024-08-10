#!/bin/bash
#
# Bash settings
export SSH_HOME='$HOME/Desktop/stuff/000_dotfiles/.ssh'

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'


source "$HOME/Desktop/stuff/000_dotfiles/shell/create_input_rc.sh"
source "$HOME/Desktop/stuff/000_dotfiles/shell/ssh_agent_auto_start.sh"
source "$HOME/Desktop/stuff/000_dotfiles/shell/git_aliases.sh"

# Oh my posh settings
OH_MY_POSH_DIR="$HOME/Desktop/stuff/000_dotfiles/oh_my_posh"
THEME_FILE="stelbent-compact.minimal.omp.json"
eval "$(oh-my-posh init bash --config "$OH_MY_POSH_DIR/$THEME_FILE")"


# Set default directory when opening terminal (except when right-clicking and opening terminal)
if [ "$PWD" == "$HOME" ] || [ "$PWD" == "/" ]; then
    cd "$HOME/Desktop/stuff" || exit
fi

# Set home directory
cd() {
    if [ "$#" -eq 0 ]; then
        builtin cd "$HOME/Desktop/stuff" || exit
    else
        builtin cd "$@" || exit
    fi
}

# enable color support of ls and grep
if [ -x /usr/bin/dircolors ]; then
    if test -r ~/.dircolors; then
        eval "$(dircolors -b ~/.dircolors)"
    else
        eval "$(dircolors -b)"
    fi
    alias ll='ls -lhHA --color=auto'
    alias ls="ls -CFA --color=auto"
    alias llr="ls -lhHAr --color=auto"
    alias llR="ls -lhHAR --color=auto"
    alias lsl="ls -lhHFA | less --color=auto"
    alias sl="ls --color=auto"
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Aliases
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias mkdir="mkdir -pv"

# Create a directory and cd into it
mcd() {
    mkdir -p "$1"
    cd "$1" || exit
}
