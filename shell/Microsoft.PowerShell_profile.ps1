# Set environment variables
$env:POSH_THEMES_PATH = "$HOME\Desktop\stuff\000_dotfiles\oh_my_posh"
$env:HOME = "$HOME\Desktop\stuff\000_dotfiles"

# Initialize Oh-My-Posh theme
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\stelbent-compact.minimal.omp.json" | Invoke-Expression


# Direct aliases
Set-Alias .. cd..
Set-Alias ... cd...
Set-Alias .... cd...
Set-Alias gth GoToHome

# Compute file hashes - useful for checking successful downloads
function md5    { Get-FileHash -Algorithm MD5 $args }
function sha1   { Get-FileHash -Algorithm SHA1 $args }
function sha256 { Get-FileHash -Algorithm SHA256 $args }


# Git functions
function gs { git status }
function gd { git diff }
function push { git push }
function gl { git log }
function gm { git merge }
function gp { git pull }
function dotcommit { git add .; git commit }

function commit {
    param (
        [string]$message = "Default commit message"
    )
    git commit -m $message
}


# Custom mkdir function that creates and enters a directory
function mkdir {
    param(
        [string]$path
    )
    New-Item -ItemType Directory -Path $path -Force
    Set-Location $path
}

# Go to Home directory function
function GoToHome {
    Set-Location -Path "$HOME\Desktop\Stuff"
}


# List all files recursively, similar to `dir /s /b`
function dirs {
    if ($args.Count -gt 0) {
        Get-ChildItem -Recurse -Include "$args" | ForEach-Object FullName
    } else {
        Get-ChildItem -Recurse | ForEach-Object FullName
    }
}


# Start a new elevated process or PowerShell instance
function admin {
    if ($args.Count -gt 0) {
       $argList = "& '" + $args + "'"
       Start-Process "$psHome\powershell.exe" -Verb runAs -ArgumentList $argList
    } else {
       Start-Process "$psHome\powershell.exe" -Verb runAs
    }
}

# Set UNIX-like aliases for the admin command, so sudo <command> will run the command with elevated rights
Set-Alias -Name su -Value admin
Set-Alias -Name sudo -Value admin


# Drive shortcuts
function HKLM  { Set-Location HKLM: }
function HKCU  { Set-Location HKCU: }
function Env:  { Set-Location Env: }

# Creates drive shortcut for main Folder, if current user account is using it
if (Test-Path "$env:USERPROFILE\Desktop\Stuff") {
    New-PSDrive -Name Stuff -PSProvider FileSystem -Root "$env:USERPROFILE\Desktop\Stuff" -Description "Stuff"
    function Stuff: { Set-Location Stuff: }
}

# Creates drive shortcut for OneDrive, if current user account is using it
if (Test-Path HKCU:\SOFTWARE\Microsoft\OneDrive) {
    $onedrive = Get-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\OneDrive
    if (Test-Path $onedrive.UserFolder) {
        New-PSDrive -Name OneDrive -PSProvider FileSystem -Root $onedrive.UserFolder -Description "OneDrive"
        function OneDrive: { Set-Location OneDrive: }
    }
    Remove-Variable onedrive
}

# Function to edit Neovim configuration file
function Edit-Nvim {
    nvim "$HOME\AppData\Local\nvim\init.vim"
}

# Make it easy to edit this profile
function Edit-Profile {
    if ($host.Name -match "ise") {
        $psISE.CurrentPowerShellTab.Files.Add($PROFILE)
    } else {
        nvim $PROFILE
    }
}

# Get alias options
function Get-AliasOptions {
    Get-Alias | Format-Table Name,Definition,Options
}

Set-Alias aliases Get-AliasOptions

# Function to delete multiple directories
function rmdir-multi {
    param(
        [string[]]$dirs
    )

    foreach ($dir in $dirs) {
        $fullPath = (Resolve-Path $dir).Path
        if (Test-Path $fullPath) {
            rmdir $fullPath -Recurse -Force
            Write-Output "Deleted: $fullPath"
        } else {
            Write-Output "Directory not found: $fullPath"
        }
    }
}

# Alias for the function
Set-Alias rm-rf rmdir-multi
