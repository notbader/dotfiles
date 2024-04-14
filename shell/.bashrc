#!/bin/bash
# shellcheck disable=SC1091
# Set SSH directory

# Set default directory
if [ -z "$PWD" ] || [ "$PWD" == "/" ]; then
    cd "$HOME/Desktop/stuff" || exit
fi

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    if test -r ~/.dircolors; then
        eval "$(dircolors -b ~/.dircolors)"
    else
        eval "$(dircolors -b)"
    fi
    alias ls='ls --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Change Prompt
new_line() {
    printf "\n$ "
}
function parse_git_dirty {
    [[ $(git status --porcelain 2>/dev/null) ]] && echo "*"
}
function parse_git_branch {
    git branch --no-color 2>/dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/ (\1$(parse_git_dirty))/"
}
PS1="\[\e[97m\]\t \[\033[33m\]\w\[\e[97m\] ~\[\033[31m\]\$(parse_git_branch)\[\033[00m\]$(new_line)"
export PS1

# Aliases
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias ll="ls -lhA"
alias ls="ls -CF"
alias sl="ls"
alias lsl="ls -lhFA | less"
alias mkdir="mkdir -pv"

# Create a directory and cd into it
mcd() {
    mkdir -p "$1"
    cd "$1" || exit
}
HISTTIMEFORMAT="%d/%m/%y %T "
