# Install Chocolatey
if (!(Test-Path -Path "$env:ProgramData\Chocolatey")) {
    Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

RefreshEnv

# Install Chocolatey packages
cinst 7zip.install `
    azure-cli `
    azure-data-studio `
    azurepowershell `
    bat `
    chromium `
    curl `
    delta `
    docker-desktop `
    dotnetcore-sdk `
    fiddler `
    firefox `
    fzf `
    git.install --package-parameters="'/GitAndUnixToolsOnPath /WindowsTerminal'" `
    git-lfs.install `
    googlechrome `
    jetbrainstoolbox `
    jq `
    imagemagick `
    microsoft-teams `
    microsoft-windows-terminal `
    microsoftazurestorageexplorer `
    nodejs-lts `
    nuget.commandline `
    office365business `
    oh-my-posh `
    pandoc `
    postman `
    powershell-core `
    powertoys `
    psscriptanalyzer `
    ripgrep `
    spotify `
    sumatrapdf `
    visualstudio2019enterprise `
    vlc `
    vscode `
    windirstat `
    winscp `
    yarn `
    -y
