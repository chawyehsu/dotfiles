# Install scoop
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')

# Install base packages
scoop install git-with-openssh pshazz concfg colortool curl hub

# Add bucket
scoop bucket add dorado https://github.com/h404bi/dorado

# Pour out configs
# colortool schemes
Push-Location "$env:USERPROFILE\scoop\persist\colortool\schemes"
curl -o https://raw.githubusercontent.com/chriskempson/base16-iterm2/master/base16-tomorrownight.dark.256.itermcolors
curl -o https://raw.githubusercontent.com/chriskempson/base16-iterm2/master/base16-tomorrownight.dark.itermcolors
Pop-Location

# Enable PowerShell colorscheme
colortool -b base16-tomorrownight.dark.256
