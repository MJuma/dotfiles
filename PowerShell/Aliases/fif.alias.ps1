<#
.DESCRIPTION
    Recursive search for files and directories.
.EXAMPLE
    fif "psome text"
#>

function fif([string]$search) {
    rg --no-messages -n $search -T | fzf --delimiter : --height=100% --preview 'bat --style=numbers --color=always --highlight-line {2} {1}' --preview-window='+{2}-/2:nohidden'
}
