#Requires -Version 5

$SRCROOT = (Resolve-Path "$PSScriptRoot/")
$DSTROOT = (Resolve-Path (($env:HOME, $env:USERPROFILE |
    Where-Object { -not [String]::IsNullOrEmpty($_) } |
    Select-Object -First 1).ToString().TrimEnd('/') + '/'))

function Set-SymbolicLink([String]$Target, [String]$Path) {
    if (!$Path) { $Path = $Target }
    $src = (Join-Path $SRCROOT $Target)
    $dst = (Join-Path $DSTROOT $Path)
    Write-Output $dst

    if (Test-Path $dst) {
        Remove-Item -Path $dst -Force
    }
    New-Item -Type SymbolicLink -Path $dst -Target $src -Force | Out-Null
}

$SRCROOT
$DSTROOT

# Core dotfiles
Set-SymbolicLink -Target ".bash_logout"
Set-SymbolicLink -Target ".bash_profile"
Set-SymbolicLink -Target ".bashrc"
Set-SymbolicLink -Target ".cargo/config"
Set-SymbolicLink -Target ".condarc"
Set-SymbolicLink -Target ".config/starship.toml"
Set-SymbolicLink -Target ".dircolorsdb"
Set-SymbolicLink -Target ".gemrc"
Set-SymbolicLink -Target ".gitconfig"
Set-SymbolicLink -Target ".gitignore_global"
Set-SymbolicLink -Target ".gnupg/gpg-agent.conf"
Set-SymbolicLink -Target ".gnupg/gpg.conf"
Set-SymbolicLink -Target ".gradle/gradle.properties"
Set-SymbolicLink -Target ".gvimrc"
Set-SymbolicLink -Target ".inputrc"
Set-SymbolicLink -Target ".nanorc"
Set-SymbolicLink -Target ".npmrc"
Set-SymbolicLink -Target ".vimrc"

# Platform-specific dotfiles
if (!$IsWindows) {
    # PowerShell Core
    Set-SymbolicLink -Target ".config/powershell/profile.ps1"
} else {
    # MinTTY
    Set-SymbolicLink -Target ".minttyrc"
    # PowerShell Core
    Set-SymbolicLink -Target ".config/powershell/profile.ps1" `
        -Path "Documents/PowerShell/profile.ps1"
    # WindowsPowerShell 5.1
    Set-SymbolicLink -Target ".config/powershell/profile.ps1" `
        -Path "Documents/WindowsPowerShell/profile.ps1"
    Set-SymbolicLink -Target ".config/pshazz/config.json"
    Set-SymbolicLink -Target ".config/pshazz/themes/chawyehsu.json"
}
