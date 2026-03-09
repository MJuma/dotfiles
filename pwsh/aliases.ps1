# Consolidated aliases — loaded once instead of per-file for faster startup

# ── Aggregates ───────────────────────────────────────────────────
function count   { BEGIN { $x = 0 } PROCESS { $x += 1 }  END { $x } }
function product { BEGIN { $x = 1 } PROCESS { $x *= $_ } END { $x } }
function sum     { BEGIN { $x = 0 } PROCESS { $x += $_ } END { $x } }
function average { BEGIN { $max = 0; $curr = 0 } PROCESS { $max += $_; $curr += 1 } END { $max / $curr } }

# ── Navigation ───────────────────────────────────────────────────
Set-Alias -Name ".." -Value "cd.."

function explorerHere { Start-Process -FilePath explorer.exe -ArgumentList . }
Set-Alias -Name "e." -Value "explorerHere"

# ── File search ──────────────────────────────────────────────────
function find {
    [CmdletBinding()] Param($name)
    Get-ChildItem . -Recurse | Where-Object Name -Like *$name* | Select-Object -ExpandProperty FullName
}

function fif([string]$search) {
    rg --no-messages -n $search | fzf --delimiter : --height=100% --preview 'bat --style=numbers --color=always --theme="Coldark-Dark" --highlight-line {2} {1}' --preview-window='60%:+{2}-/2:nohidden'
}

# ── Utilities ────────────────────────────────────────────────────
function guid { [guid]::NewGuid() }
function which($cmd) { (Get-Command $cmd).Definition }
function printenv { Get-ChildItem env:* | Sort-Object Name }

function Get-PubIP { (Invoke-WebRequest http://ifconfig.me/ip).Content }
Set-Alias -Name myAddr -Value Get-PubIP

function U {
    param([int]$Code)
    if ((0 -le $Code) -and ($Code -le 0xFFFF)) { return [char]$Code }
    if ((0x10000 -le $Code) -and ($Code -le 0x10FFFF)) { return [char]::ConvertFromUtf32($Code) }
    throw "Invalid character code $Code"
}

# ── Shortcuts ────────────────────────────────────────────────────
function dotfiles { code $HOME\dotfiles }
function hosts { code C:\Windows\System32\drivers\etc\hosts }

function listNpmGlobalModules { npm ls -g --depth=0 }
Set-Alias -Name "npmls" -Value "listNpmGlobalModules"
