# Based on scripts from here:
# https://help.github.com/articles/working-with-ssh-key-passphrases#platform-windows
# https://github.com/dahlbyk/posh-sshell

# Note: the agent env file is for non win32-openssh (like, cygwin/msys openssh),
#       win32-openssh doesn't need this, it runs as system service.
$agentEnvFile = "$env:USERPROFILE/.ssh/agent.env.ps1"

function Import-AgentEnv() {
    if (Test-Path $agentEnvFile) {
        # Source the agent env file
        . $agentEnvFile | Out-Null
    }
}

# Retrieve the current SSH agent PID (or zero).
# Can be used to determine if there is a running agent.
function Get-SshAgent() {
    $agentPid = $env:SSH_AGENT_PID
    if ($agentPid) {
        $sshAgentProcess = Get-Process | Where-Object {
            ($_.Id -eq $agentPid) -and ($_.Name -eq 'ssh-agent')
        }
        if ($null -ne $sshAgentProcess) {
            return $agentPid
        }
        else {
            # Remove SSH_AGENT_PID and SSH_AUTH_SOCK which is unvalaible
            $env:SSH_AGENT_PID = $null
            $env:SSH_AUTH_SOCK = $null
            if (Test-Path $agentEnvFile) {
                Remove-Item $agentEnvFile
            }
        }
    }

    return 0
}

function Add-SshKey([switch]$Verbose) {
    # Check to see if any keys have been added. Only add keys if it's empty.
    (& ssh-add -l) | Out-Null
    if ($LASTEXITCODE -eq 0) {
        # Keys have already been added
        if ($Verbose) {
            Write-Host "Keys have already been added to the ssh agent."
        }
        return
    }

    # Run ssh-add, add the keys
    & ssh-add
}

function Test-Administrator {
    $currentUser = [Security.Principal.WindowsPrincipal]([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-NativeSshAgent() {
    # Only works on Windows. PowerShell < 6 must be Windows PowerShell,
    # $IsWindows is defined in PS Core.
    if (($PSVersionTable.PSVersion.Major -lt 6) -or $IsWindows) {
        # Native Windows ssh-agent service
        $service = Get-Service "ssh-agent" -ErrorAction Ignore
        # Native ssh.exe binary version must include "OpenSSH"
        $nativeSsh = Get-Command "ssh" -ErrorAction Ignore `
            | ForEach-Object FileVersionInfo `
            | Where-Object ProductVersion -match OpenSSH
        
        if ($nativeSsh) {
            if ($service) {
                return $service
            } else {
                Write-Error "You have Win32-OpenSSH binaries installed but missed the ssh-agent service. Please fix it."
                # Stop any other work.
                exit 1
            }
        }
    }
}

function Start-NativeSshAgent([switch]$Verbose) {
    $service = Get-NativeSshAgent

    if (!$service) {
        return $false
    }

    # Native ssh doesn't need agentEnvFile, remove it.
    if (Test-Path $agentEnvFile) {
        Remove-Item $agentEnvFile
    }

    # Enable the servivce if it's disabled and we're an admin
    if ($service.StartType -eq "Disabled") {
        if (Test-Administrator) {
            Set-Service "ssh-agent" -StartupType 'Manual'
        }
        else {
            Write-Error "The ssh-agent service is disabled. Please enable the service and try again."
            # Exit with true so Start-SshAgent doesn't try to do any other work.
            return $true
        }
    }

    # Start the service
    if ($service.Status -ne "Running") {
        if ($Verbose) {
            Write-Host "Starting ssh agent service."
        }
        Start-Service "ssh-agent"
    }

    Add-SshKey -Verbose:$Verbose

    return $true
}

function Start-SshAgent([switch]$Verbose) {
    # If we're using the native Open-SSH, we can just interact with the service directly.
    if (Start-NativeSshAgent -Verbose:$Verbose) {
        return
    }

    [int]$agentPid = Get-SshAgent
    if ($agentPid -gt 0) {
        if ($Verbose) {
            $agentName = Get-Process -Id $agentPid | Select-Object -ExpandProperty Name
            if (!$agentName) { $agentName = "SSH Agent" }
            Write-Host "$agentName is already running (pid $($agentPid))"
        }
        # Import ssh-agent envs
        Import-AgentEnv
        return
    }

    # Start ssh-agent and get output, then translate env to powershell
    & ssh-agent `
        -creplace '([A-Z_]+)=([^;]+).*', '$$env:$1="$2"' `
        -creplace 'echo ([^;]+);', '' `
        -creplace 'export ([^;]+);', '' `
        | Out-File -FilePath $agentEnvFile -Encoding ascii -Force
    # And then import the ssh-agent envs
    Import-AgentEnv

    Add-SshKey -Verbose:$Verbose
}

function Test-IsSshBinaryMissing([switch]$Verbose) {
    # ssh-add
    $sshAdd = Get-Command "ssh-add" -TotalCount 1 -ErrorAction SilentlyContinue
    if (!$sshAdd) {
        if ($Verbose) {
            Write-Warning 'Could not find ssh-add.'
        }
        return $true
    }

    # ssh-agent
    $sshAgent = Get-Command "ssh-agent" -TotalCount 1 -ErrorAction SilentlyContinue
    if (!$sshAgent) {
        if ($Verbose) {
            Write-Warning 'Could not find ssh-agent.'
        }
        return $true
    }
}

# pshazz plugin entry point
function pshazz:ssh:init {
    if (!(Test-Path "$env:USERPROFILE/.ssh")) {
        New-Item "$env:USERPROFILE/.ssh" -ItemType Directory | Out-Null
    }

    # Change it to $false to disable verbose output
    $Verbose = $true
    if (Test-IsSshBinaryMissing -Verbose:$Verbose) { return }
    Start-SshAgent -Verbose:$Verbose
}
