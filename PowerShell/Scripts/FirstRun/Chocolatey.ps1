# Install Chocolatey
if (!(Test-Path -Path "$env:ProgramData\Chocolatey")) {
    Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

RefreshEnv
Update-SessionEnvironment

# Install Chocolatey packages
cinst 7zip.install `
    azure-cli `
    azurepowershell `
    chromium `
    curl `
    docker-desktop `
    dotnetcore-sdk `
    everything `
    fiddler `
    firefox `
    git.install --package-parameters="'/GitAndUnixToolsOnPath /WindowsTerminal'" `
    googlechrome `
    jetbrainstoolbox `
    jq `
    microsoft-teams `
    microsoft-windows-terminal `
    microsoftazurestorageexplorer `
    nodejs-lts `
    nuget.commandline `
    office365business `
    postman `
    powershell-core `
    powertoys `
    psscriptanalyzer `
    spotify `
    sumatrapdf `
    vlc `
    vscode `
    windirstat `
    winscp `
    yarn `
    -y