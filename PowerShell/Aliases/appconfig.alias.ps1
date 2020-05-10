<#
.DESCRIPTION
    Opens the ~/Documents/IISExpress/config/applicationhost.config file in VS Code
.EXAMPLE
    appconfig
#>

function appconfig {
    code $HOME\Documents\IISExpress\config\applicationhost.config
}