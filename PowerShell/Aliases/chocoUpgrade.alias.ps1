<#
.DESCRIPTION
    Upgrades all installed Chocolatey packages.
.EXAMPLE
    upgrade
#>

function chocoUpgrade() {
    choco upgrade all -y
}

Set-Alias -name "upgrade" -value "chocoUpgrade"