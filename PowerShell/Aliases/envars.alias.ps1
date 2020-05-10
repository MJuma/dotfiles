<#
.DESCRIPTION
    Returns a the current sessions environment variables
.EXAMPLE
    envars
#>

function envars {
    Get-ChildItem env:* | Sort-Object Name
}