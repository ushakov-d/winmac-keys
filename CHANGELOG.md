# Changelog

All notable changes to this project are documented here.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-06-07

### Added
- Switch input language with a single key (default `Caps Lock`); `Shift+Caps Lock`
  keeps the normal Caps Lock behaviour.
- Optional `Ctrl ⇄ Win` swap (`off` / `left` / `full`).
- Map a Mac-style chord to the Windows region screenshot (`Win+Shift+S`); default
  `Ctrl+Shift+Win+4` to match common Keychron Mac macro keys.
- Generic key remaps (`[remap]`), e.g. `CapsLock = Escape`.
- App / file / URL launcher hotkeys (`[run]`).
- Hyper key (`Ctrl+Alt+Shift+Win`) with `[hyper]` + `[hyper_run]` bindings.
- macOS-style text navigation (`[mac_text_nav]`).
- INI-based configuration in `%APPDATA%\WinMacKeys\config.ini`.
- Tray menu: Suspend, Edit config, Reload, Exit.
- `install.ps1` / `uninstall.ps1` with a SID-based logon Scheduled Task.
- GitHub Actions: PowerShell lint (CI) and automated release on tags.

[0.1.0]: https://github.com/ushakov-d/winmac-keys/releases/tag/v0.1.0
