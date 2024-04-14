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
PYTHON_INSTALL_PATH="$HOME/AppData/Local/Programs/Python/"

# Function to install Visual Studio Code and extensions
function install_vscode() {
    printf "\nChecking for Visual Studio Code installation...\n"

    # Check if VS Code is installed
    if winget list --id Microsoft.VisualStudioCode | grep -q "Microsoft.VisualStudioCode"; then
        printf "\nVisual Studio Code is already installed.\n"
    else
        # Proceed with the installation if VS Code is not found
        if ask "Visual Studio Code is not installed. Do you want to install it now?"; then
            echo "Installing Visual Studio Code..."
            winget install -e --id Microsoft.VisualStudioCode --silent \
                --override "addcontextmenufiles=1 addcontextmenufolders=1 associatewithfiles=1 addtopath=1"
            printf "\nVisual Studio Code installed.\n"
        fi
    fi

    # Ask to install extensions regardless of installation
    if ask "Do you want to install/update Visual Studio Code extensions?"; then
        echo "Installing VS Code extensions..."
        local extensions=(
            "charliermarsh.ruff"
            "dotjoshjohnson.xml" "dracula-theme.theme-dracula-pro" "github.copilot"
            "github.copilot-chat" "ms-python.python"
            "timonwong.shellcheck" "visualstudioexptteam.vscodeintellicode"
            "vscodevim.vim" "pkief.material-icon-theme"
            "foxundermoon.shell-format"
        )

        for ext in "${extensions[@]}"; do
            if command -v code >/dev/null; then
                code --install-extension "$ext" >/dev/null 2>&1
            else
                echo "VS Code command line tool not found. Skipping extension installation."
                break
            fi
        done
        echo "VS Code extensions installation complete."
    fi
}

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

# Function to check if Python executable exists in the known install path
function check_python_installation() {
    local python_installed=false
    local python_path=""

    # Check if any version of Python is installed in the known directory
    for dir in "$PYTHON_INSTALL_PATH"/*/; do
        if [[ -f "${dir}python.exe" ]]; then
            python_installed=true
            python_path="${dir}python.exe"
            break
        fi
    done

    if $python_installed; then
        printf "\nPython is installed at %s\n" "$python_path"
        # Check if Python is in PATH
        if ! python --version &>/dev/null; then
            printf "\nPython is not in PATH. Adding to PATH...\n"
            add_python_to_path "$python_path"
        else
            printf "\nPython is already in PATH.\n"
        fi
    else
        printf "\nPython is not installed in the expected directory.\n"
        install_python
    fi
}

# Function to check and update Python path
function add_python_to_path() {
    local python_exe_path=$1
    local python_dir
    python_dir=$(dirname "$python_exe_path")
    local scripts_dir="$python_dir/Scripts"

    # Use PowerShell to add the Python directory and Scripts directory to PATH and PYTHONPATH
    powershell.exe -Command "
    \$python_dir = '${python_dir}'
    \$scripts_dir = '${scripts_dir}'

    # Add to PATH if not already present
    \$path = [System.Environment]::GetEnvironmentVariable('PATH', [System.EnvironmentVariableTarget]::User)
    if (-not \$path.Contains(\$python_dir)) {
        \$path = \$path + ';' + \$python_dir
    }
    if (-not \$path.Contains(\$scripts_dir)) {
        \$path = \$path + ';' + \$scripts_dir
    }
    [System.Environment]::SetEnvironmentVariable('PATH', \$path, [System.EnvironmentVariableTarget]::User)

    # Add to PYTHONPATH if not already present
    \$pythonpath = [System.Environment]::GetEnvironmentVariable('PYTHONPATH', [System.EnvironmentVariableTarget]::User)
    if (\$null -eq \$pythonpath) {
        \$pythonpath = ''
    }
    if (-not \$pythonpath.Contains(\$python_dir)) {
        \$pythonpath = \$pythonpath + ';' + \$python_dir
    }
    if (-not \$pythonpath.Contains(\$scripts_dir)) {
        \$pythonpath = \$pythonpath + ';' + \$scripts_dir
    }
    [System.Environment]::SetEnvironmentVariable('PYTHONPATH', \$pythonpath, [System.EnvironmentVariableTarget]::User)
    "
    printf "\nPython directory and Scripts have been added to PATH and PYTHONPATH.\n"
}

# Function to prompt user to install Python
function install_python() {
    echo "Please download and install Python from the official website or the software center."
}

append_path_to_bash_profile() {
    python_paths=()

    # Find all directories within the Python installation path
    for directory in "$PYTHON_INSTALL_PATH"/*; do
        if [ -d "$directory" ]; then
            python_paths+=("$(realpath "$directory")")
        fi
    done

    # Append each directory to the PATH environment variable
    {
        echo "# Add Python to PATH"
        for path in "${python_paths[@]}"; do
            echo "export PATH=\"$path:\$PATH\""
        done
    } >>"$BASH_PROFILE"

    printf "\nPython paths added to .bash_profile.\n"
}

## Main script

# Check Python installation and prompt for installation if necessary
if ! check_python_installation; then
    install_python
fi

# Check if winget is available
printf "\nChecking for winget...\n"
if ! command -v winget &>/dev/null; then
    printf "\nwinget is not installed. Please install winget or run this script on a compatible system.\n"
    exit 1
else
    install_vscode
fi

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
append_path_to_bash_profile

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

# Handle Python linting files
if [ -d "$PYTHON_DIR" ]; then
    for file in "$PYTHON_DIR"/*; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            # Ask before copying each file
            if ask "Do you want to copy $filename to your home directory?"; then
                cp "$file" "$HOME/$filename"
                printf "\nFile %s has been copied to the home directory.\n" "$filename"
                # Set file to hidden
                attrib +h "$HOME/$filename"
            else
                printf "\nNo changes made to %s.\n" "$filename"
            fi
        fi
    done
else
    printf "\nPython directory not found.\n"
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
            echo "    email = " # Leave email empty
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
