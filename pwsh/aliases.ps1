# Consolidated aliases loaded once instead of per-file for faster startup.

# Aggregates
function count   { BEGIN { $x = 0 } PROCESS { $x += 1 }  END { $x } }
function product { BEGIN { $x = 1 } PROCESS { $x *= $_ } END { $x } }
function sum     { BEGIN { $x = 0 } PROCESS { $x += $_ } END { $x } }
function average { BEGIN { $total = 0; $count = 0 } PROCESS { $total += $_; $count += 1 } END { if ($count) { $total / $count } } }

# Navigation
function .. { Set-Location .. }

function explorerHere { Start-Process -FilePath explorer.exe -ArgumentList . }
function e. { explorerHere }

# File search
function find {
    [CmdletBinding()] Param($name)
    Get-ChildItem . -Recurse | Where-Object Name -Like *$name* | Select-Object -ExpandProperty FullName
}

function fif([string]$search) {
    rg --no-messages -n $search | fzf --delimiter : --height=100% --preview 'bat --style=numbers --color=always --theme="Coldark-Dark" --highlight-line {2} {1}' --preview-window='60%:+{2}-/2:nohidden'
}

# Utilities
function guid { [guid]::NewGuid() }
function which($cmd) { (Get-Command $cmd).Definition }
function printenv { Get-ChildItem env:* | Sort-Object Name }

function Get-PubIP { (Invoke-WebRequest https://ifconfig.me/ip).Content }
function myAddr { Get-PubIP }

function U {
    param([int]$Code)
    if ((0 -le $Code) -and ($Code -le 0xFFFF)) { return [char]$Code }
    if ((0x10000 -le $Code) -and ($Code -le 0x10FFFF)) { return [char]::ConvertFromUtf32($Code) }
    throw "Invalid character code $Code"
}

# Shortcuts
function dotfiles { code $HOME\dotfiles }
function hosts { code C:\Windows\System32\drivers\etc\hosts }

function listNpmGlobalModules { npm ls -g --depth=0 }
function npmls { listNpmGlobalModules }
