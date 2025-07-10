#Requires -Version 7
#Requires -RunAsAdministrator

<#
.SYNOPSIS
    清理 Windows 防火墙规则，删除无效的规则。
.DESCRIPTION
    该脚本会检查所有已启用的防火墙规则，测试应用程序路径是否有效以删除无效路径的规则，并检测重复的规则。
.PARAMETER Dedup
    可选参数，启用后将检查重复的防火墙规则，但不会删除它们。

    实验性功能
#>
param(
    [Parameter(Mandatory = $false)]
    [switch]$Dedup
)

Set-StrictMode -Version Latest

if (-not $IsWindows) {
    Write-Error "此脚本只能在 Windows 上运行。"
    exit 1
}

# 创建一个哈希表用于去重
$ruleHash = @{}

# 获取所有已启用的防火墙规则
$rules = Get-NetFirewallRule | Where-Object { $_.Enabled -eq "True" }

foreach ($rule in $rules) {
    $apps = Get-NetFirewallApplicationFilter -AssociatedNetFirewallRule $rule
    $ports = Get-NetFirewallPortFilter -AssociatedNetFirewallRule $rule

    foreach ($app in $apps) {
        $path = $app.Program
        $expandedPath = if (![string]::IsNullOrWhiteSpace($path)) { [Environment]::ExpandEnvironmentVariables($path) } else { "" }

        # ----- 检查无效路径 -----
        if ($expandedPath -like "C:\users\*" -or $expandedPath -like "C:\Program Files*") {
            if (-not (Test-Path $expandedPath)) {
                Remove-NetFirewallRule -Name $rule.Name

                Write-Output "❌ 无效规则：$($rule.DisplayName) - $($app.Program) [已被删除]"
                continue
            }
        }

        if ($Dedup) {
            # ----- 构造唯一键以检测重复 -----
            $key = "$($rule.DisplayName)-$($rule.Name)-$($rule.Direction)-$($rule.Action)-$expandedPath-$($ports.Protocol)-$($ports.LocalPort)-$($ports.RemotePort)-$($rule.Profile)-$($rule.Group)"

            if ($ruleHash.ContainsKey($key)) {
                Write-Output "🔁 重复规则：$($rule.DisplayName) → 与 $($ruleHash[$key]) 重复"


                # 删除规则（取消注释启用）
                # Remove-NetFirewallRule -Name $rule.Name
            } else {
                $ruleHash[$key] = $rule.DisplayName
            }
        }
    }
}
