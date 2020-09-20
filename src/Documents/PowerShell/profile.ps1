#Requires -Version 5
# NOTES: Save it with `UTF-8 with BOM` or it will fail in PowerShell ISE


#-----------------------#
# Environment Variables #
#-----------------------#
# Define Scoop home
$SCOOP_HOME = "$env:USERPROFILE\scoop"
# Change hostname format
$env:COMPUTERNAME = $env:COMPUTERNAME.Substring(0,1).ToUpper() + $env:COMPUTERNAME.Substring(1).ToLower()
$env:LANG = "en_US.UTF-8"
$env:TZ = "UTC-8"
# Rustup mirror
$env:RUSTUP_DIST_SERVER = "https://mirrors.ustc.edu.cn/rust-static"
# Node.js COLOR
$env:FORCE_COLOR = "true"
# Show git dirty state
$env:GIT_PS1_SHOWDIRTYSTATE = 1
# pipenv exports
$env:PIPENV_DEFAULT_PYTHON_VERSION = 3
$env:PIPENV_SHELL_FANCY = 1
# dircolorsdb
$env:LS_COLORS = "no=00:fi=00:di=36:ln=35:pi=30;44:so=35;44:do=35;44:bd=33;44:cd=37;44:or=05;37;41:mi=05;37;41:ex=01;31:*.cmd=01;31:*.exe=01;31:*.com=01;31:*.bat=01;31:*.reg=01;31:*.app=01;31:*.txt=32:*.org=32:*.md=32:*.mkd=32:*.bib=32:*.h=32:*.hpp=32:*.c=32:*.C=32:*.cc=32:*.cpp=32:*.cxx=32:*.objc=32:*.cl=32:*.sh=32:*.bash=32:*.csh=32:*.zsh=32:*.el=32:*.vim=32:*.java=32:*.pl=32:*.pm=32:*.py=32:*.rb=32:*.hs=32:*.php=32:*.htm=32:*.html=32:*.shtml=32:*.erb=32:*.haml=32:*.xml=32:*.rdf=32:*.css=32:*.sass=32:*.scss=32:*.less=32:*.js=32:*.coffee=32:*.man=32:*.0=32:*.1=32:*.2=32:*.3=32:*.4=32:*.5=32:*.6=32:*.7=32:*.8=32:*.9=32:*.l=32:*.n=32:*.p=32:*.pod=32:*.tex=32:*.go=32:*.sql=32:*.csv=32:*.sv=32:*.svh=32:*.v=32:*.vh=32:*.vhd=32:*.bmp=33:*.cgm=33:*.dl=33:*.dvi=33:*.emf=33:*.eps=33:*.gif=33:*.jpeg=33:*.jpg=33:*.JPG=33:*.mng=33:*.pbm=33:*.pcx=33:*.pdf=33:*.pgm=33:*.png=33:*.PNG=33:*.ppm=33:*.pps=33:*.ppsx=33:*.ps=33:*.svg=33:*.svgz=33:*.tga=33:*.tif=33:*.tiff=33:*.xbm=33:*.xcf=33:*.xpm=33:*.xwd=33:*.xwd=33:*.yuv=33:*.NEF=33:*.nef=33:*.aac=33:*.au=33:*.flac=33:*.m4a=33:*.mid=33:*.midi=33:*.mka=33:*.mp3=33:*.mpa=33:*.mpeg=33:*.mpg=33:*.ogg=33:*.opus=33:*.ra=33:*.wav=33:*.anx=33:*.asf=33:*.avi=33:*.axv=33:*.flc=33:*.fli=33:*.flv=33:*.gl=33:*.m2v=33:*.m4v=33:*.mkv=33:*.mov=33:*.MOV=33:*.mp4=33:*.mp4v=33:*.mpeg=33:*.mpg=33:*.nuv=33:*.ogm=33:*.ogv=33:*.ogx=33:*.qt=33:*.rm=33:*.rmvb=33:*.swf=33:*.vob=33:*.webm=33:*.wmv=33:*.doc=31:*.docx=31:*.rtf=31:*.odt=31:*.dot=31:*.dotx=31:*.ott=31:*.xls=31:*.xlsx=31:*.ods=31:*.ots=31:*.ppt=31:*.pptx=31:*.odp=31:*.otp=31:*.fla=31:*.psd=31:*.7z=1;35:*.apk=1;35:*.arj=1;35:*.bin=1;35:*.bz=1;35:*.bz2=1;35:*.cab=1;35:*.deb=1;35:*.dmg=1;35:*.gem=1;35:*.gz=1;35:*.iso=1;35:*.jar=1;35:*.msi=1;35:*.rar=1;35:*.rpm=1;35:*.tar=1;35:*.tbz=1;35:*.tbz2=1;35:*.tgz=1;35:*.tx=1;35:*.war=1;35:*.xpi=1;35:*.xz=1;35:*.z=1;35:*.Z=1;35:*.zip=1;35:*.zst=1;35:*.ANSI-30-black=30:*.ANSI-01;30-brblack=01;30:*.ANSI-31-red=31:*.ANSI-01;31-brred=01;31:*.ANSI-32-green=32:*.ANSI-01;32-brgreen=01;32:*.ANSI-33-yellow=33:*.ANSI-01;33-bryellow=01;33:*.ANSI-34-blue=34:*.ANSI-01;34-brblue=01;34:*.ANSI-35-magenta=35:*.ANSI-01;35-brmagenta=01;35:*.ANSI-36-cyan=36:*.ANSI-01;36-brcyan=01;36:*.ANSI-37-white=37:*.ANSI-01;37-brwhite=01;37:*.log=01;32:*~=01;32:*#=01;32:*.bak=01;36:*.BAK=01;36:*.old=01;36:*.OLD=01;36:*.org_archive=01;36:*.off=01;36:*.OFF=01;36:*.dist=01;36:*.DIST=01;36:*.orig=01;36:*.ORIG=01;36:*.swp=01;36:*.swo=01;36:*.v=01;36:*.gpg=34:*.gpg=34:*.pgp=34:*.asc=34:*.3des=34:*.aes=34:*.enc=34:*.sqlite=34:*.db=34:"


#-----------------------#
#   PowerShell Aliases  #
#-----------------------#
# Remove built-in curl alias
if (Test-Path Alias:curl) { Remove-Item Alias:curl }
# Override ls with GNU ls
function Get-ChildItemGLS {
    # GNU ls ignore list
    $ls_ignore = '"{0}"' -f (@(
        "_viminfo", "navdb.csv", "NTUSER*", "ntuser*", "Application Data*",
        "Local Settings*", "My Documents*", "NetHood*", "PrintHood*",
        "Recent*", "SendTo*", "Templates*", "Cookies*", "iCloudDrive*",
        "desktop.ini", "Thumbs.db", "Start Menu", "「开始」菜单"
    ) -join '","')
    # Find available ls executable
    $ls1 = "$SCOOP_HOME\apps\git\current\usr\bin\ls.exe"
    $ls2 = "$SCOOP_HOME\apps\git-with-openssh\current\usr\bin\ls.exe"
    $ls_exec = $ls1, $ls2 | Where-Object { Test-Path $_ } | Select-Object -First 1

    & $ls_exec -F --show-control-chars --color=auto --ignore="{$ls_ignore}" $args
}
function Get-ChildItemGLSLA { Get-ChildItemGLS -A $args }
function Get-ChildItemGLSLL { Get-ChildItemGLS -lh $args }
function Get-ChildItemGLSLLA { Get-ChildItemGLS -lhA $args }
Set-Alias -Name "l" -Value Get-ChildItemGLS -Option AllScope
Set-Alias -Name "ls" -Value Get-ChildItemGLS -Option AllScope
Set-Alias -Name "la" -Value Get-ChildItemGLSLA -Option AllScope
Set-Alias -Name "ll" -Value Get-ChildItemGLSLL -Option AllScope
Set-Alias -Name "lla" -Value Get-ChildItemGLSLLA -Option AllScope
# Git Alias
function Get-GitDiff { git diff }
function Get-GitStatus { git status }
Set-Alias -Name "gdf" -Value Get-GitDiff -Option AllScope
Set-Alias -Name "gst" -Value Get-GitStatus -Option AllScope
# Efficient helper
Set-Alias -Name "c" -Value "cls" -Option AllScope
function Get-WanIp {
    (Invoke-WebRequest -UseBasicParsing https://api.ip.sb/ip).Content
}
Set-Alias -Name "myip" -Value Get-WanIp -Option AllScope
# Explorer helper, quick terminal->explorer
function Open-Here { explorer.exe . }
Set-Alias -Name "open" -Value explorer.exe -Option AllScope
Set-Alias -Name "here" -Value Open-Here -Option AllScope
# Show all environment variables, like `export`
function Get-AllEnv { Get-ChildItem env: }
Set-Alias -Name "export" -Value Get-AllEnv -Option AllScope


#-----------------------#
# PowerShell PSReadLine #
#-----------------------#
# PSReadLine - https://github.com/lzybkr/PSReadLine
if (Get-Module -Name "PSReadline") {
    # Command history search/completion
    Set-PSReadLineOption -HistorySearchCursorMovesToEnd
    Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
    Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward
    Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key "Ctrl+f" -Function ForwardWord
    # Copy selected text to clipboard
    Set-PSReadLineKeyHandler -Chord "Ctrl+d,Ctrl+c" -Function CaptureScreen
}


#-----------------------#
#    Tab Completions    #
#-----------------------#
# Anaconda/Miniconda - https://docs.conda.io/en/latest
#  NOTES: This must be loaded before `pshazz`, since it also changes prompt
if ([bool](Get-Command -Name "conda.exe" -ErrorAction SilentlyContinue)) {
    (& conda.exe "shell.powershell" "hook") | Out-String | Invoke-Expression
}
# Rustup - https://rustup.rs
if ([bool](Get-Command -Name "rustup.exe" -ErrorAction SilentlyContinue)) {
    (& rustup.exe "completions" "powershell") | Out-String | Invoke-Expression
}
# Volta - https://volta.sh
if ([bool](Get-Command -Name "volta.exe" -ErrorAction SilentlyContinue)) {
    (& volta.exe "completions" "powershell") | Out-String | Invoke-Expression
}
# scoop-completion - https://github.com/Moeologist/scoop-completion
if (Test-Path "$SCOOP_HOME\modules\scoop-completion") {
    Import-Module "$SCOOP_HOME\modules\scoop-completion"
}


#-----------------------#
#    Prompt & Styles    #
#-----------------------#
# pshazz - https://github.com/lukesampson/pshazz
if ([bool](Get-Command -Name "pshazz" -ErrorAction SilentlyContinue)) {
    pshazz init
}
# starship - https://github.com/starship/starship (in Windows Terminal only)
if ($env:WT_SESSION -and [bool](Get-Command -Name "starship.exe" -ErrorAction SilentlyContinue)) {
    (& starship.exe "init" "powershell") | Out-String | Invoke-Expression
}
# concfg - https://github.com/lukesampson/concfg
if ([bool](Get-Command -Name "concfg" -ErrorAction SilentlyContinue)) {
    concfg tokencolor -n enable
}


#-----------------------#
#  Smart Insert/Delete  #
#-----------------------#
# The next four key handlers are designed to make entering matched quotes
# parens, and braces a nicer experience.  I'd like to include functions
# in the module that do this, but this implementation still isn't as smart
# as ReSharper, so I'm just providing it as a sample.
Set-PSReadLineKeyHandler -Key '"',"'" `
                         -BriefDescription SmartInsertQuote `
                         -LongDescription "Insert paired quotes if not already on a quote" `
                         -ScriptBlock {
    param($key, $arg)

    $quote = $key.KeyChar

    $selectionStart = $null
    $selectionLength = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetSelectionState(`
        [ref]$selectionStart, [ref]$selectionLength)

    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState(`
        [ref]$line, [ref]$cursor)

    # If text is selected, just quote it without any smarts
    if ($selectionStart -ne -1)
    {
        [Microsoft.PowerShell.PSConsoleReadLine]::Replace(`
            $selectionStart, $selectionLength, $quote +
            $line.SubString($selectionStart, $selectionLength) + $quote)
        [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition(`
            $selectionStart + $selectionLength + 2)
        return
    }

    $ast = $null
    $tokens = $null
    $parseErrors = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState(`
        [ref]$ast, [ref]$tokens, [ref]$parseErrors, [ref]$null)

    function FindToken
    {
        param($tokens, $cursor)

        foreach ($token in $tokens)
        {
            if ($cursor -lt $token.Extent.StartOffset) { continue }
            if ($cursor -lt $token.Extent.EndOffset) {
                $result = $token
                $token = $token -as [System.Management.Automation.Language.StringExpandableToken]
                if ($token) {
                    $nested = FindToken $token.NestedTokens $cursor
                    if ($nested) { $result = $nested }
                }

                return $result
            }
        }
        return $null
    }

    $token = FindToken $tokens $cursor

    # If we're on or inside a **quoted** string token (so not generic), we need to be smarter
    if ($token -is [System.Management.Automation.Language.StringToken] -and $token.Kind -ne [System.Management.Automation.Language.TokenKind]::Generic) {
        # If we're at the start of the string, assume we're inserting a new string
        if ($token.Extent.StartOffset -eq $cursor) {
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$quote$quote ")
            [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
            return
        }

        # If we're at the end of the string, move over the closing quote if present.
        if ($token.Extent.EndOffset -eq ($cursor + 1) -and $line[$cursor] -eq $quote) {
            [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
            return
        }
    }

    if ($null -eq $token -or
        $token.Kind -eq [System.Management.Automation.Language.TokenKind]::RParen -or $token.Kind -eq [System.Management.Automation.Language.TokenKind]::RCurly -or $token.Kind -eq [System.Management.Automation.Language.TokenKind]::RBracket) {
        if ($line[0..$cursor].Where{$_ -eq $quote}.Count % 2 -eq 1) {
            # Odd number of quotes before the cursor, insert a single quote
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert($quote)
        }
        else {
            # Insert matching quotes, move cursor to be in between the quotes
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$quote$quote")
            [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
        }
        return
    }

    if ($token.Extent.StartOffset -eq $cursor) {
        if ($token.Kind -eq [System.Management.Automation.Language.TokenKind]::Generic -or $token.Kind -eq [System.Management.Automation.Language.TokenKind]::Identifier -or
            $token.Kind -eq [System.Management.Automation.Language.TokenKind]::Variable -or $token.TokenFlags.hasFlag([TokenFlags]::Keyword)) {
            $end = $token.Extent.EndOffset
            $len = $end - $cursor
            [Microsoft.PowerShell.PSConsoleReadLine]::Replace($cursor, $len, $quote + $line.SubString($cursor, $len) + $quote)
            [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($end + 2)
            return
        }
    }

    # We failed to be smart, so just insert a single quote
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert($quote)
}

Set-PSReadLineKeyHandler -Key '(','{','[' `
                         -BriefDescription InsertPairedBraces `
                         -LongDescription "Insert matching braces" `
                         -ScriptBlock {
    param($key, $arg)

    $closeChar = switch ($key.KeyChar)
    {
        <#case#> '(' { [char]')'; break }
        <#case#> '{' { [char]'}'; break }
        <#case#> '[' { [char]']'; break }
    }

    $selectionStart = $null
    $selectionLength = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetSelectionState(`
        [ref]$selectionStart, [ref]$selectionLength)

    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState(`
        [ref]$line, [ref]$cursor)

    if ($selectionStart -ne -1)
    {
      # Text is selected, wrap it in brackets
      [Microsoft.PowerShell.PSConsoleReadLine]::Replace(`
        $selectionStart, $selectionLength, $key.KeyChar +
        $line.SubString($selectionStart, $selectionLength) + $closeChar)
      [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition(`
        $selectionStart + $selectionLength + 2)
    } else {
      # No text is selected, insert a pair
      [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$($key.KeyChar)$closeChar")
      [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
    }
}

Set-PSReadLineKeyHandler -Key ')',']','}' `
                         -BriefDescription SmartCloseBraces `
                         -LongDescription "Insert closing brace or skip" `
                         -ScriptBlock {
    param($key, $arg)

    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

    if ($line[$cursor] -eq $key.KeyChar)
    {
        [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
    }
    else
    {
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$($key.KeyChar)")
    }
}

Set-PSReadLineKeyHandler -Key Backspace `
                         -BriefDescription SmartBackspace `
                         -LongDescription "Delete previous character or matching quotes/parens/braces" `
                         -ScriptBlock {
    param($key, $arg)

    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

    if ($cursor -gt 0)
    {
        $toMatch = $null
        if ($cursor -lt $line.Length)
        {
            switch ($line[$cursor])
            {
                <#case#> '"' { $toMatch = '"'; break }
                <#case#> "'" { $toMatch = "'"; break }
                <#case#> ')' { $toMatch = '('; break }
                <#case#> ']' { $toMatch = '['; break }
                <#case#> '}' { $toMatch = '{'; break }
            }
        }

        if ($toMatch -ne $null -and $line[$cursor-1] -eq $toMatch)
        {
            [Microsoft.PowerShell.PSConsoleReadLine]::Delete($cursor - 1, 2)
        }
        else
        {
            [Microsoft.PowerShell.PSConsoleReadLine]::BackwardDeleteChar($key, $arg)
        }
    }
}
