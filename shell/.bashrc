#!/bin/bash

# Set default directory
if [ -z "$PWD" ] || [ "$PWD" == "/" ]; then
    cd "$HOME/Desktop/stuff" || exit
fi
#ldkn;lsakjndfsldkjfnlskdjnflkjnfskdjnfksdjnfksdjnfksdjnfksdjfnksdjfnksdjfnksdjfnksdjfnksdjfnksdjfnkj
# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt
if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        color_prompt=yes
    else
        color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\e[34m\]λ\[\e[33m\]\$(parse_git_branch)\[\033[00m\]'
else
    PS1='${debian_chroot:+($debian_chroot)}\[\e[33m\]λ\[\e[34m\]\$(parse_git_branch)\[\033[00m\] '
fi
unset color_prompt force_color_prompt

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    if test -r ~/.dircolors; then
        eval "$(dircolors -b ~/.dircolors)"
    else
        eval "$(dircolors -b)"
    fi
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Change Prompt
parse_git_branch() {
    git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}
export PS1=" \[\e[34m\]λ \[\033[33m\]~ \[\033[33m\]\W\[\033[31m\]\$(parse_git_branch)\[\033[00m\] "

echo -n -e "\033]0;Bash\007"

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
