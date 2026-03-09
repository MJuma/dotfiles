:: http://technet.microsoft.com/en-us/library/bb490894.aspx
:: F7     = history
:: Alt+F7 = history -c
:: F8     = Ctrl+R
@echo off

:: Linux commands
doskey alias   = doskey $*
doskey cat     = type $*
doskey clear   = cls
doskey cp      = copy $*
doskey cpr     = xcopy $*
doskey grep    = find $*
doskey history = doskey /history
doskey kill    = taskkill /PID $*
doskey ls      = dir /D $*
doskey lsl     = dir $*
doskey man     = help $*
doskey mv      = move $*
doskey ps      = tasklist $*
doskey pwd     = echo %cd%
doskey rm      = del $*
doskey rmr     = deltree $*
doskey sudo    = runas /user:administrator $*
doskey ip      = ipconfig $*
doskey cd      = %SYSTEMDRIVE%%HOMEPATH%\Documents\Powershell\cd.bat $*

:: Easier navigation
doskey ~     = cd %HOMEPATH%
doskey ..    = cd ..\$*
doskey ...   = cd ..\..\$*
doskey ....  = cd ..\..\..\$*
doskey ..... = cd ..\..\..\..\$*

:: Edit common files & directories
doskey appconfig    = code %SYSTEMDRIVE%%HOMEPATH%\Documents\IISExpress\config\applicationhost.config
doskey dotfiles     = code %SYSTEMDRIVE%%HOMEPATH%\Documents\Powershell
doskey hosts        = code %WINDIR%\System32\drivers\etc\hosts
