<#
.DESCRIPTION
    Changes the directory based on the given alias.
.EXAMPLE
    g w # Changes the directory to C:\Workspace
#>

$configPath = $PSScriptRoot + "\goToFolder.config"
$folderList = Import-Csv($configPath)

function Set-TargetFolder() {
    [CmdletBinding(SupportsShouldProcess = $true)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'folderAlias')]
    Param($folderAlias)

    if ($PSCmdlet.ShouldProcess("Target", "Operation")) {
        $targetFolder = $folderList | Where-Object { $_.alias -eq $folderAlias }
        Set-Location $targetFolder.folder
    }
}

Set-Alias -Name g -Value Set-TargetFolder