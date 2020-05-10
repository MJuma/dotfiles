<#
.DESCRIPTION
    Returns the current logged in users domain and username.
.EXAMPLE
    whoami
#>

function whoami {
    [Environment]::UserDomainName + "\" + [Environment]::UserName
}