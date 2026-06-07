# WinMacKeys

> Mac-подобные клавиши для Windows: переключение языка по **Caps Lock**, своп **Ctrl ⇄ Win**, Mac-аккорд для **скриншота области** и произвольные ремапы — всё через конфиг.

[![CI](https://github.com/ushakov-d/winmac-keys/actions/workflows/ci.yml/badge.svg)](https://github.com/ushakov-d/winmac-keys/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/ushakov-d/winmac-keys?sort=semver)](https://github.com/ushakov-d/winmac-keys/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

🇬🇧 [Documentation in English](README.md)

В Windows **нет штатной возможности** переключать язык по Caps Lock — ради этого в основном и сделана утилита. Под капотом — крошечный скрипт на [AutoHotkey v2](https://www.autohotkey.com/), управляемый простым `config.ini`.

## Возможности

| Фича | По умолч. | Что делает |
| --- | --- | --- |
| **Переключение языка** | `Caps Lock` | Один клавишей меняет язык. `Shift+Caps Lock` оставляет обычный Caps Lock. |
| **Своп Ctrl ⇄ Win** | выкл | Нижний ряд модификаторов как на macOS (`off` / `left` / `full`). |
| **Скриншот области** | `Ctrl+Shift+Win+4` | Mac-аккорд на системный захват области (`Win+Shift+S`). |
| **Произвольные ремапы** | выкл | Любая клавиша → любая, напр. `CapsLock = Escape`. |
| **Лаунчер прил./URL** | выкл | Хоткей запускает приложение, файл или сайт. |
| **Hyper-клавиша** | выкл | Клавиша как `Ctrl+Alt+Shift+Win` + сочетания `hyper + X`. |
| **Mac-навигация по тексту** | выкл | `Win+←/→` = Home/End, `Win+↑/↓` = начало/конец, `Alt+←/→` = по словам. |

## Установка

Ставится из исходников — работает на официальном рантайме AutoHotkey v2, который установщик при необходимости подтянет через `winget`:

```powershell
git clone https://github.com/ushakov-d/winmac-keys.git
cd winmac-keys
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1
```

Нет git? Скачай репозиторий ZIP-ом (зелёная кнопка **Code** → **Download ZIP**), распакуй и запусти `scripts\install.ps1` из распакованной папки.

Установщик кладёт программу в `%LOCALAPPDATA%\Programs\WinMacKeys`, создаёт `%APPDATA%\WinMacKeys\config.ini` и регистрирует **задачу автозапуска при входе** (один UAC). Флаг `-NoAutostart` пропускает автозапуск; `uninstall.ps1` всё удаляет (`-RemoveConfig` — вместе с конфигом).

## Конфигурация

Всё включается/выключается в `%APPDATA%\WinMacKeys\config.ini` — код трогать не надо. Каждая `[секция]` независима (`enabled = true/false`, у свопа — `mode = ...`); `[remap]`, `[run]`, `[hyper_run]` — просто списки строк, а **пустая секция = выключено**. Умолчания: язык + скриншот **вкл**, остальное **выкл**. Поправил файл → **Reload** в меню трея.

```ini
[language]
; method: altshift | ctrlshift | winspace
enabled = true
hotkey = CapsLock
method = altshift
```

Полный конфиг с комментариями — [`config/winmac-keys.example.ini`](config/winmac-keys.example.ini) (ремапы, лаунчер, hyper-клавиша, Mac-навигация). Синтаксис хоткеев — [как в AutoHotkey](https://www.autohotkey.com/docs/v2/Hotkeys.htm): `^` Ctrl, `!` Alt, `+` Shift, `#` Win.

## Заметки

- **Своп Ctrl ⇄ Win** переносит `Ctrl+C/V/Z` на бывшую клавишу Win, поэтому **выключен по умолчанию**.
- Автозапуск — задача Планировщика (вход, с правами, по SID); нужен один UAC при установке, ставь под аккаунтом с правами админа.
- Работает с кириллицей/пробелами в имени пользователя (пути из переменных окружения, файлы в UTF-8).

## Совместимость

- **Протестировано:** Windows 11 Pro 25H2 (сборка 26200.8457), x64 — AutoHotkey v2.0.26, Windows PowerShell 5.1.
- **Должно работать и на** Windows 10/11 (x64) — не все сборки проверены. `Win+Shift+S` требует «Ножницы» (Windows 10 1809+); установщик тянет AutoHotkey через `winget`.

## Разработка

Запуск скрипта напрямую во время правок:

```powershell
AutoHotkey64.exe src\WinMacKeys.ahk
```

## Лицензия

[MIT](LICENSE)
