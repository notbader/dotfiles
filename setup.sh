#!/bin/bash

echo
echo "========================================"
echo "Starting Dotfiles Configuration Script"
echo "========================================"

# Get the absolute path to the directory containing this script
DOTFILES_DIR=$(pwd)
SHELL_DIR="$DOTFILES_DIR/shell"
VSCODE_DIR="$DOTFILES_DIR/vscode"
BASH_PROFILE="$HOME/.bash_profile"
VIMRC_FILE="$SHELL_DIR/_vimrc"
CODE_USER_DIR="$HOME/AppData/Roaming/Code/User"
MINTTY_CONFIG="$HOME/.minttyrc"
RC_FOR_SOURCE="$SHELL_DIR/.bashrc"

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

# Create .bash_profile in $HOME that sources .bashrc in $SHELL_DIR
printf "\nCreating .bash_profile in %s...\n" "$HOME"
if [ -f "$BASH_PROFILE" ]; then
    printf "\nbash_profile already exists.\n"
else
    {
        echo "#!/bin/bash"
        echo "# shellcheck disable=SC1091"
        echo "if [ -f \"$SHELL_DIR/.bashrc\" ]; then"
        echo "    source \"$SHELL_DIR/.bashrc\""
        echo "fi"
    } >"$BASH_PROFILE"
    attrib +h "$BASH_PROFILE"
    printf "\nbash_profile created and configured\n"
fi

# Copy vimrc
printf "\nCopying _vimrc to %s...\n" "$HOME"

if [ -f "$HOME" ]; then
    echo "_vimrc already exists in $HOME."
    if ask "Do you want to overwrite the existing _vimrc?"; then
        cp "$VIMRC_FILE" "$HOME"
        printf "\n%s has been updated in %s.\n" "_vimrc" "$HOME"
    else
        printf "\nNo changes made to the existing _vimrc.\n"
    fi
else
    cp "$VIMRC_FILE" "$HOME"
    attrib +h "$HOME/_vimrc"
    printf "\n%s has been copied to %s.\n" "_vimrc" "$HOME"
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
                echo "File $filename has been updated in the destination."
            else
                echo "No changes made to the existing file at the destination."
            fi
        else
            if ask "Do you want to copy $filename to the destination?"; then
                cp "$file" "$CODE_USER_DIR/$filename"
                echo "File $filename has been copied to the destination."
            fi
        fi
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
                SOURCE_CMD="source \"$file\""
                if ! grep -qxF "$SOURCE_CMD" "$RC_FOR_SOURCE"; then
                    echo "$SOURCE_CMD" >>"$RC_FOR_SOURCE"
                fi
            fi
        fi
    fi
done

# Set GitBash theme to Dracula
if ask "Do you want to set the Dracula theme for Git Bash?"; then
    echo "ThemeFile=dracula" >"$MINTTY_CONFIG"
    echo "Dracula theme set for Git Bash."
fi

echo '# -------------- End of Dotfiles install ---------------' >>"$RC_FOR_SOURCE"
echo
echo "Process complete."
echo "========================================"
