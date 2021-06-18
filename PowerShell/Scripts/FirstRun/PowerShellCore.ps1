# Configure Nuget to use PSGallery repo
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

# Install PowerShell Modules
Install-Module -Name 'oh-my-posh'                               # Themes for PowerShell prompt v3
# Install-Module -Name 'oh-my-posh' -RequiredVersion 2.0.496    # Themes for PowerShell prompt v2
Install-Module -Name PSReadLine                                 # Command line editing experience of PowerShell
Install-Module -Name PSScriptAnalyzer                           # Linter for PowerShell scripts
Install-Module -Name Get-ChildItemColor -AllowClobber           # Colorize directory listings
Install-Module -Name PSFzf                                      # PowerShell fzf moduel
