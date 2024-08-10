# Set environment variables
$env:POSH_THEMES_PATH = "$HOME\Desktop\stuff\000_dotfiles\oh_my_posh"
$env:HOME = "$HOME\Desktop\stuff\000_dotfiles"
# Initialize Oh-My-Posh theme
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\stelbent-compact.minimal.omp.json" | Invoke-Expression

# Directory stuff aliases
set-alias .. cd..
set-alias ... cd...
set-alias .... cd...

# Custom mkdir function that creates and enters a directory
function mkdir {
    param(
        [string]$path
    )
    New-Item -ItemType Directory -Path $path -Force
    Set-Location $path
}

# Git functions instead of aliases
function gs { git status }
function gd { git diff }
function gl { git log }
function gc { git checkout }
function gp { git push }
function gm { git merge }
function gpl { git pull }
function dotcommit { git add .; git commit -m '.' }

# Docker functions instead of aliases
function dk { docker }
function dcup { docker compose up }
function dcdown { docker compose down }

# Custom mcd function that creates and enters a directory
function mcd {
    param(
        [string]$path
    )
    New-Item -ItemType Directory -Path $path -Force
    Set-Location $path
}

# Set default directory when opening PowerShell
if ($PWD.Path -eq $HOME -or $PWD.Path -eq "C:\") {
    Set-Location "$HOME\Desktop\stuff"
}

# Custom cd function
function cd {
    param(
        [string]$path = "$HOME\Desktop\stuff"
    )
    Set-Location $path
}

# Custom ls function
function ls {
    param (
        [string[]]$args
    )
    Get-ChildItem @args | Format-Table -AutoSize
}

# ls aliases
Set-Alias ll ls
Set-Alias llr ls
Set-Alias llR ls
Set-Alias lsl ls

# grep, fgrep, egrep functions using Select-String
function grep {
    param (
        [string]$pattern,
        [string[]]$files
    )
    Select-String -Pattern $pattern -Path $files
}

function fgrep {
    param (
        [string]$pattern,
        [string[]]$files
    )
    Select-String -SimpleMatch -Pattern $pattern -Path $files
}

function egrep {
    param (
        [string]$pattern,
        [string[]]$files
    )
    Select-String -Pattern $pattern -Path $files
}
