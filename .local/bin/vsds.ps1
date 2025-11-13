#Requires -Version 5.1
#!Requires Visual Studio 2022 17.1 or later

<#
.SYNOPSIS
    Set up Visual Studio Developer Shell environment.
.DESCRIPTION
    This script sets up Visual Studio Developer Shell environment.
.PARAMETER HostArch
    The host application of the Visual Studio Developer Shell. Valid
    values are 'x86' and 'amd64'.
    Default is 'Default'.
.PARAMETER TargetArch
    The target architecture of the Visual Studio Developer Shell.
    Default is automatically detected through the PROCESSOR_ARCHITECTURE
    environment variable.
.PARAMETER KeepModule
    Keep the module loaded after setting up the environment.
    Default is $false.
#>
param (
    [ValidateSet('x86', 'amd64')]
    [string]
    $HostArch = 'Default',
    [ValidateSet('x86', 'amd64', 'arm', 'arm64')]
    [string]
    $TargetArch,
    [switch]
    $KeepModule = $false
)

Set-StrictMode -Version Latest

function Test-IsNotWindows {
    return ((Test-Path Variable:\IsWindows) -and (-not $IsWindows))
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

function Enter-DevShell {
    $ErrorActionPreference = 'Stop'

    if (Test-IsNotWindows) {
        Write-Output "This script is for Windows only."
        return
    }

    if (Test-Command 'cl.exe') {
        Write-Output "Visual Studio Developer Shell already set up."
        return
    }

    if ([bool](Get-Module -Name Microsoft.VisualStudio.DevShell)) {
        Write-Verbose "Microsoft.VisualStudio.DevShell module already loaded:"
        (Get-Module -Name Microsoft.VisualStudio.DevShell).Path | Write-Verbose
    } else {
        # Find VC: https://github.com/microsoft/vswhere/wiki/Find-VC
        $vswhere = "${Env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
        if (-not (Test-Path $vswhere)) {
            Write-Output "Visual Studio Installer not installed, vswhere.exe not found."
            return
        }

        $vsPath = & $vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
        Write-Verbose "Microsoft Visual Studio: '$vsPath'"
        if ($vsPath -eq '') {
            Write-Output "Visual Studio with C++ tools not found."
            return
        }

        Import-Module (Get-ChildItem $vsPath -File -Filter Microsoft.VisualStudio.DevShell.dll -Recurse).FullName
    }

    if (-not $TargetArch) {
        $TargetArch = switch ($env:PROCESSOR_ARCHITECTURE) {
            'AMD64' { 'amd64' }
            'x86'   { 'x86' }
            'ARM64' { 'arm64' }
            'ARM'   { 'arm' }
            default { 'amd64' }
        }
    }

    Write-Verbose "Setting up environment variables"
    Write-Verbose "Host: $HostArch, Target: '$TargetArch'"
    # https://learn.microsoft.com/en-us/visualstudio/ide/reference/command-prompt-powershell?view=vs-2022#skipautomaticlocation
    Enter-VsDevShell -VsInstallPath $vsPath -SkipAutomaticLocation -HostArch $HostArch -Arch $TargetArch

    if (-not $KeepModule) {
        Remove-Module Microsoft.VisualStudio.DevShell
    }
}

Enter-DevShell
