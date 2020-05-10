<#
.DESCRIPTION
    Runs PSScriptAnalyzer over the ~/Documents/Powershell directory
.EXAMPLE
    lintDotfiles
#>

function lintDotfiles() {
    Invoke-ScriptAnalyzer -Path $HOME\Documents\Powershell\profile.ps1 -Settings $HOME\Documents\Powershell\PSScriptAnalyzerSettings.psd1
    Invoke-ScriptAnalyzer -Path $HOME\Documents\Powershell\Aliases -Settings $HOME\Documents\Powershell\PSScriptAnalyzerSettings.psd1 -Recurse
    Invoke-ScriptAnalyzer -Path $HOME\Documents\Powershell\PoshThemes -Settings $HOME\Documents\Powershell\PSScriptAnalyzerSettings.psd1 -Recurse
    Invoke-ScriptAnalyzer -Path $HOME\Documents\Powershell\Scripts -Settings $HOME\Documents\Powershell\PSScriptAnalyzerSettings.psd1 -Recurse
}
