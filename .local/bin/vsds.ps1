#Requires -Version 5.1
#!Requires Visual Studio 2022 or later

<#
.SYNOPSIS
    Set up Visual Studio Developer Shell environment.
.DESCRIPTION
    This script sets up Visual Studio Developer Shell environment.
.PARAMETER Arch
    The target architecture of the Visual Studio Developer Shell.
    Default is 'amd64'.
.PARAMETER KeepModule
    Keep the module loaded after setting up the environment.
    Default is $false.
#>
param (
    [ValidateSet('x86', 'amd64', 'arm', 'arm64')]
    [string]
    $Arch,
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

        Import-Module (Get-ChildItem $vsPath -File -Filter Microsoft.VisualStudio.DevShell.dll -Recurse).FullName
    }

    if (-not $Arch) {
        $envArch = $env:PROCESSOR_ARCHITECTURE
        $Arch = if ($envArch) { $envArch.ToLower() } else { 'amd64' }
    }

    Write-Verbose "Setting up environment variables"
    Write-Verbose "Arch: '$Arch'"
    # https://learn.microsoft.com/en-us/visualstudio/ide/reference/command-prompt-powershell?view=vs-2022#skipautomaticlocation
    Enter-VsDevShell -VsInstallPath $vsPath -SkipAutomaticLocation -DevCmdArguments "-arch=$Arch"

    if (-not $KeepModule) {
        Remove-Module Microsoft.VisualStudio.DevShell
    }
}

Enter-DevShell
