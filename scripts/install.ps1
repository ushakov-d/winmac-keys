#Requires -Version 5.1
<#
.SYNOPSIS
    Installs WinMacKeys: copies files, creates the default config, and registers
    a per-user logon Scheduled Task so it starts automatically.

.DESCRIPTION
    Works both from a cloned repo (uses src\WinMacKeys.ahk + AutoHotkey runtime)
    and from a release zip (uses the bundled WinMacKeys.exe, no runtime needed).

    All paths are resolved from environment variables, never built from the user
    name, so Cyrillic / spaced user names are handled correctly.

.PARAMETER NoAutostart
    Install without registering the logon Scheduled Task.

.PARAMETER InstallDir
    Override the install directory (default: %LOCALAPPDATA%\Programs\WinMacKeys).

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File scripts\install.ps1
#>
[CmdletBinding()]
param(
    [switch]$NoAutostart,
    [string]$InstallDir = (Join-Path $env:LOCALAPPDATA 'Programs\WinMacKeys')
)

$ErrorActionPreference = 'Stop'
$AppName  = 'WinMacKeys'
$TaskName = 'WinMacKeys'

function Write-Step($msg) { Write-Host "==> $msg" -ForegroundColor Cyan }
function Write-Ok($msg)   { Write-Host "    $msg" -ForegroundColor Green }
function Write-Warn2($msg){ Write-Host "    $msg" -ForegroundColor Yellow }

function Test-Admin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    (New-Object Security.Principal.WindowsPrincipal($id)).IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator)
}

# ---- Locate source artifacts (repo layout or release-zip layout) ------------
# Search both the installer's own folder (release zip: files are flat next to it)
# and its parent (repo: scripts\ with src\ + config\ one level up).
$SearchRoots = @($PSScriptRoot, (Split-Path -Parent $PSScriptRoot)) | Select-Object -Unique
$SrcExe = $null; $SrcAhk = $null; $SrcIni = $null
foreach ($root in $SearchRoots) {
    if (-not $SrcExe) {
        foreach ($rel in @('WinMacKeys.exe', 'dist\WinMacKeys.exe')) {
            $c = Join-Path $root $rel; if (Test-Path -LiteralPath $c) { $SrcExe = $c; break }
        }
    }
    if (-not $SrcAhk) {
        foreach ($rel in @('WinMacKeys.ahk', 'src\WinMacKeys.ahk')) {
            $c = Join-Path $root $rel; if (Test-Path -LiteralPath $c) { $SrcAhk = $c; break }
        }
    }
    if (-not $SrcIni) {
        foreach ($rel in @('winmac-keys.example.ini', 'config\winmac-keys.example.ini')) {
            $c = Join-Path $root $rel; if (Test-Path -LiteralPath $c) { $SrcIni = $c; break }
        }
    }
}

if (-not $SrcExe -and -not $SrcAhk) {
    throw "Could not find WinMacKeys.exe or WinMacKeys.ahk next to the installer."
}

# ---- Ensure AutoHotkey runtime when running from source (.ahk) --------------
function Resolve-AutoHotkey {
    $paths = @(
        (Join-Path $env:LOCALAPPDATA 'Programs\AutoHotkey\v2\AutoHotkey64.exe'),
        (Join-Path $env:ProgramFiles 'AutoHotkey\v2\AutoHotkey64.exe')
    )
    foreach ($p in $paths) { if (Test-Path -LiteralPath $p) { return $p } }
    return $null
}

$UseExe = [bool]$SrcExe
$AhkExe = $null
if (-not $UseExe) {
    $AhkExe = Resolve-AutoHotkey
    if (-not $AhkExe) {
        Write-Step 'AutoHotkey v2 not found; installing via winget...'
        if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
            throw "winget is not available. Install AutoHotkey v2 manually, or use the release .exe."
        }
        winget install --id AutoHotkey.AutoHotkey -e --accept-source-agreements --accept-package-agreements
        $AhkExe = Resolve-AutoHotkey
        if (-not $AhkExe) { throw "AutoHotkey installation did not complete." }
    }
    Write-Ok "AutoHotkey: $AhkExe"
}

# ---- Copy program files -----------------------------------------------------
Write-Step "Installing to: $InstallDir"
New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
if ($UseExe) {
    Copy-Item -LiteralPath $SrcExe -Destination (Join-Path $InstallDir 'WinMacKeys.exe') -Force
    $TargetForRun = Join-Path $InstallDir 'WinMacKeys.exe'
} else {
    Copy-Item -LiteralPath $SrcAhk -Destination (Join-Path $InstallDir 'WinMacKeys.ahk') -Force
    $TargetForRun = Join-Path $InstallDir 'WinMacKeys.ahk'
}
Write-Ok 'Program files copied.'

# ---- Create default config (do not overwrite an existing one) ---------------
$CfgDir  = Join-Path $env:APPDATA $AppName
$CfgFile = Join-Path $CfgDir 'config.ini'
New-Item -ItemType Directory -Force -Path $CfgDir | Out-Null
if (Test-Path -LiteralPath $CfgFile) {
    Write-Ok "Config kept (already exists): $CfgFile"
} elseif ($SrcIni) {
    Copy-Item -LiteralPath $SrcIni -Destination $CfgFile -Force
    Write-Ok "Default config written: $CfgFile"
} else {
    Write-Warn2 'No example config found; the app will use built-in defaults.'
}

# ---- Build the launch command ----------------------------------------------
if ($UseExe) {
    $Execute    = $TargetForRun
    $LaunchArgs = ''
} else {
    $Execute    = $AhkExe
    $LaunchArgs = '"' + $TargetForRun + '"'
}

function LaunchApp {
    if ([string]::IsNullOrEmpty($LaunchArgs)) { Start-Process -FilePath $Execute }
    else { Start-Process -FilePath $Execute -ArgumentList $LaunchArgs }
}

$autostart    = -not $NoAutostart
$elevatedHere = Test-Admin
$delegated    = $false

# ---- Register autostart (Scheduled Task) -----------------------------------
if ($autostart) {
    if (-not $elevatedHere) {
        Write-Step 'Registering the logon task requires administrator rights (one UAC prompt)...'
        $argList = @('-NoProfile','-ExecutionPolicy','Bypass','-File',('"' + $PSCommandPath + '"'),
                     '-InstallDir',('"' + $InstallDir + '"'))
        Start-Process -FilePath 'powershell.exe' -Verb RunAs -ArgumentList $argList -Wait
        $delegated = $true   # the elevated child registered AND started the app
        Write-Ok 'Elevated step finished.'
    } else {
        # Principal by SID (robust against renamed/Cyrillic account names);
        # trigger by account name (passed to Task Scheduler as Unicode, not via ANSI).
        $sid  = ([Security.Principal.WindowsIdentity]::GetCurrent()).User.Value
        $user = "$env:USERDOMAIN\$env:USERNAME"
        if ([string]::IsNullOrEmpty($LaunchArgs)) {
            $action = New-ScheduledTaskAction -Execute $Execute
        } else {
            $action = New-ScheduledTaskAction -Execute $Execute -Argument $LaunchArgs
        }
        $trigger = New-ScheduledTaskTrigger -AtLogOn -User $user
        $trigger.Delay = 'PT5S'
        $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
                    -StartWhenAvailable -ExecutionTimeLimit ([TimeSpan]::Zero) -MultipleInstances IgnoreNew
        $principal = New-ScheduledTaskPrincipal -UserId $sid -LogonType Interactive -RunLevel Highest
        Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger `
            -Settings $settings -Principal $principal -Force | Out-Null
        Write-Ok "Scheduled Task '$TaskName' registered (logon, 5s delay)."
    }
}

# ---- Start it now (avoid a second instance if a child already started it) ---
if (-not $delegated) {
    if ($autostart -and $elevatedHere) {
        try { Start-ScheduledTask -TaskName $TaskName } catch { LaunchApp }
    } else {
        LaunchApp
    }
}

Write-Host ''
Write-Host "$AppName installed. Edit config: $CfgFile (tray menu -> Reload to apply)." -ForegroundColor Green
