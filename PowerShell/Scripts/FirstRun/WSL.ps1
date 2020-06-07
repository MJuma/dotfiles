Invoke-Expression "wsl --set-default-version 2"

Invoke-WebRequest -Uri https://aka.ms/wsl-debian-gnulinux -OutFile ~/Downlowds/Debian.appx -UseBasicParsing
Add-AppxPackage -Path ~/Downlowds/Debian.appx
Remove-Item ~/Downlowds/Debian.appx

RefreshEnv
Debian install --root
Debian run apt update
Debian run apt upgrade -y
