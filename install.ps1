#!/usr/bin/env pwsh
#Requires -Version 7

<#
.SYNOPSIS
    Dotfiles installer.
.DESCRIPTION
    Script to pour dotfiles into your home directory.
.PARAMETER BackupDir
    Directory to store backup files. Default is ~/dotfiles.backup[datetime].
.PARAMETER NoBackup
    Do not backup existing dotfiles. Default is to create a backup when a same
    dotfile already exists.
.LINK
    https://github.com/chawyehsu/dotfiles
#>
param(
    [Parameter(Mandatory = $false)]
    [string]$BackupDir = "~/dotfiles.backup$(Get-Date -Format 'yyyyMMddHHmmss')",
    [Parameter(Mandatory = $false)]
    [Switch]$NoBackup
)

Set-StrictMode -Version Latest

Write-Host 'This will overwrite all current local dotfiles' -ForegroundColor Red
if ($NoBackup) {
    Write-Host '[CAUTION!] No backup will be created' -ForegroundColor Red
} else {
    Write-Host "A backup will be created at $BackupDir" -ForegroundColor Yellow
}
Read-Host 'Press ENTER to continue or Ctrl+C to cancel'

$SRCROOT = (Resolve-Path "$PSScriptRoot/")
$DSTROOT = (Resolve-Path (($env:HOME, $env:USERPROFILE |
            Where-Object { -not [String]::IsNullOrEmpty($_) } |
            Select-Object -First 1).ToString().TrimEnd('/') + '/'))

function Test-IsWindows() {
    return $env:OS -eq 'Windows_NT' -or $IsWindows
}

function Get-NormalizedPath ([String]$in) {
    # from: https://stackoverflow.com/a/12605755/3651279
    $out = Resolve-Path $in -ErrorAction SilentlyContinue -ErrorVariable _errOut
    # Return the `resolved` inputPath even if it's not exist.
    if (-not $out) { $out = $_errOut[0].TargetObject }
    return $out
}

function Backup-Item([String]$Path) {
    if (Test-Path $Path) {
        Write-Output "Backup $Path"
        $ItemPathNoQualifier = Split-Path $Path -NoQualifier
        $BackupPath = (Join-Path $BackupDir $ItemPathNoQualifier)
        if (Test-Path $BackupPath) {
            Remove-Item -Path $BackupPath -Recurse -Force
        }
        $BackupPathParent = Split-Path $BackupPath -Parent
        New-Item -ItemType Directory -Path $BackupPathParent -Force | Out-Null
        Copy-Item -Path $Path -Destination $BackupPath -Recurse -Container -Force
        # Dangerous operation here
        Remove-Item -Path $Path -Recurse -Force
    }
}

function Set-SymbolicLink([String]$Target, [String]$Path) {
    if (!$Path) { $Path = $Target }

    $src = if ([System.IO.Path]::IsPathRooted($Target)) {
        Get-NormalizedPath  $Path
    } else {
        (Join-Path $SRCROOT $Target)
    }

    $DestPath = if ([System.IO.Path]::IsPathRooted($Path)) {
        Get-NormalizedPath  $Path
    } else {
        (Join-Path $DSTROOT $Path)
    }

    Write-Output "$($DestPath.ToString()) -> $($src.ToString())"
    New-Item -Type SymbolicLink -Path $DestPath -Target $src -Force | Out-Null
}


# Backup
if (-not $NoBackup) {
    $BackupDir = Get-NormalizedPath $BackupDir
    if (-not (Test-Path $BackupDir)) {
        New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
    }

    $DotfilesToBackup = @()
    # dotfiles deprecated in favor of XDG compliance
    $DotfilesDeprecated = @(
        '.condarc',
        '.gemrc',
        '.gitconfig',
        '.gvimrc',
        '.inputrc',
        '.mintty',
        '.nanorc',
        '.npmrc',
        '.tmux.conf',
        '.vimrc'
    )
    $DotfilesToBackup = $DotfilesToBackup + $DotfilesDeprecated

    # dotfiles to be linked
    $DotfilesToBeLinked = @(
        '.bash_logout',
        '.bash_profile',
        '.bashrc',
        '.cargo/config',
        '.config/conda',
        '.config/gem',
        '.config/gh/config',
        '.config/git/config',
        '.config/git/config.local',
        '.config/git/ignore',
        '.config/mintty',
        '.config/nano',
        '.config/npm',
        '.config/pip',
        '.config/pixi',
        '.config/powershell/profile.ps1',
        '.config/proxychains/proxychains.conf',
        '.config/readline/inputrc',
        '.config/screen/screenrc',
        '.config/starship.toml',
        '.config/tmux',
        '.config/volta/hook.json',
        '.config/wget/wgetrc',
        '.dir_colors',
        '.gnupg/gpg-agent.conf',
        '.gnupg/gpg.conf',
        '.gradle/gradle.properties',
        '.pip',
        '.rprofile',
        '.screenrc',
        '.volta',
        '.wgetrc'
    )
    $DotfilesToBackup = $DotfilesToBackup + $DotfilesToBeLinked

    # Windows only
    if (Test-IsWindows) {
        $DotfilesWindowsOnly = @(
            '.config/concfg',
            '.config/pshazz',
            '.config/scoop/config.json',
            '.wslconfig',
            'pip',
            'Rconsole',
            "$env:APPDATA/pip",
            "$env:LOCALAPPDATA/Microsoft/Windows Terminal/settings.json",
            "$env:APPDATA/nushell"
        )
        $DotfilesToBackup = $DotfilesToBackup + $DotfilesWindowsOnly
    }

    $DotfilesToBackup | ForEach-Object {
        $Path = if ([System.IO.Path]::IsPathRooted($_)) {
            Get-NormalizedPath "$_"
        } else {
            Get-NormalizedPath "$DSTROOT/$_"
        }
        Backup-Item $Path
    }

    Write-Host "Backup created at $BackupDir" -ForegroundColor Green
}

# Link dotfiles
Set-SymbolicLink -Target '.bash_logout'
Set-SymbolicLink -Target '.bash_profile'
Set-SymbolicLink -Target '.bashrc'
Set-SymbolicLink -Target '.config/bat/config'
Set-SymbolicLink -Target '.cargo/config.toml'
Set-SymbolicLink -Target '.config/conda'
Set-SymbolicLink -Target '.config/gem/gemrc'
Set-SymbolicLink -Target '.config/gh/config.yml'
Set-SymbolicLink -Target '.config/git/config'
Set-SymbolicLink -Target '.config/git/ignore'
Set-SymbolicLink -Target '.config/mintty'
Set-SymbolicLink -Target '.config/nano'
Set-SymbolicLink -Target '.config/starship.toml'
Set-SymbolicLink -Target '.dir_colors'
Set-SymbolicLink -Target '.gnupg/gpg-agent.conf'
Set-SymbolicLink -Target '.gnupg/gpg.conf'
Set-SymbolicLink -Target '.gradle/gradle.properties'
Set-SymbolicLink -Target '.config/pixi/config.toml'
Set-SymbolicLink -Target '.config/r/.rprofile' -Path '.rprofile'
Set-SymbolicLink -Target '.config/readline/inputrc'
Set-SymbolicLink -Target '.config/starship.toml'
Set-SymbolicLink -Target '.config/tmux'
Set-SymbolicLink -Target '.config/wget/wgetrc' -Path '.wgetrc'
# Link dotfiles (platform specific)
if (Test-IsWindows) {
    # git config for Windows
    Set-SymbolicLink -Target '.config/git/config.win.conf' `
        -Path '.config/git/config.local'
    # PowerShell profile
    Set-SymbolicLink -Target '.config/powershell/profile.ps1' `
        -Path $PROFILE.CurrentUserAllHosts
    # Scoop, pshazz and concfg
    Set-SymbolicLink -Target '.config/concfg'
    Set-SymbolicLink -Target '.config/pshazz'
    Set-SymbolicLink -Target '.config/scoop/config.json'
    # pip on Windows only uses %APPDATA%/pip
    Set-SymbolicLink -Target '.config/pip' -Path "$env:APPDATA/pip"
    # proxychains
    Set-SymbolicLink -Target '.config/proxychains/proxychains.conf' `
        -Path '.proxychains/proxychains.conf'
    # R for Windows
    Set-SymbolicLink -Target '.config/r/Rconsole' -Path 'Rconsole'
    # Windows Terminal
    Set-SymbolicLink -Target 'scoop/persist/windows-terminal/settings/settings.json' `
        -Path "$env:LOCALAPPDATA/Microsoft/Windows Terminal/settings.json"
    if (Test-Path "$env:LOCALAPPDATA/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState") {
        Set-SymbolicLink -Target 'scoop/persist/windows-terminal/settings/settings.json' `
            -Path "$env:LOCALAPPDATA/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json"
    }
    # WSL host config
    Set-SymbolicLink -Target '.config/wsl/.wslconfig' -Path '.wslconfig'
    # Nushell
    Set-SymbolicLink -Target '.config/nushell' -Path "$env:APPDATA/nushell"
    # Helix
    Set-SymbolicLink -Target '.config/helix' -Path "$env:APPDATA/helix"
} else {
    # git config for macOS and Linux
    if ($IsMacOS) {
        # macOS
        Set-SymbolicLink -Target '.config/git/config.mac.conf' `
            -Path '.config/git/config.local'
    } else {
        # Linux
        Set-SymbolicLink -Target '.config/git/config.linux.conf' `
            -Path '.config/git/config.local'
    }
    # PowerShell profile
    Set-SymbolicLink -Target '.config/powershell/profile.ps1'
    # Volta Hooks
    Set-SymbolicLink -Target '.config/volta' -Path '.volta'
    # pip
    Set-SymbolicLink -Target '.config/pip/pip.ini' -Path '.config/pip/pip.conf'
    # screen
    Set-SymbolicLink -Target '.config/screen/screenrc' -Path '.screenrc'
}
