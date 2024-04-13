#!/bin/bash

echo
echo "========================================"
echo "Starting Dotfiles Configuration Script"
echo "========================================"

# Get the absolute path to the directory containing this script
DOTFILES_DIR=$(pwd)
SHELL_DIR="$DOTFILES_DIR/shell"
SSH_DIR="$DOTFILES_DIR/ssh"
VSCODE_DIR="$DOTFILES_DIR/vscode"
PYTHON_DIR="$DOTFILES_DIR/python"

HOME_DEST="$HOME"
CODE_USER_DIR="$HOME/AppData/Roaming/Code/User"

RC_FOR_SOURCE="$HOME/.bashrc"

# Function to install Visual Studio Code and extensions
function install_vscode() {
    printf "\nChecking for Visual Studio Code installation..."

    # Check if VS Code is installed
    if winget list --id Microsoft.VisualStudioCode | grep -q "Microsoft.VisualStudioCode"; then
        printf "\nVisual Studio Code is already installed.\n"
    else
        # Proceed with the installation if VS Code is not found
        if ask "Visual Studio Code is not installed. Do you want to install it now?"; then
            echo "Installing Visual Studio Code..."
            winget install -e --id Microsoft.VisualStudioCode --silent \
                --override "addcontextmenufiles=1 addcontextmenufolders=1 associatewithfiles=1 addtopath=1"
            echo "Visual Studio Code installed."
        fi
    fi

    # Ask to install extensions regardless of installation
    if ask "Do you want to install/update Visual Studio Code extensions?"; then
        echo "Installing VS Code extensions..."
        local extensions=(
            "adpyke.vscode-sql-formatter" "angular.ng-template" "charliermarsh.ruff"
            "dotjoshjohnson.xml" "dracula-theme.theme-dracula-pro" "github.copilot"
            "github.copilot-chat" "kevinrose.vsc-python-indent" "ms-python.python"
            "redhat.java" "timonwong.shellcheck" "visualstudioexptteam.vscodeintellicode"
            "vscjava.vscode-java-pack" "vscodevim.vim" "pkief.material-icon-theme"
            "formulahendry.code-runner" "foxundermoon.shell-format"
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

# Function to handle the creation of symlinks
function create_symlink() {
    local src="$1"
    local dest="$2"
    local hide
    hide="${3:-true}"
    if [ -f "$dest" ] || [ -L "$dest" ]; then
        printf "\nA symlink or file already exists at %s", "$dest"
        if ask "Do you want to overwrite the existing symlink or file?"; then
            ln -sf "$src" "$dest"
            echo "Symlink for $(basename "$src") has been updated to point to $dest."
            if [ "$hide" = true ]; then
                attrib +h "$dest"
                echo "Hidden attribute set for $dest."
            fi
        else
            echo "No changes made to existing symlink or file at $dest."
        fi
    elif ask "Do you want to create a symlink for $(basename "$src") in $dest?"; then
        ln -sf "$src" "$dest"
        echo "Symlink created for $(basename "$src") to $dest."
        if [ "$hide" = true ]; then
            attrib +h "$dest"
        fi
    fi
}

# Update environment variables
function update_environment_variables() {
    echo "Updating environment variables based on Python installation paths..."

    # Use PowerShell to handle the path extraction and environment variable update
    powershell.exe -Command "
    # Get Python paths from where command
    \$pythonPaths = (Get-Command python).Source | Select-Object -Unique

    # Prepare the paths to add to PATH and PYTHONPATH
    \$pathsToAdd = @()
    foreach (\$path in \$pythonPaths) {
        if (\$path -notlike '*WindowsApps*') {  # Exclude paths that are typically not real Python installations like WindowsApps
            \$dir = Split-Path -Parent \$path
            \$pathsToAdd += \$dir  # Add the base directory
            \$scriptsPath = Join-Path -Path \$dir -ChildPath 'Scripts'
            \$pathsToAdd += \$scriptsPath  # Add the Scripts directory
        }
    }

    # Update PATH
    \$currentPath = [System.Environment]::GetEnvironmentVariable('PATH', [System.EnvironmentVariableTarget]::User)
    foreach (\$path in \$pathsToAdd) {
        if (-not \$currentPath.Contains(\$path)) {
            \$currentPath += ';'+\$path
        }
    }
    [System.Environment]::SetEnvironmentVariable('PATH', \$currentPath, [System.EnvironmentVariableTarget]::User)

    # Update PYTHONPATH to include the same paths (if needed)
    \$currentPythonPath = [System.Environment]::GetEnvironmentVariable('PYTHONPATH', [System.EnvironmentVariableTarget]::User)
    if (\$currentPythonPath -ne \$null) {
        foreach (\$path in \$pathsToAdd) {
            if (-not \$currentPythonPath.Contains(\$path)) {
                \$currentPythonPath += ';'+\$path
            }
        }
    } else {
        \$currentPythonPath = [String]::Join(';', \$pathsToAdd)
    }
    [System.Environment]::SetEnvironmentVariable('PYTHONPATH', \$currentPythonPath, [System.EnvironmentVariableTarget]::User)
    "

    echo "Environment variables PATH and PYTHONPATH have been updated."
}

## Main script

# Check if winget is available
printf "\nChecking for winget...\n"
if ! command -v winget &>/dev/null; then
    echo "winget is not installed. Please install winget or run this script on a compatible system."
    exit 1
else
    install_vscode
fi

# Handle shell configuration files
printf "\nProcessing dot configuration files...\n"
for file in .bashrc .bash_profile .inputrc .gitconfig; do
    if [ -f "$DOTFILES_DIR/shell/$file" ]; then
        create_symlink "$DOTFILES_DIR/shell/$file" "$HOME_DEST/$file"
    fi
done

# Handle shell scripts
printf "\nProcessing shell scripts...\n"
for file in "$SHELL_DIR"/*; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        create_symlink "$file" "$HOME_DEST/$filename"
    fi
done

# Handle SSH configuration files
printf "\nProcessing SSH configuration files...\n"

if [ -d "$SSH_DIR" ]; then
    mkdir -p "$HOME_DEST/.ssh"
    attrib +h "$HOME_DEST/.ssh"
    for file in "$SSH_DIR"/*; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            create_symlink "$file" "$HOME_DEST/.ssh/$filename" false
        fi
    done
fi

# Python configuration files
printf "\nProcessing Python configuration files...\n"
if [ -d "$PYTHON_DIR" ]; then
    for file in "$PYTHON_DIR"/*; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            # Check if the file is pyproject.toml and handle it specially
            if [ "$filename" = "pyproject.toml" ]; then
                # Define the special directory for pyproject.toml
                special_dir="$HOME/AppData/Roaming/Ruff"
                mkdir -p "$special_dir" # Ensure the directory exists
                create_symlink "$file" "$special_dir/$filename"
            else
                # Handle all other Python configuration files normally
                create_symlink "$file" "$HOME_DEST/$filename"
            fi
        fi
    done
fi

# Handle vscode files
printf "\nProcessing VS Code configuration files...\n"

for file in "$VSCODE_DIR"/*; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        create_symlink "$file" "$CODE_USER_DIR/$filename" false
    fi
done

if ask "Do you want to update the system PATH and PYTHONPATH environment variables?"; then
    update_environment_variables
fi

printf "\nFinalizing installation...\n"

# Source shell scripts in .bashrc, excluding .vimrc and _vimrc files
BASHRC_SOURCE_HEADER='# -------------- Dotfiles install ---------------'
if ! grep -qxF "$BASHRC_SOURCE_HEADER" "$RC_FOR_SOURCE"; then
    echo "" >>"$RC_FOR_SOURCE"
    echo "$BASHRC_SOURCE_HEADER" >>"$RC_FOR_SOURCE"
fi

for file in "$DOTFILES_DIR/shell/"*; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        if [[ "$filename" != ".vimrc" && "$filename" != "_vimrc" ]]; then
            if ask "Do you want to source ${filename} in .bashrc?"; then
                # ShellCheck disable directive added for each source command
                echo "# shellcheck disable=SC1091" >>"$RC_FOR_SOURCE"
                SOURCE_CMD="source \"$file\""
                if ! grep -qxF "$SOURCE_CMD" "$RC_FOR_SOURCE"; then
                    echo "$SOURCE_CMD" >>"$RC_FOR_SOURCE"
                fi
            fi
        fi
    fi
done

echo '# -------------- End of Dotfiles install ---------------' >>"$RC_FOR_SOURCE"
echo
echo "Process complete."
echo "========================================"
