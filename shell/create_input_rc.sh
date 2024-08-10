#!/bin/bash

# If ~/.inputrc doesn't exist yet: First include the original /etc/inputrc
# so it won't get overridden
if [ ! -f ~/.inputrc ]; then
    include="/etc/inputrc"
    echo "include $include" >~/.inputrc
fi

# Add useful shell options to ~/.inputrc

# Enable case-insensitive tab completion
echo 'set completion-ignore-case on' >>~/.inputrc

# Disable terminal bell sounds
echo 'set bell-style none' >>~/.inputrc

# Prevent display of control characters (like ^C for Ctrl+C)
echo 'set echo-control-characters off' >>~/.inputrc

# Treat hyphens and underscores as equivalent when completing
echo 'set completion-map-case on' >>~/.inputrc

# Append the / character to the end of symlinked directories when completing
echo 'set mark-symlinked-directories on' >>~/.inputrc

# Enable colors when completing filenames and directories
echo 'set colored-stats on' >>~/.inputrc

# Completion matches of multiple items highlight the matching prefix in color
echo 'set colored-completion-prefix on' >>~/.inputrc

# Enable menu-complete for cycling through completion options
echo 'TAB: menu-complete' >>~/.inputrc
echo '"\e[Z": menu-complete-backward' >>~/.inputrc

# Enable incremental history navigation with the UP and DOWN arrow keys
echo '"\e[A": history-search-backward' >>~/.inputrc
echo '"\e[B": history-search-forward' >>~/.inputrc

# Override to ensure the 'i' key works correctly
echo '"i": self-insert' >>~/.inputrc
echo '"I": self-insert' >>~/.inputrc
