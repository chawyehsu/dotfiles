#Requires -Version 7
# License: MIT
# References:
#  - https://devblogs.microsoft.com/powershell/optimizing-your-profile/

<#
.SYNOPSIS
    Powershell profile performance measurement script.
.DESCRIPTION
    This script measures the average startup time of PowerShell w|wo profile.
.PARAMETER BaselineOnly
    Measure only the baseline (no profile) startup time.
.PARAMETER Iterations
    Number of iterations to run for measuring the startup time. Default is 10.
#>
param(
    [Parameter(Mandatory = $false)]
    [switch]$BaselineOnly = $false,
    [Parameter(Mandatory = $false)]
    [Int32]$Iterations = 10
)

Set-StrictMode -Version 1.0

function Measure-Profile {
    param(
        [switch]$Baseline = $false
    )

    $t = 0
    $cmd = if ($Baseline) { 'pwsh -noprofile -command 1' } else { 'pwsh -command 1' }
    $title = if ($Baseline) { 'Baseline (no profile)' } else { 'Current (with profile)' }

    1..$Script:Iterations | ForEach-Object {
        Write-Progress -Id 1 -Activity $title -PercentComplete $_
        $t += (Measure-Command {
            Invoke-Expression $cmd
        }).TotalMilliseconds
    }
    Write-Progress -Id 1 -Activity $title -Completed
    return $t / $Script:Iterations
}

if ($BaselineOnly) {
    $baseline = Measure-Profile -Baseline
    Write-Host "Baseline: $baseline ms" -ForegroundColor Blue
} else {
    $baseline = Measure-Profile -Baseline
    $current = Measure-Profile
    Write-Host "Baseline: $baseline ms`nCurrent: $current ms" -ForegroundColor Blue
}
