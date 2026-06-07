# WinMacKeys

> Mac-style keyboard tweaks for Windows 11 — switch input language with **Caps Lock**, optional **Ctrl ⇄ Win** swap, and a Mac-style **region screenshot** chord.

[![CI](https://github.com/ushakov-d/winmac-keys/actions/workflows/ci.yml/badge.svg)](https://github.com/ushakov-d/winmac-keys/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/ushakov-d/winmac-keys?sort=semver)](https://github.com/ushakov-d/winmac-keys/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

🇷🇺 [Документация на русском](README.ru.md)

---

## Features

| Feature | Default | What it does |
| --- | --- | --- |
| **Language switch** | `Caps Lock` | One key toggles the input language. `Shift+Caps Lock` keeps the normal Caps Lock. |
| **Ctrl ⇄ Win swap** | off | Make the bottom-row modifiers feel like macOS. `off` / `left` / `full`. |
| **Region screenshot** | `Ctrl+Shift+Win+4` | Maps a Mac-style chord to the Windows region capture (`Win+Shift+S`). Handy for Keychron Mac macro keys. |
| **Custom remaps** | off | Remap any key to any key, e.g. `CapsLock = Escape`, via `[remap]`. |
| **App / URL launcher** | off | Bind a hotkey to launch an app, file or URL via `[run]`. |
| **Hyper key** | off | Turn a key into `Ctrl+Alt+Shift+Win` and bind `hyper + X` shortcuts. |
| **Mac text navigation** | off | `Win+←/→` = Home/End, `Win+↑/↓` = doc start/end, `Alt+←/→` = word. |

Everything is driven by a small INI file, so each feature can be turned on/off without touching code.

> Windows has **no built-in option** to switch the input language with Caps Lock — that is the main reason this tool exists.

## Why a tool and not just registry tweaks?

The native Windows language-switch hotkeys are limited to `Alt+Shift`, `Ctrl+Shift`, the grave accent and `Win+Space`. Caps Lock is simply not an option in the OS UI. WinMacKeys adds that (and a couple of related niceties) as a tiny [AutoHotkey v2](https://www.autohotkey.com/) layer.

## How it works

Under the hood it's a tiny [AutoHotkey v2](https://www.autohotkey.com/) script that intercepts key presses and substitutes the action you configured. All settings live in a plain `config.ini` — change a value, hit **Reload** in the tray menu, done; you never edit code. The installer copies the program, creates the config and registers a **logon Scheduled Task** so it starts with Windows; the uninstaller removes everything. No AutoHotkey installed? Each release ships a standalone `.exe` that runs without dependencies.

In one line: *a thin layer over Windows that puts Mac-style habits (Caps = language, Ctrl↔Win, a screenshot chord, plus your own remaps) onto the keyboard and starts itself at logon.*

## Install

### Option A — from a release (recommended)

1. Download the latest `WinMacKeys-vX.Y.Z.zip` from [Releases](https://github.com/ushakov-d/winmac-keys/releases) and unzip it.
2. In the unzipped folder, run:

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\install.ps1
   ```

The release bundles a standalone `WinMacKeys.exe`, so **AutoHotkey is not required**.

### Option B — from source

```powershell
git clone https://github.com/ushakov-d/winmac-keys.git
cd winmac-keys
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1
```

From source the installer will install AutoHotkey v2 via `winget` if it is missing.

The installer:

- copies the program to `%LOCALAPPDATA%\Programs\WinMacKeys`,
- writes a default config to `%APPDATA%\WinMacKeys\config.ini` (never overwrites an existing one),
- registers a **logon Scheduled Task** so it starts automatically (one UAC prompt),
- starts it right away.

Run with `-NoAutostart` to skip the Scheduled Task.

## Configuration

Every feature is switched on/off in this one text file — **no code changes**. Each `[section]` is independent: set `enabled = true/false` (or `mode = ...` for the swap); the `[remap]`, `[run]` and `[hyper_run]` sections are just lists of lines, and an **empty section means off**. Defaults: language switch and region screenshot **on**, everything else **off**.

Edit `%APPDATA%\WinMacKeys\config.ini`, then pick **Reload** from the tray menu — changes apply instantly.

```ini
[language]
; method: altshift | ctrlshift | winspace
enabled = true
hotkey = CapsLock
method = altshift
shift_toggles_capslock = true

[swap_ctrl_win]
; mode: off | left | full
mode = off

[screenshot]
; hotkeys: semicolon-separated list; ^=Ctrl +=Shift #=Win  (^+#4 = Ctrl+Shift+Win+4)
enabled = true
hotkeys = ^+#4

[remap]
; one "from = to" per line
CapsLock = Escape

[run]
; "hotkey = command"
#t = wt.exe
^!c = https://www.google.com

[hyper]
; turn a key into Ctrl+Alt+Shift+Win, then bind hyper+X in [hyper_run]
enabled = false
key = CapsLock

[hyper_run]
; <key> = command  (fires while the hyper key is held)
e = explorer.exe

[mac_text_nav]
; Win = Cmd. NOTE: overrides Win+Arrow window snapping while enabled
enabled = false
```

See [`config/winmac-keys.example.ini`](config/winmac-keys.example.ini) for the fully commented reference. New sections (`remap`, `run`, `hyper`, `mac_text_nav`) ship **disabled/empty**, so they change nothing until you opt in.

> Put comments on their own line (starting with `;`), not after a value — Windows INI keeps everything after `=` as the value. Hotkeys use [AutoHotkey modifier syntax](https://www.autohotkey.com/docs/v2/Hotkeys.htm): `^` Ctrl, `!` Alt, `+` Shift, `#` Win.

## Tray menu

A tray icon provides **Suspend hotkeys**, **Edit config**, **Reload** and **Exit**.
To run without a tray icon, add `#NoTrayIcon` to the top of `WinMacKeys.ahk` (source build).

## Uninstall

```powershell
powershell -ExecutionPolicy Bypass -File .\uninstall.ps1
# add -RemoveConfig to also delete your config.ini
```

## How autostart works

A per-user **Scheduled Task** (`AtLogon`, 5-second delay, highest privileges) launches the app. This is more reliable than the Startup folder, and running elevated lets the remaps work even in elevated windows. The task principal is keyed by **SID**, so it keeps working if the account is renamed.

## Notes & limitations

- **Unsigned executable.** The released `.exe` is not code-signed, so SmartScreen may warn on first run (*More info → Run anyway*). Each release ships a `.sha256` checksum; or run from source if you prefer.
- **Ctrl ⇄ Win swap** moves `Ctrl+C/V/Z` onto the former Win key — that is the point of the swap, but it surprises people, so it is **off by default**.
- **Administrator step.** Registering the logon task needs one UAC prompt. Use an account that is a local administrator (typical on personal PCs); if you elevate with a *different* admin account, the task is registered for that account. Use `-NoAutostart` to skip it entirely.
- Works with Cyrillic / spaced user names (paths are resolved from environment variables and files are written as UTF-8). See **Compatibility** below.

## Compatibility

- **Tested on:** Windows 11 Pro **25H2** (build 26200.8457), x64 — with AutoHotkey **v2.0.26** and Windows PowerShell **5.1**.
- **Should also work on:** Windows 10 and 11 (x64). AutoHotkey v2 runs on Windows 7+ and the features rely on standard OS shortcuts, so other recent builds are expected to work — just not verified by us yet.
- **Requirements:**
  - `Win+Shift+S` region screenshot needs the Snipping Tool (Windows 10 1809+, standard on 10/11).
  - Installing **from source** uses `winget` to fetch AutoHotkey (Windows 10 1709+ / App Installer). The release `.exe` needs neither winget nor AutoHotkey.
  - 64-bit Windows (the bundled build is x64); Windows PowerShell 5.1 (ships with Windows) or newer.

## Build locally

```powershell
# requires AutoHotkey v2 + Ahk2Exe
Ahk2Exe.exe /in src\WinMacKeys.ahk /out dist\WinMacKeys.exe /base AutoHotkey64.exe
```

CI builds the `.exe` and publishes a release automatically when a `vX.Y.Z` tag is pushed.

## License

[MIT](LICENSE)
