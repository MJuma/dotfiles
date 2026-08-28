#Requires -RunAsAdministrator

# Remove Windows Default Bloatware
& "$PSScriptRoot\RemoveDefaultApps.ps1"

# Configure Privacy Settings For Windows
& "$PSScriptRoot\Privacy.ps1"

# Configure Windows System Settings
& "$PSScriptRoot\System.ps1"

# Install Software Using WinGet
& "$PSScriptRoot\WinGet.ps1"

# Refresh environment variables
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

# Configure PowerShellCore
pwsh.exe -File "$PSScriptRoot\PowerShellCore.ps1"

# Clone dotfiles repo
$dotfilesPath = Join-Path $HOME 'dotfiles'
if (Test-Path -LiteralPath (Join-Path $dotfilesPath '.git')) {
    Write-Host "Dotfiles already cloned at $dotfilesPath; skipping clone." -ForegroundColor DarkGray
} elseif (Test-Path -LiteralPath $dotfilesPath) {
    Write-Warning "Cannot clone dotfiles because '$dotfilesPath' already exists and is not a Git repository."
} else {
    git clone https://github.com/MJuma/dotfiles.git $dotfilesPath
}

# Link dotfiles (profile, gitconfig, terminal settings, doskey)
& "$PSScriptRoot\..\..\setup.ps1"

# Install WSL
& "$PSScriptRoot\WSL.ps1"
