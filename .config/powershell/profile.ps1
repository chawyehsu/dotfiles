#Requires -Version 5
# This profile is created by Chawye Hsu, licensed under the MIT license.
# NOTES: Save it with `UTF-8 with BOM` or it will break on PowerShell ISE.
#------------------------------------------------------------------------------#
# Support Platforms:
#     Windows: WindowsPowerShell 5.1 or PowerShell 6+
# macOS/Linux: PowerShell 6+ (PowerShell 7 is recommended)
#------------------------------------------------------------------------------#


#-----------------------#
#   Internal variables  #
#-----------------------#
# Define an UNIform $HOME variable in the scope of this script.
# $env:USERPROFILE goes first since $env:HOME might be defined in Windows.
$Script:UNI_HOME = $env:USERPROFILE, $env:HOME | Where-Object {
    -not [String]::IsNullOrEmpty($_) } | Select-Object -First 1


#-----------------------#
#   Internal functions  #
#-----------------------#
function Test-IsNotWindows {
    return ((Test-Path Variable:\IsWindows) -and (-not $IsWindows))
}
function Add-ItemToPath ([String]$part) {
    $spliter = if (Test-IsNotWindows) { ':' } else { ';' }
    $env:PATH = "$part$spliter$env:PATH"
}
function Get-NormalizedPath ([String]$in) {
    # from: https://stackoverflow.com/a/12605755/3651279
    $out = Resolve-Path $in -ErrorAction SilentlyContinue -ErrorVariable _errOut
    # Return the `resolved` inputPath even if it's not exist.
    if (-not $out) { $out = $_errOut[0].TargetObject }
    return $out
}
function Test-Command ([String]$command) {
    return [bool](Get-Command -Name $command `
            -CommandType Application -ErrorAction SilentlyContinue)
}
function Test-PathExist ([String]$part) {
    return ("$env:PATH".ToLower() -like "*$part*".ToLower())
}


#-----------------------#
# PowerShell PSReadLine #
#-----------------------#
# readline implementation for PowerShell:
#   https://github.com/PowerShell/PSReadLine
if ((Get-Module -Name 'PSReadline').Version.Major -eq 2) {
    # Enable Predictive IntelliSense (v2.1.0+)
    Set-PSReadLineOption -PredictionSource History
    # Command history search/completion
    Set-PSReadLineOption -HistorySearchCursorMovesToEnd
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key 'Ctrl+f' -Function ForwardWord
    # Copy selected text to clipboard
    Set-PSReadLineKeyHandler -Chord 'Ctrl+d,Ctrl+c' -Function CaptureScreen

    # Enable Predictive IntelliSense (requires PS7.1+ and PSReadLine v2.2.0+)
    if ((($PSVersionTable.PSVersion.Major -ge 7) -and
        ($PSVersionTable.PSVersion.Minor -ge 1)) -and
        ((Get-Module -Name 'PSReadline').Version.Minor -ge 2)) {
        Set-PSReadLineOption -PredictionSource HistoryAndPlugin
    }

    # CompletionPredictor (requires PS7.2+ and PSReadLine v2.2.2+)
    if ((($PSVersionTable.PSVersion.Major -ge 7) -and
        ($PSVersionTable.PSVersion.Minor -ge 2)) -and
        ((Get-Module -Name 'PSReadline').Version.Minor -ge 2) -and
        ((Get-Module -Name 'PSReadline').Version.Build -ge 2) -and
        (Get-Module -Name 'CompletionPredictor')) {
        Import-Module -Name CompletionPredictor
    }

    # Smart Quotes Insert/Delete
    # The next four key handlers are designed to make entering matched quotes
    # parens, and braces a nicer experience.  I'd like to include functions
    # in the module that do this, but this implementation still isn't as smart
    # as ReSharper, so I'm just providing it as a sample.
    Set-PSReadLineKeyHandler -Key '"', "'" `
        -BriefDescription SmartInsertQuote `
        -LongDescription 'Insert paired quotes if not already on a quote' `
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
        if ($selectionStart -ne -1) {
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

        function FindToken {
            param($tokens, $cursor)

            foreach ($token in $tokens) {
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
        if ($token -is [System.Management.Automation.Language.StringToken] -and
            $token.Kind -ne [System.Management.Automation.Language.TokenKind]::Generic) {
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
            $token.Kind -eq [System.Management.Automation.Language.TokenKind]::RParen -or
            $token.Kind -eq [System.Management.Automation.Language.TokenKind]::RCurly -or
            $token.Kind -eq [System.Management.Automation.Language.TokenKind]::RBracket) {
            if ($line[0..$cursor].Where{ $_ -eq $quote }.Count % 2 -eq 1) {
                # Odd number of quotes before the cursor, insert a single quote
                [Microsoft.PowerShell.PSConsoleReadLine]::Insert($quote)
            } else {
                # Insert matching quotes, move cursor to be in between the quotes
                [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$quote$quote")
                [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
            }
            return
        }

        if ($token.Extent.StartOffset -eq $cursor) {
            if ($token.Kind -eq [System.Management.Automation.Language.TokenKind]::Generic -or
                $token.Kind -eq [System.Management.Automation.Language.TokenKind]::Identifier -or
                $token.Kind -eq [System.Management.Automation.Language.TokenKind]::Variable -or
                $token.TokenFlags.hasFlag([TokenFlags]::Keyword)) {
                $end = $token.Extent.EndOffset
                $len = $end - $cursor
                [Microsoft.PowerShell.PSConsoleReadLine]::Replace($cursor, $len, $quote +
                    $line.SubString($cursor, $len) + $quote)
                [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($end + 2)
                return
            }
        }

        # We failed to be smart, so just insert a single quote
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert($quote)
    }
    Set-PSReadLineKeyHandler -Key '(', '{', '[' `
        -BriefDescription InsertPairedBraces `
        -LongDescription 'Insert matching braces' `
        -ScriptBlock {
        param($key, $arg)

        $closeChar = switch ($key.KeyChar) {
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

        if ($selectionStart -ne -1) {
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
    Set-PSReadLineKeyHandler -Key ')', ']', '}' `
        -BriefDescription SmartCloseBraces `
        -LongDescription 'Insert closing brace or skip' `
        -ScriptBlock {
        param($key, $arg)

        $line = $null
        $cursor = $null
        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

        if ($line[$cursor] -eq $key.KeyChar) {
            [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
        } else {
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$($key.KeyChar)")
        }
    }
    Set-PSReadLineKeyHandler -Key Backspace `
        -BriefDescription SmartBackspace `
        -LongDescription 'Delete previous character or matching quotes/parens/braces' `
        -ScriptBlock {
        param($key, $arg)

        $line = $null
        $cursor = $null
        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

        if ($cursor -gt 0) {
            $toMatch = $null
            if ($cursor -lt $line.Length) {
                switch ($line[$cursor]) {
                    <#case#> '"' { $toMatch = '"'; break }
                    <#case#> "'" { $toMatch = "'"; break }
                    <#case#> ')' { $toMatch = '('; break }
                    <#case#> ']' { $toMatch = '['; break }
                    <#case#> '}' { $toMatch = '{'; break }
                }
            }

            if ($toMatch -ne $null -and $line[$cursor - 1] -eq $toMatch) {
                [Microsoft.PowerShell.PSConsoleReadLine]::Delete($cursor - 1, 2)
            } else {
                [Microsoft.PowerShell.PSConsoleReadLine]::BackwardDeleteChar($key, $arg)
            }
        }
    }

    # Each time you press Alt+', this key handler will change the token
    # under or before the cursor.  It will cycle through single quotes,
    # double quotes, or no quotes each time it is invoked.
    Set-PSReadLineKeyHandler -Key "Alt+'" `
        -BriefDescription ToggleQuoteArgument `
        -LongDescription 'Toggle quotes on the argument under the cursor' `
        -ScriptBlock {
        param($key, $arg)

        $ast = $null
        $tokens = $null
        $errors = $null
        $cursor = $null
        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState(`
                [ref]$ast, [ref]$tokens, [ref]$errors, [ref]$cursor)

        $tokenToChange = $null
        foreach ($token in $tokens) {
            $extent = $token.Extent
            if ($extent.StartOffset -le $cursor -and
                $extent.EndOffset -ge $cursor) {
                $tokenToChange = $token

                # If the cursor is at the end (it's really 1 past the end) of
                # the previous token, we only want to change the previous token
                # if there is no token under the cursor
                if ($extent.EndOffset -eq $cursor -and $foreach.MoveNext()) {
                    $nextToken = $foreach.Current
                    if ($nextToken.Extent.StartOffset -eq $cursor) {
                        $tokenToChange = $nextToken
                    }
                }
                break
            }
        }

        if ($tokenToChange -ne $null) {
            $extent = $tokenToChange.Extent
            $tokenText = $extent.Text
            if ($tokenText[0] -eq '"' -and $tokenText[-1] -eq '"') {
                # Switch to no quotes
                $replacement = $tokenText.Substring(1, $tokenText.Length - 2)
            } elseif ($tokenText[0] -eq "'" -and $tokenText[-1] -eq "'") {
                # Switch to double quotes
                $replacement = '"' + $tokenText.Substring(1, $tokenText.Length - 2) + '"'
            } else {
                # Add single quotes
                $replacement = "'" + $tokenText + "'"
            }

            [Microsoft.PowerShell.PSConsoleReadLine]::Replace(
                $extent.StartOffset,
                $tokenText.Length,
                $replacement)
        }
    }
}


#--------------------------#
#   Environment Variables  #
#--------------------------#
$env:LANG = 'en_US.UTF-8'
$env:TZ = 'UTC-8'
# default editor
$env:EDITOR = 'nano'
# Rustup mirror
$env:RUSTUP_DIST_SERVER = 'https://mirrors.ustc.edu.cn/rust-static'
# Node.js COLOR
$env:FORCE_COLOR = 'true'
# Show git dirty state
$env:GIT_PS1_SHOWDIRTYSTATE = 1
# GitHub CLI config dir
$env:GH_CONFIG_DIR = "$Script:UNI_HOME/.config/gh"
# PATH updates
& {
    # .local bin
    $localBinPath = Get-NormalizedPath "$Script:UNI_HOME/.local/bin"
    if ($localBinPath -and (-not (Test-PathExist $localBinPath))) {
        Add-ItemToPath $localBinPath
    }
    # cargo bin
    $cargoHome = $env:CARGO_HOME, "$Script:UNI_HOME/.cargo" | Where-Object {
        -not [String]::IsNullOrEmpty($_) } | Select-Object -First 1
    $cargoPath = Get-NormalizedPath "$cargoHome/bin"
    if ($cargoPath -and (-not (Test-PathExist $cargoPath))) {
        Add-ItemToPath $cargoPath
    }
    # deno bin
    $denoBinPath = Get-NormalizedPath "$Script:UNI_HOME/.deno/bin"
    if ($denoBinPath -and (-not (Test-PathExist $denoBinPath))) {
        Add-ItemToPath $denoBinPath
    }
}
# LS_COLORS generated by [vivid](https://github.com/sharkdp/vivid)
& {
    if (Test-Command 'vivid') {
        $env:LS_COLORS = $(vivid -m 8-bit generate snazzy)
    }
}


#-----------------------#
#   PowerShell Aliases  #
#-----------------------#
# Git Alias
function Get-GitDiff { git diff }
function Get-GitStatus { git status }
Set-Alias -Name 'gdf' -Value Get-GitDiff -Option AllScope
Set-Alias -Name 'gst' -Value Get-GitStatus -Option AllScope
Set-Alias -Name 'c' -Value 'cls' -Option AllScope
# Efficient helper
# Get WAN ip
function Get-WanIp {
    param([Switch]$g)
    if (!$g) {
        return Invoke-RestMethod https://api.myip.la
    }
    (Invoke-RestMethod https://api.myip.la/en?json) | ConvertTo-Json
}
Set-Alias -Name 'wanip' -Value Get-WanIp -Option AllScope
# Quick terminal->explorer
# Detect platforms and specific explorer tool
$nativeOpenCommand = if ($IsMacOS) { 'open' } elseif ($IsLinux) { 'nautilus' } else { 'explorer' }
function Open-Here { & $nativeOpenCommand $(Get-Location) }
if (!(Test-Command 'open')) {
    Set-Alias -Name 'open' -Value $nativeOpenCommand -Option AllScope
}
Set-Alias -Name 'here' -Value Open-Here -Option AllScope

# Show all environment variables, like `export`
function Get-AllEnv { Get-ChildItem env: }
Set-Alias -Name 'export' -Value Get-AllEnv -Option AllScope


#-------------------------------#
#   Platform-specific Settings  #
#-------------------------------#
if (Test-IsNotWindows) {
    # gpg requires this to display passphrase prompt
    $env:GPG_TTY = $(tty)

    if ($env:NAME) {
        $env:NAME = $env:NAME.Substring(0, 1).ToUpper() + $env:NAME.Substring(1).ToLower()
    }

    function Get-ChildItemWithLs {
        # Find available ls executable
        $lsCmd = @('gls', '/bin/ls') | Where-Object {
            Get-Command -Name "$_" `
                -CommandType Application `
                -ErrorAction SilentlyContinue
        } | Select-Object -First 1
        # Call ls command
        if (($lsCmd -eq '/bin/ls') -and $IsMacOS) {
            # BSD/macOS ls
            & $lsCmd -F -G $args
        } else {
            # GNU ls
            & $lsCmd -F --group-directories-first --color $args
        }
    }
    function Get-ChildItemWithLl { Get-ChildItemWithLs -lh $args }
    function Get-ChildItemWithLa { Get-ChildItemWithLs -lAh $args }
    # ls aliases
    Set-Alias -Name 'l' -Value Get-ChildItemWithLs -Option AllScope
    Set-Alias -Name 'ls' -Value Get-ChildItemWithLs -Option AllScope
    Set-Alias -Name 'la' -Value Get-ChildItemWithLa -Option AllScope
    Set-Alias -Name 'll' -Value Get-ChildItemWithLl -Option AllScope

    # Anaconda/Miniconda - https://docs.conda.io/en/latest
    if (Test-Command 'conda') {
        (& conda 'shell.powershell' 'hook') | Out-String | Invoke-Expression
    }

    # starship - https://github.com/starship/starship
    if (Test-Command 'starship') {
        (& starship 'init' 'powershell') | Out-String | Invoke-Expression
    }
} else {
    $env:COMPUTERNAME = $env:COMPUTERNAME.Substring(0, 1).ToUpper() + $env:COMPUTERNAME.Substring(1).ToLower()
    # Define Scoop home
    $SCOOP_HOME = "$Script:UNI_HOME\scoop"

    # Replace Windows PowerShell `ls` command with GNU `ls` command,
    # it's bundled with git-for-windows, installed via Scoop
    function Get-ChildItemWithLs {
        # Ignore some files that I don't want to see when calling ls command
        $lsIgnore = '"{0}"' -f (@(
                '_viminfo', 'navdb.csv', 'NTUSER*', 'ntuser*', 'Application Data*',
                'Local Settings*', 'My Documents*', 'NetHood*', 'PrintHood*',
                'Recent*', 'SendTo*', 'Templates*', 'Cookies*', 'iCloudDrive*',
                'desktop.ini', 'Thumbs.db', 'Start Menu', 'Saved Games',
                'Creative Cloud Files', '3D Objects'
            ) -join '","')
        # Find available ls executable
        $lsExe = @(
            "$SCOOP_HOME\apps\git\current\usr\bin\ls.exe",
            "$SCOOP_HOME\apps\git-with-openssh\current\usr\bin\ls.exe"
        ) | Where-Object { Test-Path $_ } | Select-Object -First 1

        # Call ls command
        & $lsExe -F --group-directories-first --color --ignore="{$lsIgnore}" $args
    }
    function Get-ChildItemWithLl { Get-ChildItemWithLs -lh $args }
    function Get-ChildItemWithLa { Get-ChildItemWithLs -lAh $args }
    # ls aliases
    Set-Alias -Name 'l' -Value Get-ChildItemWithLs -Option AllScope
    Set-Alias -Name 'ls' -Value Get-ChildItemWithLs -Option AllScope
    Set-Alias -Name 'la' -Value Get-ChildItemWithLa -Option AllScope
    # pshazz force setting `ll` as an alias of `ls`, disable pshazz aliases
    # plugin to avoid this behavior
    Set-Alias -Name 'll' -Value Get-ChildItemWithLl -Option AllScope

    #---------------------------------------------#
    #    External Applications Tab-Completions    #
    #---------------------------------------------#
    # Anaconda/Miniconda - https://docs.conda.io/en/latest
    #  NOTES: This must be loaded before `pshazz`, since it also changes prompt
    if (Test-Command 'conda') {
        (& conda 'shell.powershell' 'hook') | Out-String | Invoke-Expression
    }
    # WinGet
    if (Test-Command 'winget') {
        Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
            param($wordToComplete, $commandAst, $cursorPosition)
            [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
            $Local:word = $wordToComplete.Replace('"', '""')
            $Local:ast = $commandAst.ToString().Replace('"', '""')
            winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
                [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
            }
        }
    }
    # Scoop - https://github.com/Moeologist/scoop-completion
    if (Test-Path "$SCOOP_HOME\modules\scoop-completion") {
        Import-Module "$SCOOP_HOME\modules\scoop-completion"
    }

    #-----------------------#
    #    Prompt & Styles    #
    #-----------------------#
    # pshazz - https://github.com/lukesampson/pshazz
    if (Test-Command 'pshazz') {
        pshazz init
    }
    # starship - https://github.com/starship/starship (Windows Terminal only)
    if ($env:WT_SESSION -and
        (Test-Command 'starship.exe')) {
        (& starship.exe 'init' 'powershell') | Out-String | Invoke-Expression
    }
    # concfg - https://github.com/lukesampson/concfg
    if (Test-Command 'concfg') {
        concfg tokencolor -n enable
    }
}

if (Test-Command 'zoxide') {
    Invoke-Expression (& {
            $hook = if ($PSVersionTable.PSVersion.Major -lt 6) { 'prompt' } else { 'pwd' }
            (zoxide init --hook $hook powershell) -join "`n"
        })
    # Overwrite `cd` with `z`
    Set-Alias -Name 'cd' -Value 'z' -Option AllScope
}


#------------------------------#
#   CLI tools tab-completions  #
#------------------------------#
@('k3d') | ForEach-Object {
    if (Test-Command $_) {
        (& $_ 'completion' 'powershell') | Out-String | Invoke-Expression
    }
}
@('gh') | ForEach-Object {
    if (Test-Command $_) {
        (& $_ 'completion' '-s' 'powershell') | Out-String | Invoke-Expression
    }
}
# Tab-completions autoload for tools written in Rust(clap-rs)
@('rustup', 'deno', 'volta', 'starship') | ForEach-Object {
    if (Test-Command $_) {
        (& $_ 'completions' 'powershell') | Out-String | Invoke-Expression
    }
}
