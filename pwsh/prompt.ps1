# Native PowerShell prompt — no external dependencies
# Replaces oh-my-posh with a fast, two-line powerline prompt

# Track the last history entry we displayed timing for,
# so we don't re-show it when the user presses Enter on an empty line.
$global:_PromptLastHistoryId = -1

function prompt {
    # ── Capture last-command result immediately ──────────────────
    # $? reflects whether the user's last command succeeded.
    # Must be the very first statement — any expression resets it.
    $lastSuccess = $?

    # ── Deferred module loading (first prompt only) ─────────────
    if (-not $global:_DeferredModulesLoaded) {
        $global:_DeferredModulesLoaded = $true
        Import-Module PSFzf -ErrorAction SilentlyContinue
        Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
        Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }
        Set-PsFzfOption -TabExpansion
        Set-PSReadLineOption -PredictionSource HistoryAndPlugin
        Set-PSReadLineOption -PredictionViewStyle ListView
    }

    $e = [char]27
    $reset = "$e[0m"

    # Powerline / Nerd Font glyphs
    $sep      = [char]0xE0B0  # 
    $gitIcon  = [char]0xE0A0  # 
    $clockIcon = [char]0xF017  # 

    # ── Segment 1: Path ──────────────────────────────────────────
    $cwd = $PWD.Path
    if ($cwd.StartsWith($HOME, [StringComparison]::OrdinalIgnoreCase)) {
        $cwd = '~' + $cwd.Substring($HOME.Length)
    }
    $cwd = $cwd.Replace('\', '/')

    # ── Segment 2: Git branch + status ───────────────────────────
    # Only call git when inside a work tree (fast — purely local).
    $gitText = $null
    $branch = git rev-parse --abbrev-ref HEAD 2>$null
    if ($branch) {
        $dirty  = [bool](git status --porcelain 2>$null)
        $marker = if ($dirty) { ' ±' } else { ' ✓' }
        $gitText = " $gitIcon $branch$marker "
    }

    # ── Segment 3: Execution time ────────────────────────────────
    $timeText = $null
    $last = Get-History -Count 1
    if ($last -and $last.Id -ne $global:_PromptLastHistoryId) {
        $global:_PromptLastHistoryId = $last.Id
        $ms = ($last.EndExecutionTime - $last.StartExecutionTime).TotalMilliseconds
        if ($ms -ge 500) {
            $formatted = if ($ms -ge 60000) {
                '{0:F1}m' -f ($ms / 60000)
            } elseif ($ms -ge 1000) {
                '{0:F1}s' -f ($ms / 1000)
            } else {
                '{0:F0}ms' -f $ms
            }
            $timeText = " $clockIcon $formatted "
        }
    }

    # ── Assemble line 1 ──────────────────────────────────────────
    #  path  branch ±  1.2s 
    # Colors: path = white on blue, git = black on green, time = white on red

    $line = "$e[97;44m $cwd "                       # path segment

    if ($gitText) {
        $line += "$e[34;42m$sep"                     # blue → green transition
        $line += "$e[30;42m$gitText"                 # git segment
        if ($timeText) {
            $line += "$e[32;41m$sep"                 # green → red transition
            $line += "$e[97;41m$timeText"            # time segment
            $line += "$e[0;31m$sep"                  # red → default transition
        } else {
            $line += "$e[0;32m$sep"                  # green → default transition
        }
    } elseif ($timeText) {
        $line += "$e[34;41m$sep"                     # blue → red transition
        $line += "$e[97;41m$timeText"                # time segment
        $line += "$e[0;31m$sep"                      # red → default transition
    } else {
        $line += "$e[0;34m$sep"                      # blue → default transition
    }

    $line += $reset

    # ── Line 2: prompt indicator ─────────────────────────────────
    $promptColor = if ($lastSuccess) { '34' } else { '31' }  # blue or red
    $indicator = "$e[${promptColor}m❯$reset "

    # ── Window title ─────────────────────────────────────────────
    $host.UI.RawUI.WindowTitle = $cwd

    return "$line`n$indicator"
}
