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
git clone https://github.com/MJuma/dotfiles.git $HOME\dotfiles

# Link dotfiles (profile, gitconfig, terminal settings, doskey)
& "$PSScriptRoot\..\..\setup.ps1"

# Install WSL
& "$PSScriptRoot\WSL.ps1"
