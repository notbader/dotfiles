#!/bin/bash
#
# Bash settings

# Oh my posh settings
# if [ -z "$POSH_THEME" ]; then
#     OH_MY_POSH_DIR="/c/Users/bbal/OneDrive - gmv.com/Desktop/stuff/000_dotfiles/oh_my_posh"
#     export POSH_AUTO_UPGRADE=true
#     THEME_FILE="stelbent-compact.minimal.omp.json"
#     eval "$(oh-my-posh init bash --config "$OH_MY_POSH_DIR/$THEME_FILE")"
# fi


# Set default directory when opening terminal (except when right-clicking and opening terminal)
if [ "$PWD" == "$HOME" ] || [ "$PWD" == "/" ]; then
    cd "$HOME\OneDrive - gmv.com\Desktop\stuff" || exit
fi

# Set home directory
cd() {
    if [ "$#" -eq 0 ]; then
        builtin cd "$HOME\OneDrive - gmv.com\Desktop\stuff" || exit
    else
        builtin cd "$@" || exit
    fi
}

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
    printf "\nλ "
}
function parse_git_dirty {
    [[ $(git status --porcelain 2>/dev/null) ]] && echo "*"
}
function parse_git_branch {
    git branch --no-color 2>/dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/ (\1$(parse_git_dirty))/"
}
PS1="\\n\e[97m\]\t \[\033[33m\]\w\[\e[97m\] ~\[\033[31m\]\$(parse_git_branch)\[\033[00m\]$(new_line)"
export PS1

# Aliases
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias mkdir="mkdir -pv"
alias ll='ls -lhHA --color=auto'
alias ls="ls -CFA --color=auto"
alias llr="ls -lhHAr --color=auto"
alias llR="ls -lhHAR --color=auto"
alias lsl="ls -lhHFA | less --color=auto"
alias sl="ls --color=auto"
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias gs='git status'
alias gd='git diff'
alias gl='git log'
alias gc='git checkout'
alias gp='git push'
alias gm='git merge'
alias gpl='git pull'
alias dotcommit="git add . && git commit -m '.'"
alias treef='cmd //c tree //F'
alias tree='cmd //c tree'



# Create a directory and cd into it
mcd() {
    mkdir -p "$1"
    cd "$1" || exit
}



# # If ~/.inputrc doesn't exist yet: First include the original /etc/inputrc
# # so it won't get overridden
# if [ ! -f ~/.inputrc ]; then
#     include="/etc/inputrc"
#     echo "include $include" >~/.inputrc
# fi

# # Add useful shell options to ~/.inputrc

# # Enable case-insensitive tab completion
# echo 'set completion-ignore-case on' >>~/.inputrc

# # Disable terminal bell sounds
# echo 'set bell-style none' >>~/.inputrc

# # Prevent display of control characters (like ^C for Ctrl+C)
# echo 'set echo-control-characters off' >>~/.inputrc

# # Treat hyphens and underscores as equivalent when completing
# echo 'set completion-map-case on' >>~/.inputrc

# # Append the / character to the end of symlinked directories when completing
# echo 'set mark-symlinked-directories on' >>~/.inputrc

# # Enable colors when completing filenames and directories
# echo 'set colored-stats on' >>~/.inputrc

# # Completion matches of multiple items highlight the matching prefix in color
# echo 'set colored-completion-prefix on' >>~/.inputrc

# # Enable menu-complete for cycling through completion options
# echo 'TAB: menu-complete' >>~/.inputrc
# echo '"\e[Z": menu-complete-backward' >>~/.inputrc

# # Enable incremental history navigation with the UP and DOWN arrow keys
# echo '"\e[A": history-search-backward' >>~/.inputrc
# echo '"\e[B": history-search-forward' >>~/.inputrc

# # Override to ensure the 'i' key works correctly
# echo '"i": self-insert' >>~/.inputrc
# echo '"I": self-insert' >>~/.inputrc
