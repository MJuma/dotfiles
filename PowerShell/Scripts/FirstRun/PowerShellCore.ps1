# Configure Nuget to use PSGallery repo
Install-PackageProvider NuGet -MinimumVersion '2.8.5.201' -Force
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

# Install PowerShell Modules
Install-Module -Name 'posh-git' # Git info in PowerShell prompt
Install-Module -Name 'oh-my-posh' # Themes for PowerShell prompt
Install-Module -Name PSScriptAnalyzer # Linter for PowerShell scripts
Install-Module -Name Get-ChildItemColor -AllowClobber # Colorize directory listings