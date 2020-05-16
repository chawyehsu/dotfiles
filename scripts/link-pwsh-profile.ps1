#Requires -Version 5
# non-Windows unsupported
if (!$IsWindows) { exit 1 }
$profile_source = "$PSScriptRoot\..\src\Documents\PowerShell\profile.ps1"
$pwsh_profile = "$env:USERPROFILE\Documents\PowerShell\profile.ps1"
$ppwershell_profile = "$env:USERPROFILE\Documents\WindowsPowerShell\profile.ps1"

Write-Output "Clean old PowerShell profiles..."
$pwsh_profile, $ppwershell_profile | ForEach-Object {
    if (Test-Path $_) {
        Remove-Item -Path $_ -Force
    }
}
Write-Output "Link new PowerShell profiles..."
New-Item -ItemType SymbolicLink -Path $pwsh_profile -Target $profile_source | Out-Null
New-Item -ItemType SymbolicLink -Path $ppwershell_profile -Target $profile_source | Out-Null
Write-Output "Done."
