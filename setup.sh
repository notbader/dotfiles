#!/bin/bash
# shellcheck disable=SC1090

echo
echo "========================================"
echo "Starting Dotfiles Configuration Script"
echo "========================================"

# Get the absolute path to the directory containing this script
DOTFILES_DIR=$(pwd)
SSH_DIR="$DOTFILES_DIR/.ssh"
SHELL_DIR="$DOTFILES_DIR/shell"
VSCODE_DIR="$DOTFILES_DIR/vscode"
BASH_PROFILE="$HOME/.bash_profile"
VIMRC_FILE="$SHELL_DIR/_vimrc"
CODE_USER_DIR="$HOME/AppData/Roaming/Code/User"
MINTTY_CONFIG="$HOME/.minttyrc"
GIT_CONFIG="$HOME/.gitconfig"
INCLUDE_PATH="$SHELL_DIR/gitconfig"
PYTHON_DIR="$DOTFILES_DIR/python"

# Ask Y/n function
function ask() {
    echo "" # Ensure an empty line before each question for clarity
    read -rp "$1 (Y/n): " resp
    if [ -z "$resp" ]; then
        response_lc="y" # empty is Yes
    else
        response_lc=$(echo "$resp" | tr '[:upper:]' '[:lower:]') # case insensitive
    fi
    [ "$response_lc" = "y" ]
}

normalize_path() {
    echo "$1" | sed -e 's/\\/\//g' -e 's/^\([A-Za-z]\):/\/\L\1/'
}

remove_old_entries() {
    local file=$1
    local pattern=$2
    local temp_file="${file}.tmp"
    grep -v "$pattern" "$file" > "$temp_file"
    mv "$temp_file" "$file"
}

find_real_python() {
    # Use 'where' command to find all Python installations
    local python_paths
    python_paths=$(where python 2>/dev/null | grep -v "WindowsApps")

    if [ -z "$python_paths" ]; then
        return 1
    fi

    # Return the first non-WindowsApps Python
    echo "$python_paths" | head -n 1
}

append_python_path_to_bash_profile() {
    # Find the real Python executable
    PYTHON_EXE=$(find_real_python)

    if [ -z "$PYTHON_EXE" ]; then
        echo "WARNING: Python is not installed or not in PATH"
        echo "Skipping Python path configuration"
        return 1
    fi

    echo "Found Python at: $PYTHON_EXE"

    # Convert to Unix path and use it to get Scripts directory
    PYTHON_EXE_UNIX=$(normalize_path "$PYTHON_EXE")

    # Get Python Scripts directory using the real Python executable
    PYTHON_SCRIPTS_WIN=$("$PYTHON_EXE_UNIX" -c "import sysconfig; print(sysconfig.get_path('scripts'))" 2>/dev/null)

    if [ -z "$PYTHON_SCRIPTS_WIN" ]; then
        echo "ERROR: Could not determine Python Scripts directory"
        return 1
    fi

    PYTHON_SCRIPTS=$(normalize_path "$PYTHON_SCRIPTS_WIN")

    echo "Detected Python Scripts directory: $PYTHON_SCRIPTS"

    # Verify the Scripts directory exists
    if [ ! -d "$PYTHON_SCRIPTS" ]; then
        echo "Warning: Python Scripts directory does not exist: $PYTHON_SCRIPTS"
        echo "Creating directory..."
        mkdir -p "$PYTHON_SCRIPTS"
    fi

    # Remove old Python PATH entries
    if grep -q 'export PATH=.*Python.*Scripts' "$BASH_PROFILE"; then
        echo "Removing old Python PATH entries"
        remove_old_entries "$BASH_PROFILE" 'export PATH=.*Python.*Scripts'
    fi

    # Remove old Python PYTHONPATH entries
    if grep -q 'export PYTHONPATH=.*Python.*Scripts' "$BASH_PROFILE"; then
        echo "Removing old Python PYTHONPATH entries"
        remove_old_entries "$BASH_PROFILE" 'export PYTHONPATH=.*Python.*Scripts'
    fi

    # Add new PATH
    echo "export PATH=\"$PYTHON_SCRIPTS:\$PATH\"" >> "$BASH_PROFILE"

    # Add new PYTHONPATH
    echo "export PYTHONPATH=\"$PYTHON_SCRIPTS:\$PYTHONPATH\"" >> "$BASH_PROFILE"

    printf "\nPython paths added to .bash_profile.\n"
}

## Main script

# Create .bash_profile in $HOME that sources .bashrc in $SHELL_DIR
if ask "Do you want to create or update .bash_profile in $HOME?"; then
    if [ -f "$BASH_PROFILE" ]; then
        printf "\n.bash_profile already exists.\n"
    else
        {
            echo "#!/bin/bash"
            echo "# shellcheck disable=SC1091"
            echo "export SSH_HOME='$SSH_DIR'"
            echo "if [ -f \"$SHELL_DIR/.bashrc\" ]; then"
            echo "    source \"$SHELL_DIR/.bashrc\""
            echo "fi"
        } >"$BASH_PROFILE"
        attrib +h "$BASH_PROFILE"
        printf "\n.bash_profile created and configured.\n"
    fi
fi

if ask "Do you want to add Python paths to .bash_profile?"; then
    append_python_path_to_bash_profile
fi

# Copy vimrc
if ask "Do you want to copy _vimrc to $HOME?"; then
    if [ -f "$HOME/_vimrc" ]; then
        if ask "Do you want to overwrite the existing _vimrc?"; then
            cp "$VIMRC_FILE" "$HOME/_vimrc"
            printf "\n%s has been updated in %s.\n" "_vimrc" "$HOME"
        else
            printf "\nNo changes made to the existing _vimrc.\n"
        fi
    else
        cp "$VIMRC_FILE" "$HOME/_vimrc"
        attrib +h "$HOME/_vimrc"
        printf "\n_vimrc has been copied to %s.\n" "$HOME"
    fi
fi

# Handle vscode files
printf "\nProcessing VS Code configuration files...\n"

for file in "$VSCODE_DIR"/*; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        # Copy the file instead of creating a symlink
        if [ -f "$CODE_USER_DIR/$filename" ]; then
            printf "\nA file named %s already exists in the destination.\n" "$filename"
            if ask "Do you want to overwrite the existing file?"; then
                cp "$file" "$CODE_USER_DIR/$filename"
                printf "\nFile %s has been updated in the destination.\n" "$filename"
            else
                printf "\nNo changes made to the existing file at the destination.\n"
            fi
        else
            if ask "Do you want to copy $filename to the destination?"; then
                cp "$file" "$CODE_USER_DIR/$filename"
                printf "\nFile %s has been copied to the destination.\n" "$filename"
            fi
        fi
    fi
done

printf "\nFinalizing installation...\n"

# Source shell scripts in .bashrc, excluding .vimrc and _vimrc files
BASHRC_SOURCE_HEADER='# -------------- Dotfiles install ---------------'
if ! grep -qxF "$BASHRC_SOURCE_HEADER" "$BASH_PROFILE"; then
    echo "" >>"$BASH_PROFILE"
    echo "$BASHRC_SOURCE_HEADER" >>"$BASH_PROFILE"
fi

for file in "$DOTFILES_DIR/shell/"*; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        if [[ "$filename" != ".vimrc" && "$filename" != "_vimrc" ]]; then
            if ask "Do you want to source ${filename} in .bashrc?"; then
                SOURCE_CMD="source \"$file\""
                if ! grep -qxF "$SOURCE_CMD" "$BASH_PROFILE"; then
                    echo "$SOURCE_CMD" >>"$BASH_PROFILE"
                fi
            fi
        fi
    fi
done
echo '# -------------- End of Dotfiles install ---------------' >>"$BASH_PROFILE"

# Check if .gitconfig already exists
if [ ! -f "$GIT_CONFIG" ]; then
    printf "\nCreating .gitconfig file...\n"
    touch "$GIT_CONFIG"
fi

# Append or update user info in .gitconfig
if ask "Do you want to append or update user info in .gitconfig?"; then
    if ! grep -q "\[user\]" "$GIT_CONFIG"; then
        {
            echo "[user]"
            echo "    name = notBader"
            echo "    email = "
        } >>"$GIT_CONFIG"
    fi
fi

# Include external git config if it hasn't been included already
if ask "Do you want to include external git configuration from $INCLUDE_PATH?"; then
    if ! grep -q "\[include\]" "$GIT_CONFIG"; then
        echo "[include]" >>"$GIT_CONFIG"
        echo "    path = $INCLUDE_PATH" >>"$GIT_CONFIG"
    elif ! grep -q "path = $INCLUDE_PATH" "$GIT_CONFIG"; then
        sed -i "/\[include\]/a\    path = $INCLUDE_PATH" "$GIT_CONFIG"
    fi
fi

# Check and hide specific configuration files in the home directory
printf "\nChecking and setting files as hidden...\n"
FILES_TO_HIDE=(".gitconfig" ".inputrc" ".viminfo" ".minttyrc" ".bash_history")

# Set GitBash theme to Dracula
if ask "Do you want to set the Dracula theme for Git Bash?"; then
    echo "ThemeFile=dracula" >"$MINTTY_CONFIG"
    echo "Dracula theme set for Git Bash."
fi

for file in "${FILES_TO_HIDE[@]}"; do
    full_path="$HOME/$file"
    if [ -f "$full_path" ]; then
        if ask "Do you want to hide $file?"; then
            attrib +h "$full_path"
            printf "\n%s is now hidden.\n" "$file"
        else
            printf "\nNo changes made for %s.\n" "$file"
        fi
    else
        printf "\n%s does not exist at %s.\n" "$file" "$full_path"
    fi
done

source ~/.bash_profile

echo
echo "Process complete."
echo "========================================"
