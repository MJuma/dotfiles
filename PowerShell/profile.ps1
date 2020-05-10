# Display verbose messages during profile load
$DotFilesVerbose = $false

# Enable verbose profile load
if ($DotFilesVerbose) {
    # $VerbosePreference seems to have no value during profile load? Use
    # the default of SilentlyContinue when this appears to be the case.
    if ($VerbosePreference) {
        $VerbosePreferenceOriginal = $VerbosePreference
    } else {
        $VerbosePreferenceOriginal = 'SilentlyContinue'
    }

    $VerbosePreference = 'Continue'
}

# Put PowerShell in strict mode for type safety
Set-PSDebug -Strict

# Import PowerShell Modules
Import-Module Get-ChildItemColor
Import-Module 'posh-git'
Import-Module 'oh-my-posh'

# Set PowerShell prompt theme
Set-Theme Custom

# Function for creating bash style aliases
function BashStyleAlias([string] $name, [string] $command) {
    $sb = [scriptblock]::Create($command)
    New-Item "Function:\global:$name" -Value $sb | Out-Null
}

# Import enabled aliases from $Home\Documents\PowerShell\Aliases\
Resolve-Path $PSScriptRoot\Aliases\*.ps1 |
    Where-Object { ($_.ProviderPath.Contains(".alias.")) } |
    Where-Object { -not ($_.ProviderPath.Contains(".disabled.")) } |
    Foreach-Object { . $_.ProviderPath }

Set-ExecutionPolicy Bypass -Scope Process -Force

# Restore original $VerbosePreference setting
if ($DotFilesVerbose) {
    $VerbosePreference = $VerbosePreferenceOriginal
    Remove-Variable -Name 'VerbosePreferenceOriginal'
}
