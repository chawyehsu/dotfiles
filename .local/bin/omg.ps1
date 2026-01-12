#Requires -Version 7
Set-StrictMode -Version 2.0

$NoColor = $args -like '--no-color'

function Format-Output {
    param(
        [Parameter(ValueFromPipeline=$true)]
        [string]$InputObject
    )

    begin {
        # Colors
        $C_RESET  = if ($NoColor) { "" } else { "`e[0m" }
        $C_BLACK  = if ($NoColor) { "" } else { "`e[30m" }
        $C_RED    = if ($NoColor) { "" } else { "`e[31m" }
        $C_GREEN  = if ($NoColor) { "" } else { "`e[32m" }
        $C_YELLOW = if ($NoColor) { "" } else { "`e[33m" }
        $C_BLUE   = if ($NoColor) { "" } else { "`e[34m" }
        $C_MAGENTA= if ($NoColor) { "" } else { "`e[35m" }
        $C_CYAN   = if ($NoColor) { "" } else { "`e[36m" }
        $C_WHITE  = if ($NoColor) { "" } else { "`e[37m" }
        $C_BRIGHT_BLACK  = if ($NoColor) { "" } else { "`e[90m" }
        $C_BRIGHT_RED    = if ($NoColor) { "" } else { "`e[91m" }
        $C_BRIGHT_GREEN  = if ($NoColor) { "" } else { "`e[92m" }
        $C_BRIGHT_YELLOW = if ($NoColor) { "" } else { "`e[93m" }
        $C_BRIGHT_BLUE   = if ($NoColor) { "" } else { "`e[94m" }
        $C_BRIGHT_MAGENTA= if ($NoColor) { "" } else { "`e[95m" }
        $C_BRIGHT_CYAN   = if ($NoColor) { "" } else { "`e[96m" }
        $C_BRIGHT_WHITE  = if ($NoColor) { "" } else { "`e[97m" }

        $C_GRAY  = $C_BRIGHT_BLACK
    }

    process {
        $line = $InputObject
        if ([string]::IsNullOrWhiteSpace($line)) { return }

        # 1. Indication of key status, [expired|expires|revoked: YYYY-MM-DD]
        if ($line -match "\[(expired|expires|revoked):\s+(\d{4}\-\d{2}\-\d{2})\]$") {
            $tag = $Matches[1]; $date = $Matches[2]
            $color = if ($tag -eq "revoked" -or $tag -eq "expired") {
                $C_RED
            } else {
                $now = Get-Date
                $expDate = Get-Date $date
                # yellow if expiring within 30 days, otherwise green
                if (($expDate - $now).Days -le 30) {
                    $C_YELLOW
                } else {
                    $C_GREEN
                }
            }
            $line = $line -replace "\[(expired|expires|revoked):\s+([\d\-]+)\]", "$color[$($tag): $date]$C_RESET"
        }

        # 2. Key Fingerprint
        if ($line -match "^(\s*)(Key fingerprint = )?([0-9A-F\s]+)$") {
            $lead = $Matches[2]
            $fp = $Matches[3]

            $out = "$($Matches[1])$C_GRAY$lead"

            # split into 2 parts with fpB to be last 20 chars
            $splitPoint = if ($fp.Length -gt 40) { 20 } else { 16 }
            $fpB = $fp.Substring($fp.Length - $splitPoint)
            $fpA = $fp.Substring(0, $fp.Length - $splitPoint)
            $out += "$C_GRAY$fpA$C_RESET$C_BLUE$fpB$C_RESET"
            $line = $out
        }
        # 3. `uid` line: "uid [never|revoked|expired|ultimate|full|marginal|unknown] Name <email>"
        elseif ($line -match "^uid(\s+)(\[\s?(never|revoked|expired|ultimate|full|marginal|unknown)\])?\s((.*)\s(<.*>)?)$") {
            $statusTag = $Matches[2]
            $statusKey = $Matches[3]
            $uidName = $Matches[5]
            $uidMail = $Matches[6]
            $out = "$($C_BRIGHT_WHITE)uid$C_RESET$($Matches[1])"
            if ($statusTag) {
                $sColor = switch ($statusKey) {
                    "never" { $C_BRIGHT_BLACK }
                    "revoked" { $C_RED }
                    "expired" { $C_RED }
                    "unknown" { $C_YELLOW }
                    "marginal" { $C_YELLOW }
                    "full" { $C_GREEN }
                    "ultimate" { $C_GREEN }
                    default { "" }
                }
                $out += "$sColor[Trust: $statusKey]$C_RESET "
            }
            $out += "$C_MAGENTA$uidName$C_RESET $C_CYAN$uidMail$C_RESET"
            $line = $out
        }
        # 4. `key` line: "<pub|sub|sec|ssb> <algostr>[/<keyid>] <creationdate> <[SCEA]> [expirationdate]"
        elseif ($line -match "^(pub|sub|sec|ssb[>#]?)(\s+)([^\s]+) (\d{4}\-\d{2}\-\d{2}) (\[[SCEA]+\])(.*)") {
            $type = $Matches[1]
            $lead = $Matches[2]
            $keyid = $Matches[3]
            $date = $Matches[4]
            $caps = $Matches[5]
            $extra = $Matches[6]

            $out = ""
            if ($type -eq "pub" -or $type -like "sec") { $out += "----------------------------------`n" }

            $out += "$C_CYAN$type$C_RESET$lead$C_BLUE$keyid$C_RESET $date$C_RESET "
            if ($caps) {
                $caps = $caps.Trim("[]")
                $annotatedCaps = "["
                foreach ($c in $caps.ToCharArray()) {
                    switch ($c) {
                        "S" { $annotatedCaps += "$($C_BRIGHT_YELLOW)S$($C_GRAY)igning$C_RESET" }
                        "C" { $annotatedCaps += "$($C_BRIGHT_YELLOW)C$($C_GRAY)ertify$C_RESET" }
                        "E" { $annotatedCaps += "$($C_BRIGHT_YELLOW)E$($C_GRAY)ncrypt$C_RESET" }
                        "A" { $annotatedCaps += "$($C_BRIGHT_YELLOW)A$($C_GRAY)uth$C_RESET" }
                        default { $annotatedCaps += "$c" }
                    }
                }
                $annotatedCaps += "]"
                $out += "$annotatedCaps"
            }
            $line = "$out$extra"
        }
        # 5. `sig` line: "sig[\s|!|-|%][check level][LRPNX] <sigid> <creationdate> <sig author"
        elseif ($line -match "^sig([\s|!|#|\-]\d?([\sLRPNX]+)?)?([^\s]+) (\d{4}\-\d{2}\-\d{2})\s+(.*)$") {
            $sigMark = $Matches[1]
            $sigId = $Matches[3]
            $sigDate = $Matches[4]
            $rest = $Matches[5]

            $cRest = if ($rest -match "\[self-signature\]") { $C_GRAY } else { "" }
            $out = "$($C_GRAY)sig$C_BRIGHT_YELLOW$sigMark$C_RESET$C_GRAY$sigId$C_RESET $sigDate$C_RESET $cRest$rest$C_RESET"
            $line = $out
        }

        $line
    }
}

if (-not [Boolean](Get-Command 'gpg' -ErrorAction SilentlyContinue)) {
    "Error: gpg command not found."
    exit 1
}

$command = $args[0]

if (-not $command -or $command -eq 'list') {
    & gpg --list-keys | Format-Output
} elseif ($command -eq 'sec') {
    & gpg --list-secret-keys | Format-Output
} elseif ($command -eq 'sigs') {
    & gpg --list-signatures | Format-Output
} else {
    "Oh my GPG! A handy tool to inspect gpg keys"
    ""
    "Usage: omg [subcommand] [options]"
    ""
    "Subcommands:"
    "    help          Show this help message"
    "    list          List public keys (default)"
    "    sec           List secret keys instead of public keys"
    "    sigs          List signatures instead of keys"
    "Options:"
    "    --no-color    Disable color output"
}
