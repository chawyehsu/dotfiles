# based on script from here:
# https://help.github.com/articles/working-with-ssh-key-passphrases#platform-windows

# Note: $env:USERPROFILE/.ssh/environment should not be used, as it
#       already has a different purpose in SSH.
$envfile = "$env:USERPROFILE/.ssh/agent.env.ps1"

try { Get-Command ssh-agent -ea stop > $null } catch { return }

# Note: Don't bother checking SSH_AGENT_PID. It's not used
#       by SSH itself, and it might even be incorrect
#       (for example, when using agent-forwarding over SSH).
function agent_is_running () {
    if ($env:SSH_AUTH_SOCK) {
        # ssh-add returns:
        #   0 = agent running, has keys
        #   1 = agent running, no keys
        #   2 = agent not running
        ssh-add -l 2>&1 > $null; $lastexitcode -ne 2
    } else {
        $false
    }
}

function agent_has_keys () {
    ssh-add -l 2>&1 > $null; $lastexitcode -eq 0
}

function agent_load_env () {
    if (Test-Path $envfile) { . $envfile > $null }
}

function agent_start () {
    # translate bash script to powershell
    $output = ssh-agent `
        -creplace '([A-Z_]+)=([^;]+).*', '$$env:$1="$2"' `
        -creplace 'echo ([^;]+);', 'Write-Output "$1"' `
        -creplace 'export ([^;]+);', '' `
        -creplace '/tmp/', '$env:TEMP\' `
        -creplace '/', '\'

    $output > $envfile
    . $envfile > $null
}

# pshazz plugin entry point
function pshazz:ssh:init {
    if (!(Test-Path "$env:USERPROFILE/.ssh")) {
        mkdir "$env:USERPROFILE/.ssh" > $null
    }

    agent_load_env

    if (!(agent_is_running)) {
        # Removing old ssh-agent sockets
        Get-ChildItem "$env:TEMP/ssh-??????*" | ForEach-Object {
            Remove-Item $_ -ErrorAction Stop -Recurse -Force
        }
        agent_start
        ssh-add
    } elseif (!(agent_has_keys)) {
        ssh-add
    }
}
