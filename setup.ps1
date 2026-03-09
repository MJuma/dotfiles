<#
.SYNOPSIS
    Link dotfiles to their expected locations.
.DESCRIPTION
    Creates symbolic links for dotfiles without running the full FirstRun setup.
    Backs up existing files before overwriting.
.PARAMETER DryRun
    Show what would be done without making changes.
.EXAMPLE
    .\setup.ps1
.EXAMPLE
    .\setup.ps1 -DryRun
#>

param(
    [switch]$DryRun
)

$e = [char]27
$blue = "$e[34m"
$green = "$e[32m"
$yellow = "$e[33m"
$reset = "$e[0m"
$bold = "$e[1m"

$dotfilesRoot = $PSScriptRoot

function Write-Header {
    Write-Host ""
    Write-Host "${blue}================================================================================${reset}"
    Write-Host "  ${bold}dotfiles setup${reset}"
    if ($DryRun) { Write-Host "  ${yellow}(Dry Run)${reset}" }
    Write-Host "${blue}================================================================================${reset}"
    Write-Host ""
}

function Backup-File([string]$Path) {
    if (Test-Path $Path) {
        $item = Get-Item $Path -Force
        # Skip if already a symlink pointing into dotfiles
        if ($item.LinkType -eq 'SymbolicLink' -and $item.Target -like "*dotfiles*") {
            return $false
        }
        $backupPath = "$Path.old"
        if ($DryRun) {
            Write-Host "  Would backup: $Path ${blue}=>${reset} $backupPath"
        } else {
            Move-Item -Path $Path -Destination $backupPath -Force
            Write-Host "  Backed up: $Path ${blue}=>${reset} $backupPath"
        }
        return $true
    }
    return $false
}

function New-Symlink([string]$Link, [string]$Target) {
    if (-not (Test-Path $Target)) {
        Write-Host "  ${yellow}Skipped:${reset} $Target does not exist"
        return
    }

    Backup-File $Link | Out-Null

    if ($DryRun) {
        Write-Host "  Would link: $Link ${blue}=>${reset} $Target"
    } else {
        $parent = Split-Path $Link -Parent
        if (-not (Test-Path $parent)) {
            New-Item -ItemType Directory -Path $parent -Force | Out-Null
        }
        New-Item -ItemType SymbolicLink -Path $Link -Value $Target -Force | Out-Null
        Write-Host "  ${green}Linked:${reset} $Link ${blue}=>${reset} $Target"
    }
}

Write-Header

# PowerShell profile
Write-Host "${bold}PowerShell profile${reset}"
$profileDir = Split-Path $PROFILE -Parent
if (-not (Test-Path $profileDir)) {
    if ($DryRun) {
        Write-Host "  Would create: $profileDir"
    } else {
        New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
        Write-Host "  ${green}Created:${reset} $profileDir"
    }
}
$sourceLine = ". `"$dotfilesRoot\pwsh\profile.ps1`""
$alreadyPresent = (Test-Path $PROFILE) -and (Select-String -Path $PROFILE -Pattern ([regex]::Escape($sourceLine)) -SimpleMatch -Quiet)
if ($alreadyPresent) {
    Write-Host "  ${green}Already present:${reset} $PROFILE already dot-sources dotfiles profile"
} elseif ($DryRun) {
    Write-Host "  Would append: $sourceLine to $PROFILE"
} else {
    Add-Content -Path $PROFILE -Value "`n$sourceLine"
    Write-Host "  ${green}Appended:${reset} dot-source line to $PROFILE"
}
Write-Host ""

# Git config
Write-Host "${bold}Git config${reset}"
New-Symlink "$HOME\.gitconfig" "$dotfilesRoot\git\.gitconfig"
Write-Host ""

# Windows Terminal settings
$wtSettingsDir = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
if (Test-Path $wtSettingsDir) {
    Write-Host "${bold}Windows Terminal${reset}"
    New-Symlink "$wtSettingsDir\settings.json" "$dotfilesRoot\pwsh\windows-terminal\settings.json"
    Write-Host ""
}

# CMD doskey registry
Write-Host "${bold}Command Prompt (doskey)${reset}"
$doskeyPath = "$dotfilesRoot\pwsh\doskey.cmd"
if ($DryRun) {
    Write-Host "  Would set registry: HKCU\Software\Microsoft\Command Processor\Autorun ${blue}=>${reset} $doskeyPath"
} else {
    REG ADD "HKCU\Software\Microsoft\Command Processor" /v Autorun /t REG_EXPAND_SZ /d $doskeyPath /f 2>&1 | Out-Null
    Write-Host "  ${green}Set registry:${reset} HKCU\...\Command Processor\Autorun ${blue}=>${reset} $doskeyPath"
}
Write-Host ""

Write-Host "${blue}================================================================================${reset}"
Write-Host "  ${green}Setup complete!${reset}"
Write-Host "${blue}================================================================================${reset}"
Write-Host ""
