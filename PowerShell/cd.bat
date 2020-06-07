@echo off

:: Change to home directory if no args passed
if '%*' == '' (
    chdir /D "%USERPROFILE%"
    exit /b 0
)

if '%*' == '-' (
    if defined OLDPWD (
        cd /d %OLDPWD%
        set OLDPWD=%cd%
        exit /b 0
    )
    set OLDPWD=%cd%
) else (
    if NOT errorlevel 1 set OLDPWD=%cd%
)

set dirname=""
set dirname=%*
set orig_dirname=%*

:: Remove quotes - will re-attach later.
set dirname=%dirname:\"=%
set dirname=%dirname:/"=%
set dirname=%dirname:"=%

:: Restore dirnames that contained only "/"
if "%dirname%" == "" set dirname=%orig_dirname:"=%

:: Strip trailing slash, if longer than 3
if defined dirname if NOT "%dirname:~3%" == ""  (
    if "%dirname:~-1%" == "\" set dirname="%dirname:~0,-1%"
    if "%dirname:~-1%" == "/" set dirname="%dirname:~0,-1%"
)

set dirname=%dirname:"=%

:: If starts with ~, then replace ~ with userprofile path
if %dirname:~0,1% == ~ (
    set dirname="%USERPROFILE%%dirname:~1%"
)
set dirname=%dirname:"=%

:: Replace forward-slashes with back-slashes
set dirname="%dirname:/=\%"
set dirname=%dirname:"=%

chdir /D "%dirname%"
