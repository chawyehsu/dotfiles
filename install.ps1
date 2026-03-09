#!/usr/bin/env pwsh
#Requires -Version 5.1

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
.PARAMETER NoDomestic
    Use dotfiles not optimized for domestic (China) network environment.
.PARAMETER AssumeYes
    Assume yes for all prompts. Default is to prompt before proceeding.
.LINK
    https://github.com/chawyehsu/dotfiles
#>
param(
    [Parameter(Mandatory = $false)]
    [string]$BackupDir = "~/dotfiles.backup$(Get-Date -Format 'yyyyMMddHHmmss')",
    [Parameter(Mandatory = $false)]
    [Switch]$NoBackup,
    [Parameter(Mandatory = $false)]
    [Switch]$NoDomestic,
    [Parameter(Mandatory = $false)]
    [Switch]$AssumeYes
)

Set-StrictMode -Version 3.0

$SRCROOT = (Resolve-Path "$PSScriptRoot/")
$DSTROOT = (Resolve-Path (($env:HOME, $env:USERPROFILE |
            Where-Object { -not [String]::IsNullOrEmpty($_) } |
            Select-Object -First 1).ToString().TrimEnd('/') + '/'))

function Test-IsAdministrator {
    return ([Security.Principal.WindowsPrincipal]`
            [Security.Principal.WindowsIdentity]::GetCurrent()`
    ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Test-Command {
    <#
    .SYNOPSIS
        Test if the given command exists.
    .PARAMETER Command
        The command to check.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Command
    )

    return [bool](Get-Command -Name $Command `
            -CommandType Application -ErrorAction SilentlyContinue)
}

function Test-IsWindows() {
    return $env:OS -eq 'Windows_NT' -or $IsWindows
}

function Test-IsLinux() {
    if ($PSVersionTable.PSVersion.Major -eq 5) {
        return $false
    }

    return $IsLinux
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
        if (-not $NoBackup) {
            Write-Host "Backed up $Path" -ForegroundColor DarkGray
        }
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

    New-Item -Type SymbolicLink -Path $DestPath -Target $src -Force | Out-Null
    Write-Host "Linked" -ForegroundColor Green -NoNewline
    Write-Host " $($DestPath.ToString())" -NoNewline
    Write-Host " -> $($Target.ToString())" -ForegroundColor DarkGray
}

#--------------#
#  Main logic  #
#--------------#
if ($PSVersionTable.PSVersion.Major -eq 5) {
    if (-not (Test-IsAdministrator)) {
        Write-Host 'Run this script as administrator to allow symbolic link creation.' -ForegroundColor Yellow
        exit 1
    }
}

Write-Host 'This will overwrite all current local dotfiles' -ForegroundColor Red
if ($NoBackup) {
    Write-Host '[CAUTION!] No backup will be created' -ForegroundColor Red
} else {
    Write-Host "A backup will be created at $BackupDir" -ForegroundColor Yellow
}
if (-not $AssumeYes) {
    Read-Host 'Press ENTER to continue or Ctrl+C to cancel'
}

$BackupDir = Get-NormalizedPath $BackupDir
if (-not (Test-Path $BackupDir)) {
    New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
}

# Load link definitions
$LinksFile = Join-Path $SRCROOT 'links.json'
$Links = Get-Content -Raw $LinksFile | ConvertFrom-Json

foreach ($Link in $Links) {
    # Platform filter
    if ($Link.psobject.Properties['os']) {
        $match = $false
        foreach ($os in $Link.os) {
            switch ($os) {
                'windows' { if (Test-IsWindows)        { $match = $true } }
                'macos'   { if ($IsMacOS)              { $match = $true } }
                'linux'   { if (Test-IsLinux)          { $match = $true } }
                'unix'    { if (-not (Test-IsWindows)) { $match = $true } }
            }
        }
        if (-not $match) { continue }
    }

    # Expand environment variables in path
    $path = $ExecutionContext.InvokeCommand.ExpandString($Link.path)

    # Back up original files
    $deprecated = if ($Link.psobject.Properties['replace']) { $Link.replace } else { @() }
    @($path) + @($deprecated) | ForEach-Object {
        $p = if ([System.IO.Path]::IsPathRooted($_)) {
            Get-NormalizedPath $_
        } else {
            Get-NormalizedPath "$DSTROOT/$_"
        }
        Backup-Item $p
    }

    # Resolve source: domestic variant, explicit target, or self
    if ($Link.psobject.Properties['domestic'] -and -not $NoDomestic) {
        $source = $Link.domestic
    } elseif ($Link.psobject.Properties['target']) {
        $source = $Link.target
    } else {
        $source = $Link.path
    }

    Set-SymbolicLink -Target $source -Path $path
}

# gnupg directory permission fix (non-Windows)
if (-not (Test-IsWindows)) {
    $gnupgPath = Join-Path $DSTROOT '.gnupg'
    if (Test-Path $gnupgPath) {
        Write-Host "Updated permissions for gnupg directory at $gnupgPath" -ForegroundColor Yellow
        chown -R $(whoami) $gnupgPath
        # `--%` (skip args parsing) is needed as we are in pwsh
        find $gnupgPath --% -type d -exec chmod 700 {} ;
        find $gnupgPath --% -type f -exec chmod 600 {} ;
    }
}


# non-domestic mark
$cacheDir = Join-Path $DSTROOT '.cache'
$nodomesticMarker = Join-Path $cacheDir '.nodomestic'
if ($NoDomestic) {
    New-Item -ItemType Directory -Path $cacheDir -Force -ErrorAction Ignore | Out-Null
    New-Item -ItemType File -Path $nodomesticMarker -Force -ErrorAction Ignore | Out-Null
} else {
    if (Test-Path $nodomesticMarker) {
        Remove-Item -Path $nodomesticMarker -Force
    }
}

# WSL
if (Test-IsLinux) {
    $IsWSL = Get-Content '/proc/version' | Select-String -Pattern 'microsoft'
    if ($IsWSL) {
        $root = (Get-NormalizedPath "$PSScriptRoot")
        Write-Host 'Detected WSL environment. You probably want to apply wsl config for the guest Linux by:' -ForegroundColor Yellow
        Write-Host "  sudo cp $root/.config/wsl/wsl.conf /etc/wsl.conf" -ForegroundColor Cyan
    }
}

# Delete backup if NoBackup is specified
if ($NoBackup) {
    if (Test-Path $BackupDir) {
        Remove-Item -Path $BackupDir -Recurse -Force
    }
}
