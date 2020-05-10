#requires -Version 2 -Modules posh-git

function Write-Theme {
    param(
        [bool] $lastCommandFailed,
        [string] $with
    )

    $adminIconForegroundColor = [ConsoleColor]::Yellow
    $adminIconBackgroundColor = [ConsoleColor]::DarkRed
    $failedCommandForegroundColor = [ConsoleColor]::DarkRed
    $failedCommandBackgroundColor = [ConsoleColor]::Yellow
    $pathForegroundColor = [ConsoleColor]::White
    $pathBackgroundColor = [ConsoleColor]::DarkBlue
    $gitForegroundColor = [ConsoleColor]::Black
    $gitBackgroundColor = [ConsoleColor]::Green
    $whoamiForegroundColor = [ConsoleColor]::White
    $whoamiBackgroundColor = [ConsoleColor]::DarkBlue
    $dateForegroundColor = [ConsoleColor]::Black
    $dateBackgroundColor = [ConsoleColor]::Green
    $timeForegroundColor = [ConsoleColor]::White
    $timeBackgroundColor = [ConsoleColor]::DarkBlue
    $lastBackgroundColor = $pathBackgroundColor

    $elevatedSymbol = [char]::ConvertFromUtf32(0x26A1) # ⚡
    $failedCommandSymbol = [char]::ConvertFromUtf32(0x2A2F) # ⨯
    $forwardSymbol = [char]::ConvertFromUtf32(0xE0B0) # 
    $backwardSymbol = [char]::ConvertFromUtf32(0xE0B2) # 

    # Create empty prompt object
    $prompt = Write-Prompt -Object ''

    ###
    # Populate left side of prompt
    ###

    # Add ⚡ icon before prompt if running in elevated mode
    if (Test-Administrator) {
        $prompt += Write-Prompt -Object " $($elevatedSymbol) " -ForegroundColor $adminIconForegroundColor -BackgroundColor $adminIconBackgroundColor
        $lastBackgroundColor = $adminIconBackgroundColor
    }

    # Add ⨯ icon before prompt if last command failed
    if ($lastCommandFailed) {
        if (Test-Administrator) {
            $prompt += Write-Prompt -Object $forwardSymbol -ForegroundColor $lastBackgroundColor -BackgroundColor $failedCommandBackgroundColor
        }
        $prompt += Write-Prompt -Object " $($failedCommandSymbol) " -ForegroundColor $failedCommandForegroundColor -BackgroundColor $failedCommandBackgroundColor
        $lastBackgroundColor = $failedCommandBackgroundColor
    }

    # Add path to prompt
    $path = Get-FullPath -dir $pwd
    $prompt += Write-Prompt -Object $forwardSymbol -ForegroundColor $lastBackgroundColor -BackgroundColor $pathBackgroundColor
    $prompt += Write-Prompt -Object " $path " -ForegroundColor $pathForegroundColor -BackgroundColor $pathBackgroundColor
    $lastBackgroundColor = $pathBackgroundColor

    # Add git info to prompt if in git repo
    $status = Get-VCSStatus
    if ($status) {
        $themeInfo = Get-VcsInfo -status ($status)
        $prompt += Write-Prompt -Object $forwardSymbol -ForegroundColor $lastBackgroundColor -BackgroundColor $gitBackgroundColor
        $prompt += Write-Prompt -Object " $($themeInfo.VcInfo) " -ForegroundColor $gitForegroundColor -BackgroundColor $gitBackgroundColor
        $lastBackgroundColor = $gitBackgroundColor
    }

    $prompt += Write-Prompt -Object $forwardSymbol -ForegroundColor $lastBackgroundColor

    ###
    # Populate right side of prompt
    ###

    $rightOffset = 0
    $user = $sl.CurrentUser
    $computer = [System.Environment]::MachineName.ToLower()
    if (Test-NotDefaultUser($user)) {
        $whoamiText = " $($user)@$($computer) "
        $rightOffset += $whoamiText.Length - 1
        $prompt += Set-CursorForRightBlockWrite -textLength $rightOffset
        $prompt += Write-Prompt $whoamiText -ForegroundColor $whoamiForegroundColor -BackgroundColor $whoamiBackgroundColor
        $lastBackgroundColor = $whoamiBackgroundColor
    }

    $date = Get-Date -UFormat " %a %b. %d %Y "
    $rightOffset += $date.Length + 1
    $prompt += Set-CursorForRightBlockWrite -textLength $rightOffset
    $prompt += Write-Prompt $date -ForegroundColor $dateForegroundColor -BackgroundColor $dateBackgroundColor
    $prompt += Write-Prompt -Object $backwardSymbol -ForegroundColor $lastBackgroundColor -BackgroundColor $dateBackgroundColor
    $lastBackgroundColor = $dateBackgroundColor

    $time = Get-Date -UFormat " %I:%M %p "
    $rightOffset += $time.Length + 2
    $prompt += Set-CursorForRightBlockWrite -textLength $rightOffset
    $prompt += Write-Prompt -Object $backwardSymbol -ForegroundColor $timeBackgroundColor -BackgroundColor $dateForegroundColor
    $prompt += Write-Prompt $time -ForegroundColor $timeForegroundColor -BackgroundColor $timeBackgroundColor
    $prompt += Write-Prompt -Object $backwardSymbol -ForegroundColor $lastBackgroundColor -BackgroundColor $timeBackgroundColor
    $lastBackgroundColor = $timeBackgroundColor

    $prompt += Set-Newline

    if ($with) {
        $prompt += Write-Prompt -Object "$($with.ToUpper()) " -BackgroundColor $sl.Colors.WithBackgroundColor -ForegroundColor $sl.Colors.WithForegroundColor
    }

    $prompt += Write-Prompt -Object ($sl.PromptSymbols.PromptIndicator) -ForegroundColor $sl.Colors.PromptBackgroundColor
    $prompt += ' '
    $prompt
}

$sl = $Global:ThemeSettings # Theme Settings

# GitSymbols
$sl.GitSymbols.LocalWorkingStatusSymbol = '!' # !
$sl.GitSymbols.BranchUntrackedSymbol = [char]::ConvertFromUtf32(0x2262) # ≢
$sl.GitSymbols.BranchAheadStatusSymbol = [char]::ConvertFromUtf32(0x2191) # ↑
$sl.GitSymbols.BranchSymbol = [char]::ConvertFromUtf32(0xE0A0) # 
$sl.GitSymbols.BranchIdenticalStatusToSymbol = [char]::ConvertFromUtf32(0x2263) # ≣
$sl.GitSymbols.BeforeStashSymbol = '{' # {
$sl.GitSymbols.LocalStagedStatusSymbol = '~' # ~
$sl.GitSymbols.AfterStashSymbol = '}' # }
$sl.GitSymbols.DelimSymbol = '|' # |
$sl.GitSymbols.BranchBehindStatusSymbol = [char]::ConvertFromUtf32(0x2193) # ↓

# PromptSymbols
$sl.PromptSymbols.SegmentSeparatorForwardSymbol = [char]::ConvertFromUtf32(0xE0B0) # 
$sl.PromptSymbols.ElevatedSymbol = [char]::ConvertFromUtf32(0x26A1) # ⚡
$sl.PromptSymbols.TruncatedFolderSymbol = ".." # ..
$sl.PromptSymbols.SegmentSeparatorBackwardSymbol = [char]::ConvertFromUtf32(0xE0B2) # 
$sl.PromptSymbols.StartSymbol = '' #
$sl.PromptSymbols.VirtualEnvSymbol = [char]::ConvertFromUtf32(0xE606) # 
$sl.PromptSymbols.PromptIndicator = [char]::ConvertFromUtf32(0x276F) # ❯
$sl.PromptSymbols.SegmentBackwardSymbol = [char]::ConvertFromUtf32(0xE0B2) # 
$sl.PromptSymbols.SegmentForwardSymbol = [char]::ConvertFromUtf32(0xE0B0) # 
$sl.PromptSymbols.FailedCommandSymbol = [char]::ConvertFromUtf32(0x2A2F) # ⨯
$sl.PromptSymbols.PathSeparator = '\' # \
