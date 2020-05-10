<#
.DESCRIPTION
    Lists all installed Chocolatey package.
.EXAMPLE
    chocolist
#>

function chocoListLocal() {
    choco list --local-only
}

Set-Alias -name "chocolist" -value "chocoListLocal"