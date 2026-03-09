<#
.DESCRIPTION
    Install development tools and applications using WinGet
.EXAMPLE
    WinGet.ps1
#>

#Requires -RunAsAdministrator

# Install packages using WinGet
$packages = @(
    'junegunn.fzf'
    'Git.Git'
    'GitHub.GitLFS'
    'sharkdp.bat'
    'jqlang.jq'
    'Microsoft.PowerShell'
    'BurntSushi.ripgrep.MSVC'
    'sharkdp.fd'
    'dandavison.delta'
    'ajeetdsouza.zoxide'
    'Microsoft.VisualStudioCode'
)

foreach ($package in $packages) {
    Write-Host "Installing $package..." -ForegroundColor Cyan
    winget install --id $package --accept-source-agreements --accept-package-agreements --silent
}

# Install Hack Nerd Font (not available in WinGet)
Write-Host "Installing Hack Nerd Font..." -ForegroundColor Cyan
$fontZip = "$env:TEMP\Hack.zip"
$fontDir = "$env:TEMP\HackNerdFont"
Invoke-WebRequest -Uri "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip" -OutFile $fontZip
Expand-Archive -Path $fontZip -DestinationPath $fontDir -Force
$shellApp = New-Object -ComObject Shell.Application
$fontsFolder = $shellApp.Namespace(0x14)  # Windows Fonts folder
Get-ChildItem "$fontDir\*.ttf" | ForEach-Object { $fontsFolder.CopyHere($_.FullName, 0x10) }
Remove-Item $fontZip, $fontDir -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "`nAll packages installed!" -ForegroundColor Green
