$global:_ProfileStopwatch = [System.Diagnostics.Stopwatch]::StartNew()

# Put PowerShell in strict mode for type safety
Set-StrictMode -Version Latest

# PSFzf + PSReadLine predictions — deferred to first prompt
$global:_DeferredModulesLoaded = $false

# Native prompt (replaces oh-my-posh for faster startup)
. $PSScriptRoot\prompt.ps1

# PSReadLine predictive IntelliSense — deferred to first prompt with other modules

# Set environment variables
$FD_OPTIONS="--hidden --absolute-path --exclude .git --exclude node_modules"
$env:RIPGREP_CONFIG_PATH = "$HOME\dotfiles\config\.config\ripgreprc";
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
$env:BAT_PAGER = "less --RAW-CONTROL-CHARS --quit-if-one-screen";
$env:BAT_THEME = "Coldark-Dark";
$env:DELTA_PAGER = "less --RAW-CONTROL-CHARS --quit-if-one-screen";

# Aliases (consolidated into single file for fast load)
. $PSScriptRoot\aliases.ps1

# Zoxide integration (cached for speed — regenerate with: zoxide init powershell > ~/dotfiles/pwsh/zoxide.ps1)
$zoxideCache = "$PSScriptRoot\zoxide.ps1"
if (Test-Path $zoxideCache) {
    . $zoxideCache
} elseif (Get-Command zoxide -ErrorAction SilentlyContinue) {
    zoxide init powershell | Set-Content $zoxideCache
    . $zoxideCache
}

# Profile load time (only show if slow)
$global:_ProfileStopwatch.Stop()
if ($global:_ProfileStopwatch.ElapsedMilliseconds -ge 250) {
    Write-Host "Profile loaded in $($global:_ProfileStopwatch.ElapsedMilliseconds)ms" -ForegroundColor DarkGray
}
