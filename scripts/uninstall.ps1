#Requires -Version 5.1
<#
.SYNOPSIS
    Removes WinMacKeys: stops the process, deletes the Scheduled Task and the
    installed files. The user config is kept unless -RemoveConfig is given.

.PARAMETER RemoveConfig
    Also delete %APPDATA%\WinMacKeys (your config.ini).

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File scripts\uninstall.ps1
#>
[CmdletBinding()]
param(
    [switch]$RemoveConfig,
    [string]$InstallDir = (Join-Path $env:LOCALAPPDATA 'Programs\WinMacKeys')
)

$ErrorActionPreference = 'Stop'
$AppName  = 'WinMacKeys'
$TaskName = 'WinMacKeys'

function Write-Step($msg) { Write-Host "==> $msg" -ForegroundColor Cyan }
function Write-Ok($msg)   { Write-Host "    $msg" -ForegroundColor Green }

function Test-Admin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    (New-Object Security.Principal.WindowsPrincipal($id)).IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator)
}

# ---- Remove the Scheduled Task (needs admin) -------------------------------
$task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
if ($task) {
    if (-not (Test-Admin)) {
        Write-Step 'Removing the logon task requires administrator rights (one UAC prompt)...'
        $argList = @('-NoProfile','-ExecutionPolicy','Bypass','-File',('"' + $PSCommandPath + '"'),
                     '-InstallDir',('"' + $InstallDir + '"'))
        if ($RemoveConfig) { $argList += '-RemoveConfig' }
        Start-Process -FilePath 'powershell.exe' -Verb RunAs -ArgumentList $argList -Wait
        Write-Ok 'Done (handled by the elevated step).'
        return
    }
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
    Write-Ok "Scheduled Task '$TaskName' removed."
} else {
    Write-Ok 'No Scheduled Task found.'
}

# ---- Stop the running process ----------------------------------------------
Write-Step 'Stopping WinMacKeys...'
Get-CimInstance Win32_Process -Filter "Name = 'WinMacKeys.exe'" -ErrorAction SilentlyContinue |
    ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
# Source mode: AutoHotkey running our script
Get-CimInstance Win32_Process -Filter "Name = 'AutoHotkey64.exe'" -ErrorAction SilentlyContinue |
    Where-Object { $_.CommandLine -like '*WinMacKeys.ahk*' } |
    ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
Write-Ok 'Process stopped.'

# ---- Remove installed files -------------------------------------------------
if (Test-Path -LiteralPath $InstallDir) {
    Remove-Item -LiteralPath $InstallDir -Recurse -Force
    Write-Ok "Removed: $InstallDir"
}

# ---- Optionally remove config ----------------------------------------------
$CfgDir = Join-Path $env:APPDATA $AppName
if ($RemoveConfig) {
    if (Test-Path -LiteralPath $CfgDir) {
        Remove-Item -LiteralPath $CfgDir -Recurse -Force
        Write-Ok "Removed config: $CfgDir"
    }
} else {
    Write-Ok "Config kept: $CfgDir (use -RemoveConfig to delete)."
}

Write-Host ''
Write-Host "$AppName uninstalled." -ForegroundColor Green
