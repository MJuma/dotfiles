# Remove Windows Default Bloatware
.\RemoveDefaultApps.ps1

# Configure Privacy Settings For Windows
.\Privacy.ps1

# Configure Windows System Settings
.\System.ps1

# Configure Windows Optional Features
.\WindowsOptionalFeatures.ps1

## Install Software Using Chococlatey
.\Chococlatey.ps1

RefreshEnv
Update-SessionEnvironment

## Install VSCode Extensions
.\VSCode.ps1

# Install Powerline Fonts
git clone https://github.com/powerline/fonts.git C:\Workspace\Other\fonts
C:\Workspace\Other\fonts\install.ps1

# Configure PowerShellCore
pwsh.exe -File .\PowerShellCore.ps1

# Symbolic Link PowerShell dotfiles directory
New-Item $HOME\Documents\PowerShell -ItemType SymbolicLink -Value $HOME\dotfiles\PowerShell
