<#
.DESCRIPTION
    Returns a the current sessions environment variables
.EXAMPLE
    printenv
#>

function printenv {
    Get-ChildItem env:* | Sort-Object Name
}