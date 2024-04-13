#!/bin/bash
# shellcheck disable=SC1091

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
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

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

# -------------- Dotfiles install ---------------
source "$HOME/Desktop/stuff/dot_files/shell/case_insensitive_completion.sh"
source "$HOME/Desktop/stuff/dot_files/shell/git_aliases.sh"
source "$HOME/Desktop/stuff/dot_files/shell/ssh_agent_auto_start.sh"
if [ -f "$HOME/Desktop/stuff/dot_files/shell/.inputrc" ]; then source "$HOME/Desktop/stuff/dot_files/shell/.inputrc"; fi
# -------------- End of Dotfiles install ---------------
