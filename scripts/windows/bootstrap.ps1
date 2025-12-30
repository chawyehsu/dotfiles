#Requires -Version 5.1

Set-StrictMode -Version Latest

$Script:SCOOP_INSTALLER_URL = 'https://raw.githubusercontent.com/ScoopInstaller/Install/ff4eedda58d832b8225d7697510f097ebe8ab071/install.ps1'
$Script:PROXY = if (Test-Path Env:HTTPS_PROXY) {
    "$env:HTTPS_PROXY"
} elseif (Test-Path Env:HTTP_PROXY) {
    "$env:HTTP_PROXY"
} else {
    $null
}

function Test-IsNotWindows {
    return ((Test-Path Variable:\IsWindows) -and (-not $IsWindows))
}

function Test-CommandAvailable {
    param (
        [Parameter(Mandatory = $True, Position = 0)]
        [String] $Command
    )
    return [Boolean](Get-Command $Command -ErrorAction SilentlyContinue)
}

function Install-Scoop {
    if (Test-CommandAvailable 'scoop') {
        Write-Host -ForegroundColor Yellow "Scoop is already installed."
        return
    }

    if ($Script:PROXY) {
        Write-Verbose "Running scoop installer with proxy $Script:PROXY"
        Invoke-RestMethod -Uri $Script:SCOOP_INSTALLER_URL -Proxy $Script:PROXY | Invoke-Expression
    } else {
        Invoke-RestMethod -Uri $Script:SCOOP_INSTALLER_URL | Invoke-Expression
    }

    if (-not (Test-CommandAvailable 'scoop')) {
        Write-Host -ForegroundColor Red "Scoop installation failed."
        exit 1
    }

    if ($Script:PROXY) {
        $parsedProxy = $Script:PROXY -replace '^(http|https)://', ''
        scoop config proxy $parsedProxy
    }

    scoop config show_update_log false
    scoop install 7zip
    # dorado/git is chosen because it does not expose (ba)sh executables
    scoop install https://raw.githubusercontent.com/chawyehsu/dorado/refs/heads/master/bucket/git.json

    scoop update
    scoop bucket add dorado https://github.com/chawyehsu/dorado

    # reinstall dorado/git ensuring update gets tracked
    scoop uninstall git
    scoop install dorado/git

    # essential packages
    scoop install main/concfg dorado/trash dorado/nano dorado/hok dorado/pixi main/pshazz
}

# Main flow
if (Test-IsNotWindows) {
    Write-Output "This script is for Windows only."
    return
}

$ErrorActionPreference = 'Stop'
Install-Scoop
