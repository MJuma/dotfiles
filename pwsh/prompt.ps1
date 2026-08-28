# Native PowerShell prompt with no required external dependencies.
# Replaces oh-my-posh with a fast, two-line powerline prompt

# Track the last history entry we displayed timing for,
# so we don't re-show it when the user presses Enter on an empty line.
$global:_PromptLastHistoryId = -1
$global:_PromptLastCommandSucceededOverride = $null
$global:_PromptLastWindowTitle = $null
$global:_PromptGitExecutable = $null
$global:_PromptFzfExecutable = $null
& {
    $previousGitStatusTask = try { $global:_PromptGitStatusTask } catch { $null }
    if ($previousGitStatusTask) {
        try {
            if (-not $previousGitStatusTask.Process.HasExited) {
                $previousGitStatusTask.Process.Kill()
            }
        } catch {}
        try { $previousGitStatusTask.Process.Dispose() } catch {}
    }
}
$global:_PromptGitStatusTask = $null
$global:_PromptGitStatusCache = $null

& {
    $gitExecutableName = if ($env:OS -eq 'Windows_NT') { 'git.exe' } else { 'git' }
    $fzfExecutableName = if ($env:OS -eq 'Windows_NT') { 'fzf.exe' } else { 'fzf' }
    foreach ($pathEntry in ($env:PATH -split [System.IO.Path]::PathSeparator)) {
        if ($pathEntry) {
            $pathEntry = $pathEntry.Trim('"')
            if (-not $global:_PromptGitExecutable) {
                $candidate = [System.IO.Path]::Combine($pathEntry, $gitExecutableName)
                if ([System.IO.File]::Exists($candidate)) {
                    $global:_PromptGitExecutable = $candidate
                }
            }
            if (-not $global:_PromptFzfExecutable) {
                $candidate = [System.IO.Path]::Combine($pathEntry, $fzfExecutableName)
                if ([System.IO.File]::Exists($candidate)) {
                    $global:_PromptFzfExecutable = $candidate
                }
            }
            if ($global:_PromptGitExecutable -and $global:_PromptFzfExecutable) { break }
        }
    }
}

function ConvertFrom-ProfileGitStatus {
    param(
        [string]$StatusOutput,
        [string]$RepositoryRoot,
        [DateTime]$CheckedAt
    )

    $status = [PSCustomObject]@{
        RepositoryRoot = $RepositoryRoot
        CheckedAt = $CheckedAt
        Upstream = $null
        Ahead = 0
        Behind = 0
        Staged = 0
        Unstaged = 0
        Untracked = 0
        Conflicted = 0
        Stash = 0
    }

    foreach ($line in @($StatusOutput -split "`r?`n" | Where-Object { $_ })) {
        if ($line -match '^# branch\.upstream (.+)$') {
            $status.Upstream = $Matches[1]
        } elseif ($line -match '^# branch\.ab \+(\d+) -(\d+)$') {
            $status.Ahead = [int]$Matches[1]
            $status.Behind = [int]$Matches[2]
        } elseif ($line -match '^# stash (\d+)$') {
            $status.Stash = [int]$Matches[1]
        } elseif ($line.StartsWith('1 ') -or $line.StartsWith('2 ')) {
            $indexAndWorkTree = $line.Substring(2, 2)
            if ($indexAndWorkTree[0] -ne '.') { $status.Staged++ }
            if ($indexAndWorkTree[1] -ne '.') { $status.Unstaged++ }
        } elseif ($line.StartsWith('u ')) {
            $status.Conflicted++
        } elseif ($line.StartsWith('? ')) {
            $status.Untracked++
        }
    }

    return $status
}

function prompt {
    # Capture last-command result immediately.
    # $? reflects whether the user's last command succeeded.
    # Must be the very first statement; any expression resets it.
    $lastSuccess = $?
    if ($null -ne $global:_PromptLastCommandSucceededOverride) {
        $lastSuccess = $global:_PromptLastCommandSucceededOverride
        $global:_PromptLastCommandSucceededOverride = $null
    }

    # Deferred module loading (first prompt only).
    if (-not $global:_DeferredModulesLoaded) {
        $global:_DeferredModulesLoaded = $true

        # PSFzf can be installed even when its required fzf executable is not.
        # Keep optional fuzzy-search setup from preventing the prompt from rendering.
        if ($global:_PromptFzfExecutable) {
            try {
                Import-Module PSFzf -Global -ErrorAction Stop
                Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
                Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }
                Set-PsFzfOption -TabExpansion
            } catch {}
        }

        # Windows PowerShell can have an older PSReadLine without prediction options.
        $psReadLineOption = if (Get-Module PSReadLine) {
            Get-Command Set-PSReadLineOption -Module PSReadLine -ErrorAction SilentlyContinue
        }
        if ($psReadLineOption -and $psReadLineOption.Parameters.ContainsKey('PredictionSource')) {
            Set-PSReadLineOption -PredictionSource HistoryAndPlugin -ErrorAction SilentlyContinue
        }
        if ($psReadLineOption -and $psReadLineOption.Parameters.ContainsKey('PredictionViewStyle')) {
            Set-PSReadLineOption -PredictionViewStyle ListView -ErrorAction SilentlyContinue
        }
    }

    $e = [char]27
    $reset = "$e[0m"

    # Powerline / Nerd Font glyphs
    $sep = [char]0xE0B0
    $gitIcon = [char]0xE0A0
    $clockIcon = [char]0xF017

    # Segment 1: path.
    $cwd = $PWD.Path
    if ($cwd.StartsWith($HOME, [StringComparison]::OrdinalIgnoreCase)) {
        $cwd = '~' + $cwd.Substring($HOME.Length)
    }
    $cwd = $cwd.Replace('\', '/')

    # Segment 2: Git branch and status.
    # Find .git with filesystem checks so non-repository prompts do not pay
    # the high cost of starting git.exe. Dirty-state refreshes run in the
    # background and are harvested by the next prompt.
    $gitText = $null
    $now = [DateTime]::UtcNow
    $gitStatusTask = $global:_PromptGitStatusTask
    if ($gitStatusTask) {
        if ($gitStatusTask.Process.HasExited -and $gitStatusTask.Output.IsCompleted -and $gitStatusTask.Error.IsCompleted) {
            try {
                $statusOutput = [string]$gitStatusTask.Output.Result
                if ($gitStatusTask.Process.ExitCode -eq 0) {
                    $global:_PromptGitStatusCache = ConvertFrom-ProfileGitStatus $statusOutput $gitStatusTask.RepositoryRoot $now
                }
            } catch {
            } finally {
                try { $gitStatusTask.Process.Dispose() } catch {}
                $global:_PromptGitStatusTask = $null
            }
        } elseif (($now - $gitStatusTask.StartedAt).TotalSeconds -ge 10) {
            try { $gitStatusTask.Process.Kill() } catch {}
            try { $gitStatusTask.Process.Dispose() } catch {}
            $global:_PromptGitStatusTask = $null
        }
    }

    if ($PWD.Provider.Name -eq 'FileSystem') {
        $directory = [System.IO.DirectoryInfo]$PWD.ProviderPath
        $repositoryRoot = $null
        $gitDirectory = $null
        while ($directory) {
            $gitMetadata = Join-Path $directory.FullName '.git'
            if ([System.IO.Directory]::Exists($gitMetadata)) {
                $repositoryRoot = $directory.FullName
                $gitDirectory = $gitMetadata
                break
            }
            if ([System.IO.File]::Exists($gitMetadata)) {
                $gitDirectoryLine = [System.IO.File]::ReadAllText($gitMetadata).Trim()
                if ($gitDirectoryLine.StartsWith('gitdir: ')) {
                    $gitDirectory = $gitDirectoryLine.Substring('gitdir: '.Length)
                    if (-not [System.IO.Path]::IsPathRooted($gitDirectory)) {
                        $gitDirectory = [System.IO.Path]::GetFullPath((Join-Path $directory.FullName $gitDirectory))
                    }
                }
                $repositoryRoot = $directory.FullName
                break
            }
            $directory = $directory.Parent
        }

        if ($repositoryRoot -and $gitDirectory) {
            $branch = 'unknown'
            $headPath = Join-Path $gitDirectory 'HEAD'
            if ([System.IO.File]::Exists($headPath)) {
                $head = [System.IO.File]::ReadAllText($headPath).Trim()
                if ($head.StartsWith('ref: refs/heads/')) {
                    $branch = $head.Substring('ref: refs/heads/'.Length)
                } elseif ($head.StartsWith('ref: ')) {
                    $branch = Split-Path $head.Substring('ref: '.Length) -Leaf
                } elseif ($head.Length -ge 7) {
                    $branch = $head.Substring(0, 7)
                }
            }

            $gitStatusCache = $global:_PromptGitStatusCache
            $cacheMatchesRepository = $gitStatusCache -and ($gitStatusCache.RepositoryRoot -eq $repositoryRoot)
            $statusText = if ($cacheMatchesRepository) {
                $statusParts = @()
                if (-not $gitStatusCache.Upstream) {
                    $statusParts += 'no-upstream'
                } elseif (-not $gitStatusCache.Ahead -and -not $gitStatusCache.Behind) {
                    $statusParts += 'synced'
                } else {
                    if ($gitStatusCache.Ahead) { $statusParts += "ahead:$($gitStatusCache.Ahead)" }
                    if ($gitStatusCache.Behind) { $statusParts += "behind:$($gitStatusCache.Behind)" }
                }

                $hasWorkingTreeChanges = $gitStatusCache.Staged -or $gitStatusCache.Unstaged -or $gitStatusCache.Untracked -or $gitStatusCache.Conflicted
                if ($hasWorkingTreeChanges) {
                    $statusParts += "staged:$($gitStatusCache.Staged)"
                    $statusParts += "unstaged:$($gitStatusCache.Unstaged)"
                    $statusParts += "untracked:$($gitStatusCache.Untracked)"
                } else {
                    $statusParts += 'clean'
                }
                if ($gitStatusCache.Conflicted) { $statusParts += "conflicts:$($gitStatusCache.Conflicted)" }
                if ($gitStatusCache.Stash) { $statusParts += "stash:$($gitStatusCache.Stash)" }
                $statusParts -join ' '
            } elseif ($global:_PromptGitExecutable) {
                'checking...'
            } else {
                ''
            }
            $gitText = " $gitIcon $branch $statusText ".TrimEnd() + ' '

            $cacheExpired = -not $cacheMatchesRepository -or (($now - $gitStatusCache.CheckedAt).TotalSeconds -ge 2)
            if ($global:_PromptGitExecutable -and -not $global:_PromptGitStatusTask -and $cacheExpired) {
                try {
                    $startInfo = [System.Diagnostics.ProcessStartInfo]::new()
                    $startInfo.FileName = $global:_PromptGitExecutable
                    $startInfo.Arguments = 'status --porcelain=v2 --branch --show-stash'
                    $startInfo.WorkingDirectory = $repositoryRoot
                    $startInfo.UseShellExecute = $false
                    $startInfo.CreateNoWindow = $true
                    $startInfo.RedirectStandardOutput = $true
                    $startInfo.RedirectStandardError = $true
                    $startInfo.EnvironmentVariables['GIT_OPTIONAL_LOCKS'] = '0'

                    $process = [System.Diagnostics.Process]::new()
                    $process.StartInfo = $startInfo
                    $null = $process.Start()
                    $global:_PromptGitStatusTask = [PSCustomObject]@{
                        RepositoryRoot = $repositoryRoot
                        Process = $process
                        Output = $process.StandardOutput.ReadToEndAsync()
                        Error = $process.StandardError.ReadToEndAsync()
                        StartedAt = $now
                    }
                } catch {
                    if ($process) { try { $process.Dispose() } catch {} }
                }
            }
        }
    }

    # Segment 3: execution time.
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

    # Assemble line 1: path, branch/status, and optional execution time.
    # Colors: path = white on blue, git = black on green, time = white on red

    $line = "$e[97;44m $cwd "                       # path segment

    if ($gitText) {
        $line += "$e[34;42m$sep"                     # blue to green transition
        $line += "$e[30;42m$gitText"                 # git segment
        if ($timeText) {
            $line += "$e[32;41m$sep"                 # green to red transition
            $line += "$e[97;41m$timeText"            # time segment
            $line += "$e[0;31m$sep"                  # red to default transition
        } else {
            $line += "$e[0;32m$sep"                  # green to default transition
        }
    } elseif ($timeText) {
        $line += "$e[34;41m$sep"                     # blue to red transition
        $line += "$e[97;41m$timeText"                # time segment
        $line += "$e[0;31m$sep"                      # red to default transition
    } else {
        $line += "$e[0;34m$sep"                      # blue to default transition
    }

    $line += $reset

    # Line 2: prompt indicator.
    $promptColor = if ($lastSuccess) { '34' } else { '31' }  # blue or red
    $indicator = "$e[${promptColor}m$([char]0x276F)$reset "

    # Window title.
    if ($global:_PromptLastWindowTitle -ne $cwd) {
        try {
            $host.UI.RawUI.WindowTitle = $cwd
            $global:_PromptLastWindowTitle = $cwd
        } catch {}
    }

    return "$line`n$indicator"
}
