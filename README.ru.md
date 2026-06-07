# WinMacKeys

> Mac-подобные клавиши для Windows 11 — переключение языка по **Caps Lock**, опциональный своп **Ctrl ⇄ Win** и Mac-аккорд для **скриншота области**.

[![CI](https://github.com/ushakov-d/winmac-keys/actions/workflows/ci.yml/badge.svg)](https://github.com/ushakov-d/winmac-keys/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/ushakov-d/winmac-keys?sort=semver)](https://github.com/ushakov-d/winmac-keys/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

🇬🇧 [Documentation in English](README.md)

---

## Возможности

| Фича | По умолчанию | Что делает |
| --- | --- | --- |
| **Переключение языка** | `Caps Lock` | Один клавишей меняет язык ввода. `Shift+Caps Lock` оставляет обычный Caps Lock. |
| **Своп Ctrl ⇄ Win** | выкл | Делает нижний ряд модификаторов как на macOS. `off` / `left` / `full`. |
| **Скриншот области** | `Ctrl+Shift+Win+4` | Вешает Mac-аккорд на системный захват области (`Win+Shift+S`). Удобно для макро-кнопки Keychron. |
| **Произвольные ремапы** | выкл | Любая клавиша → любая, напр. `CapsLock = Escape`, через `[remap]`. |
| **Лаунчер прил./URL** | выкл | Хоткей запускает приложение, файл или сайт через `[run]`. |
| **Hyper-клавиша** | выкл | Превращает клавишу в `Ctrl+Alt+Shift+Win` и вешает `hyper + X`. |
| **Mac-навигация по тексту** | выкл | `Win+←/→` = Home/End, `Win+↑/↓` = начало/конец, `Alt+←/→` = по словам. |

Всё управляется маленьким INI-файлом, поэтому каждую фичу можно включать/выключать без правки кода.

> В Windows **нет встроенной опции** переключать язык по Caps Lock — ради этого инструмент в основном и сделан.

## Почему не просто реестр?

Штатные хоткеи Windows ограничены: `Alt+Shift`, `Ctrl+Shift`, гравис и `Win+Space`. Caps Lock в системном списке отсутствует. WinMacKeys добавляет это (и пару смежных удобств) тонким слоем на [AutoHotkey v2](https://www.autohotkey.com/).

## Как это работает

Под капотом — крошечный скрипт на [AutoHotkey v2](https://www.autohotkey.com/): он перехватывает нажатия и подменяет их на настроенное действие. Все настройки — в простом `config.ini`: поменял значение, нажал **Reload** в меню трея — готово, код трогать не надо. Установщик копирует программу, создаёт конфиг и регистрирует **задачу в Планировщике**, чтобы утилита запускалась при входе в систему; деинсталлятор всё убирает. Нет AutoHotkey? В релизах лежит автономный `.exe` — работает без зависимостей.

Одной фразой: *тонкий слой поверх Windows, который вешает «маковские» привычки (Caps = язык, Ctrl↔Win, аккорд для скриншота и твои собственные ремапы) на клавиатуру и сам стартует при входе.*

## Установка

### Вариант A — из релиза (рекомендуется)

1. Скачай свежий `WinMacKeys-vX.Y.Z.zip` из [Releases](https://github.com/ushakov-d/winmac-keys/releases) и распакуй.
2. В распакованной папке запусти:

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\install.ps1
   ```

В релиз вложен автономный `WinMacKeys.exe`, поэтому **AutoHotkey не нужен**.

### Вариант B — из исходников

```powershell
git clone https://github.com/ushakov-d/winmac-keys.git
cd winmac-keys
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1
```

Из исходников установщик при необходимости поставит AutoHotkey v2 через `winget`.

Установщик:

- копирует программу в `%LOCALAPPDATA%\Programs\WinMacKeys`,
- кладёт конфиг по умолчанию в `%APPDATA%\WinMacKeys\config.ini` (существующий не трогает),
- создаёт **задачу автозапуска при входе** (один запрос UAC),
- сразу запускает.

Флаг `-NoAutostart` пропускает создание задачи.

## Конфигурация

Любая фича включается/выключается в одном текстовом файле — **код трогать не надо**. Каждая `[секция]` независима: где есть тумблер — `enabled = true/false` (а у свопа — `mode = ...`); секции `[remap]`, `[run]`, `[hyper_run]` — это просто списки строк, а **пустая секция = выключено**. Умолчания: переключение языка и скриншот области **вкл**, остальное **выкл**.

Отредактируй `%APPDATA%\WinMacKeys\config.ini`, затем выбери **Reload** в меню трея — изменения применяются сразу.

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
; hotkeys: список через ; ; ^=Ctrl +=Shift #=Win  (^+#4 = Ctrl+Shift+Win+4)
enabled = true
hotkeys = ^+#4

[remap]
; по строке "from = to"
CapsLock = Escape

[run]
; "хоткей = команда"
#t = wt.exe
^!c = https://www.google.com

[hyper]
; превратить клавишу в Ctrl+Alt+Shift+Win, привязки в [hyper_run]
enabled = false
key = CapsLock

[hyper_run]
; <клавиша> = команда  (срабатывает, пока зажата hyper-клавиша)
e = explorer.exe

[mac_text_nav]
; Win = Cmd. ВНИМАНИЕ: пока включено, перекрывает Win+стрелки (привязку окон)
enabled = false
```

Полный конфиг с комментариями — [`config/winmac-keys.example.ini`](config/winmac-keys.example.ini). Новые секции (`remap`, `run`, `hyper`, `mac_text_nav`) поставляются **выключенными/пустыми** — пока не включишь, ничего не меняется.

> Комментарии пиши на отдельной строке (с `;`), не после значения — Windows INI считает значением всё после `=`. Синтаксис хоткеев — [как в AutoHotkey](https://www.autohotkey.com/docs/v2/Hotkeys.htm): `^` Ctrl, `!` Alt, `+` Shift, `#` Win.

## Меню в трее

Иконка в трее даёт **Suspend hotkeys**, **Edit config**, **Reload** и **Exit**.
Чтобы работать без иконки, добавь `#NoTrayIcon` в начало `WinMacKeys.ahk` (сборка из исходников).

## Удаление

```powershell
powershell -ExecutionPolicy Bypass -File .\uninstall.ps1
# добавь -RemoveConfig, чтобы удалить и config.ini
```

## Как работает автозапуск

Задача Планировщика для пользователя (`AtLogon`, задержка 5 сек, повышенные права) запускает приложение. Это надёжнее папки автозагрузки, а повышенные права позволяют ремапам работать даже в админ-окнах. Принципал задачи задан по **SID**, поэтому переименование аккаунта ничего не ломает.

## Заметки и ограничения

- **Неподписанный .exe.** Релизный `.exe` без цифровой подписи — SmartScreen может предупредить при первом запуске (*Подробнее → Выполнить в любом случае*). К каждому релизу прилагается контрольная сумма `.sha256`; либо запускай из исходников.
- **Своп Ctrl ⇄ Win** переносит `Ctrl+C/V/Z` на бывшую клавишу Win — это и есть смысл свопа, но многих удивляет, поэтому он **выключен по умолчанию**.
- **Шаг с правами админа.** Для создания задачи нужен один запрос UAC. Используй аккаунт с правами локального администратора (как обычно на личных ПК); если повысить права *другим* админ-аккаунтом, задача создастся для него. Флаг `-NoAutostart` отключает этот шаг.
- Работает с кириллицей/пробелами в имени пользователя (пути берутся из переменных окружения, файлы пишутся в UTF-8). См. **Совместимость** ниже.

## Совместимость

- **Протестировано на:** Windows 11 Pro **25H2** (сборка 26200.8457), x64 — с AutoHotkey **v2.0.26** и Windows PowerShell **5.1**.
- **Должно работать и на:** Windows 10 и 11 (x64). AutoHotkey v2 работает на Windows 7+, а фичи используют штатные системные сочетания — так что другие свежие сборки тоже ожидаемо подойдут, но нами пока не проверены.
- **Требования:**
  - Скриншот `Win+Shift+S` — нужен инструмент «Ножницы» (Windows 10 1809+, штатно есть на 10/11).
  - Установка **из исходников** тянет AutoHotkey через `winget` (Windows 10 1709+ / App Installer). Релизный `.exe` не требует ни winget, ни AutoHotkey.
  - 64-битная Windows (сборка x64); Windows PowerShell 5.1 (идёт с Windows) или новее.

## Локальная сборка

```powershell
# нужны AutoHotkey v2 + Ahk2Exe
Ahk2Exe.exe /in src\WinMacKeys.ahk /out dist\WinMacKeys.exe /base AutoHotkey64.exe
```

CI собирает `.exe` и публикует релиз автоматически при пуше тега `vX.Y.Z`.

## Лицензия

[MIT](LICENSE)
