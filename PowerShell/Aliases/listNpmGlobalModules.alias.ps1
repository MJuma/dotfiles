<#
.DESCRIPTION
    Lists all the globally installed npm modules.
.EXAMPLE
    npmls
#>

function listNpmGlobalModules() {
    npm ls -g --depth=0
}

Set-Alias -name "npmls" -value "listNpmGlobalModules"