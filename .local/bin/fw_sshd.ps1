#Requires -Version 5.1

<#
.SYNOPSIS
    Check and create OpenSSH Server firewall rule
.DESCRIPTION
    This PowerShell script checks for the existence of a firewall rule named
    "OpenSSH-Server-In-TCP". If the rule does not exist, it creates the rule
    to allow inbound TCP traffic on port 22.
#>
param(
    [Parameter(Mandatory = $false)]
    [ValidateSet('Private', 'Public', 'Domain', 'Any')]
    [string]$Profile = 'Private'
)

if (($PSVersionTable.PSVersion.Major) -gt 5) {
    if (-not $IsWindows) {
        Write-Error "This script is intended to run on Windows systems only."
        exit 1
    }
}

if (!(Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue | Select-Object Name, Enabled)) {
    $ScriptBlock = {
        New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22 -Profile Private
    }

    Start-Process powershell -Verb RunAs -WindowStyle Hidden -Wait -ArgumentList "-NoProfile -Command $($ScriptBlock.ToString())"
    Write-Host "Firewall Rule 'OpenSSH-Server-In-TCP' has been created successfully." -ForegroundColor DarkGreen
} else {
    Write-Output "Firewall rule 'OpenSSH-Server-In-TCP' has already been created."
}
