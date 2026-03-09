# Configure Nuget to use PSGallery repo
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

# Install PowerShell Modules
Install-Module -Name PSReadLine                                 # Command line editing experience of PowerShell
Install-Module -Name PSFzf                                      # PowerShell fzf module
