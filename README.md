# WinMacKeys

> Mac-style keyboard tweaks for Windows: switch input language with **Caps Lock**, swap **Ctrl ⇄ Win**, a Mac-style **region-screenshot** chord, plus custom remaps — all config-driven.

[![CI](https://github.com/ushakov-d/winmac-keys/actions/workflows/ci.yml/badge.svg)](https://github.com/ushakov-d/winmac-keys/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/ushakov-d/winmac-keys?sort=semver)](https://github.com/ushakov-d/winmac-keys/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

🇷🇺 [Документация на русском](README.ru.md)

Windows has **no built-in way** to switch the input language with Caps Lock — that's the main reason this tool exists. Under the hood it's a tiny [AutoHotkey v2](https://www.autohotkey.com/) script driven by a simple `config.ini`.

## Features

| Feature | Default | What it does |
| --- | --- | --- |
| **Language switch** | `Caps Lock` | One key toggles the input language. `Shift+Caps Lock` keeps the normal Caps Lock. |
| **Ctrl ⇄ Win swap** | off | Make the bottom-row modifiers feel like macOS (`off` / `left` / `full`). |
| **Region screenshot** | `Ctrl+Shift+Win+4` | Maps a Mac-style chord to the Windows region capture (`Win+Shift+S`). |
| **Custom remaps** | off | Remap any key to any key, e.g. `CapsLock = Escape`. |
| **App / URL launcher** | off | Bind a hotkey to launch an app, file or URL. |
| **Hyper key** | off | Turn a key into `Ctrl+Alt+Shift+Win` and bind `hyper + X` shortcuts. |
| **Mac text navigation** | off | `Win+←/→` = Home/End, `Win+↑/↓` = doc start/end, `Alt+←/→` = word. |

## Install

**From a release (recommended).** Download the latest `WinMacKeys-vX.Y.Z.zip` from [Releases](https://github.com/ushakov-d/winmac-keys/releases), unzip, and run:

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

The bundle includes a standalone `WinMacKeys.exe`, so **AutoHotkey is not required**.

**From source** (installs AutoHotkey v2 via `winget` if missing):

```powershell
git clone https://github.com/ushakov-d/winmac-keys.git
cd winmac-keys
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1
```

The installer copies the app to `%LOCALAPPDATA%\Programs\WinMacKeys`, writes a default `%APPDATA%\WinMacKeys\config.ini`, and registers a **logon Scheduled Task** (one UAC prompt). Use `-NoAutostart` to skip autostart; `uninstall.ps1` removes everything (add `-RemoveConfig` to drop the config too).

## Configuration

Everything is toggled in `%APPDATA%\WinMacKeys\config.ini` — no code changes. Each `[section]` is independent (`enabled = true/false`, or `mode = ...` for the swap); `[remap]`, `[run]` and `[hyper_run]` are just lists of lines, and an **empty section means off**. Defaults: language switch + screenshot **on**, everything else **off**. Edit the file, then pick **Reload** from the tray menu.

```ini
[language]
; method: altshift | ctrlshift | winspace
enabled = true
hotkey = CapsLock
method = altshift
```

See [`config/winmac-keys.example.ini`](config/winmac-keys.example.ini) for the full, commented reference (remaps, launcher, hyper key, Mac text navigation). Hotkeys use [AutoHotkey syntax](https://www.autohotkey.com/docs/v2/Hotkeys.htm): `^` Ctrl, `!` Alt, `+` Shift, `#` Win.

## Notes

- **Unsigned `.exe`** — SmartScreen may warn on first run (*More info → Run anyway*); each release ships a `.sha256`.
- **Ctrl ⇄ Win swap** moves `Ctrl+C/V/Z` onto the former Win key, so it's **off by default**.
- Autostart is a per-user **Scheduled Task** (logon, elevated, keyed by SID) — needs one UAC at install, so run as a local administrator.
- Works with Cyrillic / spaced user names (paths come from environment variables, files are UTF-8).

## Compatibility

- **Tested:** Windows 11 Pro 25H2 (build 26200.8457), x64 — AutoHotkey v2.0.26, Windows PowerShell 5.1.
- **Should also work on** Windows 10/11 (x64) — not all builds verified. `Win+Shift+S` needs the Snipping Tool (Windows 10 1809+); installing from source needs `winget`.

## Build

```powershell
Ahk2Exe.exe /in src\WinMacKeys.ahk /out dist\WinMacKeys.exe /base AutoHotkey64.exe
```

CI builds the `.exe` and publishes a release automatically on every `vX.Y.Z` tag.

## License

[MIT](LICENSE)
