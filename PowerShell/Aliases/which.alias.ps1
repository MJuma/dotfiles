<#
.DESCRIPTION
    Returns the definition for a command.
.EXAMPLE
    which ls
#>

function which($cmd) {
    (Get-Command $cmd).Definition
}
