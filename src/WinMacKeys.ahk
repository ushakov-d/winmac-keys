#Requires AutoHotkey v2.0
#SingleInstance Force
; =============================================================================
; WinMacKeys - Mac-style keyboard tweaks for Windows
; https://github.com/ushakov-d/winmac-keys
;
; Config-driven. This file is intentionally ASCII-only; all user-facing text
; lives in the README. Configuration is read from an INI file (see below).
; =============================================================================

; ---- Locate the configuration file -----------------------------------------
; Priority: per-user config in %APPDATA% -> file next to the script -> defaults.
ConfigPath() {
    candidates := [
        EnvGet("APPDATA") . "\WinMacKeys\config.ini",
        A_ScriptDir . "\config.ini",
        A_ScriptDir . "\winmac-keys.ini"
    ]
    for p in candidates
        if FileExist(p)
            return p
    return ""  ; no file -> built-in defaults are used
}

global CFG := ConfigPath()

ReadIni(section, key, defVal) {
    global CFG
    if (CFG = "")
        return defVal
    return Trim(IniRead(CFG, section, key, defVal))
}

; Read every "key = value" pair from a section (used by [remap], [run], [hyper_run]).
; Parses the file directly instead of the Windows INI API, because hotkey-style
; keys (e.g. ^!+#t) break IniRead's section enumeration. Comment lines (;) and
; the UTF-8 BOM are handled here too.
ReadPairs(section) {
    global CFG
    pairs := []
    if (CFG = "" || !FileExist(CFG))
        return pairs
    target := "[" . StrLower(section) . "]"
    inSection := false
    for line in StrSplit(FileRead(CFG, "UTF-8"), "`n", "`r") {
        t := Trim(line)
        if (t = "" || SubStr(t, 1, 1) = ";")
            continue
        if (SubStr(t, 1, 1) = "[") {
            inSection := (StrLower(t) = target)
            continue
        }
        if (!inSection)
            continue
        eq := InStr(t, "=")
        if (!eq)
            continue
        k := Trim(SubStr(t, 1, eq - 1))
        v := Trim(SubStr(t, eq + 1))
        if (k != "")
            pairs.Push([k, v])
    }
    return pairs
}

IsTrue(v) => (v = "1" || StrLower(v) = "true" || StrLower(v) = "yes" || StrLower(v) = "on")

SafeHotkey(spec, callback) {
    try {
        Hotkey(spec, callback)
    } catch as e {
        MsgBox("Invalid hotkey in config: '" . spec . "'`n" . e.Message, "WinMacKeys", "Iconx")
    }
}

; ---- Feature implementations ------------------------------------------------
SwitchLanguage(method) {
    switch StrLower(method) {
        case "ctrlshift": Send("{LCtrl down}{LShift down}{LShift up}{LCtrl up}")
        case "winspace":  Send("#{Space}")
        default:          Send("{LAlt down}{LShift down}{LShift up}{LAlt up}")  ; altshift
    }
}

ToggleCapsLock(*) => SetCapsLockState(!GetKeyState("CapsLock", "T"))

; Modifier remap that mirrors AHK's own internal "a::b" remapping.
RemapDown(to, *) => Send("{Blind}{" . to . " DownR}")
RemapUp(to, *)   => Send("{Blind}{" . to . " Up}")
RemapKey(from, to) {
    Hotkey("*" . from, RemapDown.Bind(to))
    Hotkey("*" . from . " Up", RemapUp.Bind(to))
}

RegionScreenshot(*) => Send("#+s")  ; Windows built-in region capture (Win+Shift+S)

RunLaunch(cmd, *) {
    try Run(cmd)
    catch as e
        MsgBox("Failed to run: '" . cmd . "'`n" . e.Message, "WinMacKeys", "Iconx")
}

HyperHeld(key, *) => GetKeyState(key, "P")  ; HotIf predicate: is the hyper key physically down?

; =============================================================================
; Apply configuration
; =============================================================================

; --- Language switch ---
if IsTrue(ReadIni("language", "enabled", "true")) {
    langKey := ReadIni("language", "hotkey", "CapsLock")
    langMethod := ReadIni("language", "method", "altshift")
    SafeHotkey(langKey, (*) => SwitchLanguage(langMethod))
    if (langKey = "CapsLock" && IsTrue(ReadIni("language", "shift_toggles_capslock", "true")))
        SafeHotkey("+CapsLock", ToggleCapsLock)
}

; --- Ctrl <-> Win swap ---
swapMode := StrLower(ReadIni("swap_ctrl_win", "mode", "off"))
if (swapMode = "full" || swapMode = "left") {
    RemapKey("LControl", "LWin")
    RemapKey("LWin", "LControl")
    if (swapMode = "full") {
        RemapKey("RControl", "RWin")
        RemapKey("RWin", "RControl")
    }
}

; --- Region screenshot ---
if IsTrue(ReadIni("screenshot", "enabled", "true")) {
    for hk in StrSplit(ReadIni("screenshot", "hotkeys", "^+#4"), ";", " `t")
        if (hk != "")
            SafeHotkey(hk, RegionScreenshot)
}

; --- Generic key remaps ([remap]: from = to) ---
for pair in ReadPairs("remap")
    if (pair[2] != "")
        RemapKey(pair[1], pair[2])

; --- Launch apps / files / URLs by hotkey ([run]: hotkey = command) ---
for pair in ReadPairs("run")
    if (pair[2] != "")
        SafeHotkey(pair[1], RunLaunch.Bind(pair[2]))

; --- Hyper key (Ctrl+Alt+Shift+Win); bindings in [hyper_run]: key = command ---
if IsTrue(ReadIni("hyper", "enabled", "false")) {
    hyperKey := ReadIni("hyper", "key", "CapsLock")
    SafeHotkey("*" . hyperKey, (*) => 0)        ; swallow the hyper key's own action
    HotIf(HyperHeld.Bind(hyperKey))             ; following hotkeys fire only while it is held
    for pair in ReadPairs("hyper_run")
        if (pair[2] != "")
            SafeHotkey(pair[1], RunLaunch.Bind(pair[2]))
    HotIf()                                      ; reset context
}

; --- macOS-style text navigation (Win key acts as Cmd) ---
; NOTE: overrides Win+Arrow window snapping while enabled.
if IsTrue(ReadIni("mac_text_nav", "enabled", "false")) {
    SafeHotkey("#Left",   (*) => Send("{Home}"))
    SafeHotkey("#Right",  (*) => Send("{End}"))
    SafeHotkey("+#Left",  (*) => Send("+{Home}"))
    SafeHotkey("+#Right", (*) => Send("+{End}"))
    SafeHotkey("#Up",     (*) => Send("^{Home}"))
    SafeHotkey("#Down",   (*) => Send("^{End}"))
    SafeHotkey("#BS",     (*) => Send("+{Home}{Del}"))   ; delete to start of line
    SafeHotkey("!Left",   (*) => Send("^{Left}"))         ; word left
    SafeHotkey("!Right",  (*) => Send("^{Right}"))        ; word right
}

; =============================================================================
; Tray icon + menu
; =============================================================================
A_IconTip := "WinMacKeys" . (CFG ? " - " . CFG : " (built-in defaults)")

tray := A_TrayMenu
tray.Delete()
tray.Add("WinMacKeys", (*) => 0)
tray.Disable("WinMacKeys")
tray.Add()
tray.Add("Suspend hotkeys", MenuSuspend)
tray.Add("Edit config", MenuEditConfig)
tray.Add("Reload", (*) => Reload())
tray.Add()
tray.Add("Exit", (*) => ExitApp())

MenuSuspend(*) {
    Suspend(-1)
    A_TrayMenu.ToggleCheck("Suspend hotkeys")
}

MenuEditConfig(*) {
    global CFG
    if (CFG != "")
        Run('notepad.exe "' . CFG . '"')
    else
        MsgBox("No config file found; using built-in defaults.", "WinMacKeys", "Iconi")
}
