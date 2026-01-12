#Requires -Version 5.1

Set-StrictMode -Version 1.0

$Script:SCOOP_INSTALLER_URL = 'https://raw.githubusercontent.com/ScoopInstaller/Install/1e2f334083d609986d8c8bc9e31ae8e87c39fab4/install.ps1'
$Script:CONCFG_PRESET_URL = 'https://raw.githubusercontent.com/chawyehsu/base16-concfg/main/presets/base16-selenized-black.json'
$Script:PROXY = $env:HTTPS_PROXY, $env:HTTP_PROXY | Where-Object { $_ -ne $null } | Select-Object -First 1

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

function Import-Preferences {
    if (Test-CommandAvailable 'concfg') {
        Write-Host -ForegroundColor Green "Importing concfg preset..."
        concfg clean
        concfg import $Script:CONCFG_PRESET_URL -yn
    }
}

function Install-Scoop {
    if ($env:NO_SCOOP) {
        return
    }

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
    scoop install https://raw.githubusercontent.com/chawyehsu/dorado/master/bucket/git.json

    scoop update
    scoop bucket add dorado https://github.com/chawyehsu/dorado

    # reinstall dorado/git ensuring update gets tracked
    scoop uninstall git
    scoop install dorado/git

    # essential packages
    scoop install main/concfg dorado/trash dorado/nano dorado/hok dorado/pixi main/pshazz

    Import-Preferences
}

function Install-WinGet {
    # WinGet in Windows Sandbox
    if (($env:USERNAME -eq 'WDAGUtilityAccount') -and (-not (Test-CommandAvailable 'winget'))) {
        Write-Host "Installing WinGet..."
        Install-PackageProvider -Name NuGet -Force | Out-Null
        Install-Module -Name Microsoft.WinGet.Client -Force -Repository PSGallery | Out-Null
        Repair-WinGetPackageManager -AllUsers
    }
}

# Main flow
if (Test-IsNotWindows) {
    Write-Output "This script is for Windows only."
    return
}

$oldErrorActionPreference = $ErrorActionPreference
try {
    $ErrorActionPreference = 'Stop'
    Install-WinGet
    Install-Scoop
} finally {
    $ErrorActionPreference = $oldErrorActionPreference
}
