#Requires -Version 5.1

<#
.SYNOPSIS
    Check and create OpenSSH Server firewall rule
.DESCRIPTION
    This PowerShell script checks for the existence of a firewall rule named
    "OpenSSH-Server-In-TCP". If the rule does not exist, it creates the rule
    to allow inbound TCP traffic on port 22.
.PARAMETER Profile
    The network profile for which the firewall rule should be applied.
    Valid values are 'Private', 'Public', 'Domain', and 'Any'.
    Default is 'Private'.
.PARAMETER AssumeYes
    If specified, the script will automatically create the firewall rule without
    prompting for confirmation. Default is to prompt before creating the rule.
#>
param(
    [Parameter(Mandatory = $false)]
    [ValidateSet('Private', 'Public', 'Domain', 'Any')]
    [string]$Profile = 'Private',
    [Parameter(Mandatory = $false)]
    [switch]$AssumeYes
)

if (($PSVersionTable.PSVersion.Major) -gt 5) {
    if (-not $IsWindows) {
        Write-Error "This script is intended to run on Windows systems only."
        exit 1
    }
}

$ErrorActionPreference = 'Stop'

if (!([bool](Get-Command -Name 'sshd' -CommandType Application -ErrorAction SilentlyContinue))) {
    Write-Host "OpenSSH Server (sshd) is not available on this system." -ForegroundColor DarkYellow
    Write-Host "Hint: install via 'winget install Microsoft.OpenSSH.Preview'"
}

if (!(Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" `
    -ErrorAction SilentlyContinue | Select-Object Name, Enabled)) {
    $ScriptBlock = {
        New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' `
            -DisplayName 'OpenSSH Server (sshd)' -Enabled True `
            -Direction Inbound -Protocol TCP -Action Allow `
            -LocalPort 22 -Profile $Profile
    }

    if (-not $AssumeYes) {
        $confirmation = Read-Host "Firewall rule 'OpenSSH-Server-In-TCP' does not exist. Do you want to create it? (y/N)"
        if ($confirmation -ne 'Y' -and $confirmation -ne 'y') {
            exit 0
        }
    }

    Start-Process powershell -Verb RunAs -WindowStyle Hidden -Wait `
        -ArgumentList "-NoProfile -Command $($ScriptBlock.ToString())"
    Write-Host "Firewall Rule 'OpenSSH-Server-In-TCP' has been created successfully." -ForegroundColor DarkGreen
} else {
    Write-Host "Firewall rule 'OpenSSH-Server-In-TCP' has already been created."
}
