## Check for root

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
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

## Install VSCode Extensions
.\VSCode.ps1

# Install Powerline Fonts
git clone https://github.com/powerline/fonts.git C:\Workspace\Other\fonts
C:\Workspace\Other\fonts\install.ps1

# Configure PowerShellCore
pwsh.exe -File .\PowerShellCore.ps1

# Symbolic Link PowerShell dotfiles directory
New-Item $HOME\Documents\PowerShell -ItemType SymbolicLink -Value $HOME\dotfiles\PowerShell

# Configure Command Prompt
# PROMPT = $E[1;37;44m $T$H$H$H $E[0;34;42m$E[0;30;42m $P $E[0;32;40m$_$E[1;30;40m$+$E[0;34;40m❯ $E[1;37;40m
REG ADD "HKCU\Software\Microsoft\Command Processor" /v Autorun /t REG_EXPAND_SZ /d "%UserProfile%\dotfiles\PowerShell\doskey.cmd" /f
