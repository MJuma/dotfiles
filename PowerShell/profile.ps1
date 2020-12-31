# Display verbose messages during profile load
$DotFilesVerbose = $false

# Enable verbose profile load
if ($DotFilesVerbose) {
    # $VerbosePreference seems to have no value during profile load? Use
    # the default of SilentlyContinue when this appears to be the case.
    if ($VerbosePreference) {
        $VerbosePreferenceOriginal = $VerbosePreference
    } else {
        $VerbosePreferenceOriginal = 'SilentlyContinue'
    }

    $VerbosePreference = 'Continue'
}

# Put PowerShell in strict mode for type safety
Set-PSDebug -Strict

# Import PowerShell Modules
Import-Module Get-ChildItemColor
Import-Module 'posh-git'
Import-Module 'oh-my-posh'
Import-Module PSReadLine
Import-Module PSFzf

# Set PowerShell prompt theme
Set-Theme Custom

# Configure PSFzf bindings
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }
Set-PsFzfOption -TabExpansion

# Set environment variables
$FD_OPTIONS="--hidden --absolute-path --exclude .git --exclude node_modules"
$env:RIPGREP_CONFIG_PATH = "$env:HOME\dotfiles\config\.config\ripgreprc";
$env:FZF_TMUX_OPTS = "-r 40%";
$env:FZF_DEFAULT_OPTS = "--extended
--multi
--height=40%
--layout=reverse
--bind='ctrl-p:toggle-preview,ctrl-j:preview-down,ctrl-k:preview-up,ctrl-o:execute(code {1})'
--preview='bat --style=numbers --color=always {}'
--preview-window='right:hidden:wrap'
--border
--color=dark
--color=fg:-1,bg:-1,hl:#c678dd,fg+:#ffffff,bg+:#4b5263,hl+:#d858fe
--color=info:#98c379,prompt:#61afef,pointer:#be5046,marker:#e5c07b,spinner:#61afef,header:#61afef
";
$env:FZF_DEFAULT_COMMAND = " (rg --files --line-number --hidden --smart-case) || (fd --type f --type l $FD_OPTIONS)";
$env:FZF_CTRL_T_COMMAND = "fd $FD_OPTIONS";
$env:FZF_ALT_C_COMMAND = "fd --type d $FD_OPTIONS";
$env:BAT_PAGER = "less --RAW-CONTROL-CHARS --quit-if-one-screen --mouse";
$env:BAT_THEME = "OneHalfDark";

# Function for creating bash style aliases
function BashStyleAlias([string] $name, [string] $command) {
    $sb = [scriptblock]::Create($command)
    New-Item "Function:\global:$name" -Value $sb | Out-Null
}

# Import enabled aliases from $Home\Documents\PowerShell\Aliases\
Resolve-Path $PSScriptRoot\Aliases\*.ps1 |
    Where-Object { ($_.ProviderPath.Contains(".alias.")) } |
    Where-Object { -not ($_.ProviderPath.Contains(".disabled.")) } |
    Foreach-Object { . $_.ProviderPath }

Set-ExecutionPolicy Bypass -Scope Process -Force

# Restore original $VerbosePreference setting
if ($DotFilesVerbose) {
    $VerbosePreference = $VerbosePreferenceOriginal
    Remove-Variable -Name 'VerbosePreferenceOriginal'
}
