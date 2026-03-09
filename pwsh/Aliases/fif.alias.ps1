<#
.DESCRIPTION
    Recursive search for files and directories.
.EXAMPLE
    fif "psome text"
#>

function fif([string]$search) {
    rg --no-messages -n $search | fzf --delimiter : --height=100% --preview 'bat --style=numbers --color=always --theme="Coldark-Dark" --highlight-line {2} {1}' --preview-window='60%:+{2}-/2:nohidden'
}
