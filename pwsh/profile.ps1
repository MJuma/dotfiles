$global:_ProfileLoadStopwatch = [System.Diagnostics.Stopwatch]::StartNew()

# PSFzf + PSReadLine predictions are deferred to the first prompt.
$global:_DeferredModulesLoaded = $false

# Native prompt (replaces oh-my-posh for faster startup)
. $PSScriptRoot\prompt.ps1

# Set environment variables
& {
    param($ProfileRoot)

    $fdOptions = '--hidden --absolute-path --exclude .git --exclude node_modules'
    $dotfilesRoot = [System.IO.Directory]::GetParent($ProfileRoot).FullName
    $ripgrepConfig = [System.IO.Path]::Combine($dotfilesRoot, 'config', '.config', 'ripgreprc')
    if ([System.IO.File]::Exists($ripgrepConfig)) {
        $env:RIPGREP_CONFIG_PATH = $ripgrepConfig
    }
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
    $env:FZF_DEFAULT_COMMAND = "(rg --files --hidden --smart-case) || (fd --type f --type l $fdOptions)"
    $env:FZF_CTRL_T_COMMAND = "fd $fdOptions"
    $env:FZF_ALT_C_COMMAND = "fd --type d $fdOptions"
    $env:BAT_PAGER = 'less --RAW-CONTROL-CHARS --quit-if-one-screen'
    $env:BAT_THEME = 'Coldark-Dark'
    $env:DELTA_PAGER = 'less --RAW-CONTROL-CHARS --quit-if-one-screen'
} $PSScriptRoot

# Aliases (consolidated into single file for fast load)
. $PSScriptRoot\aliases.ps1

# Zoxide integration (cached for speed). The generated script still calls the
# executable on every directory change, so do not load it when zoxide is absent.
& {
    param($ProfileRoot)

    $hadZoxideHook = try { $global:__zoxide_hooked -eq 1 } catch { $false }
    $zoxidePath = $null
    $zoxideName = if ($env:OS -eq 'Windows_NT') { 'zoxide.exe' } else { 'zoxide' }
    foreach ($pathEntry in ($env:PATH -split [System.IO.Path]::PathSeparator)) {
        if ($pathEntry) {
            $candidate = [System.IO.Path]::Combine($pathEntry.Trim('"'), $zoxideName)
            if ([System.IO.File]::Exists($candidate)) {
                $zoxidePath = $candidate
                break
            }
        }
    }

    if ($zoxidePath) {
        $zoxideCache = [System.IO.Path]::Combine($ProfileRoot, 'zoxide.ps1')
        if (-not [System.IO.File]::Exists($zoxideCache)) {
            & $zoxidePath init powershell | Set-Content -LiteralPath $zoxideCache -Encoding UTF8
        }
        if ([System.IO.File]::Exists($zoxideCache)) {
            # Ensure reloading the profile wraps the newly defined prompt again.
            $global:__zoxide_hooked = 0
            . $zoxideCache
        }
    } else {
        # Remove stale aliases when reloading after zoxide has been uninstalled.
        if ($hadZoxideHook) {
            foreach ($aliasName in 'z', 'zi') {
                if (Test-Path "Alias:$aliasName") {
                    $alias = Get-Item "Alias:$aliasName"
                    if ($alias.Definition -like '__zoxide_*') {
                        Remove-Item "Alias:$aliasName" -Force
                    }
                }
            }
        }
        $global:__zoxide_hooked = 0
    }
} $PSScriptRoot

# Profile load time (only show if slow)
$global:_ProfileLoadStopwatch.Stop()
if ($global:_ProfileLoadStopwatch.ElapsedMilliseconds -ge 250) {
    Write-Host "Profile loaded in $($global:_ProfileLoadStopwatch.ElapsedMilliseconds)ms" -ForegroundColor DarkGray
}
$global:_ProfileLoadStopwatch = $null
