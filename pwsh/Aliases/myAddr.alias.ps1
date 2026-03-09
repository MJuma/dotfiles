<#
.DESCRIPTION
    Returns the machines public IP address.
.EXAMPLE
    myAddr
#>

function Get-PubIP {
    (Invoke-WebRequest http://ifconfig.me/ip ).Content
}

Set-Alias -Name myAddr -Value Get-PubIP