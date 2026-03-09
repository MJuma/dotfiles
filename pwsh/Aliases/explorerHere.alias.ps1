<#
.DESCRIPTION
    Launches an explorer window in the current directory.
.EXAMPLE
    e.
#>

function explorerHere() {
    Start-Process -FilePath explorer.exe -argumentlist .
}

Set-Alias -name "e." -value "explorerHere"