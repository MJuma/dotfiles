<#
.DESCRIPTION
    Recursive search for files and directories.
.EXAMPLE
    find someFile.txt
#>

function find {
    [CmdletBinding()] Param($name);
    Get-ChildItem . -Recurse | Where-Object name -Like *$name* | Select-Object -ExpandProperty Fullname
}