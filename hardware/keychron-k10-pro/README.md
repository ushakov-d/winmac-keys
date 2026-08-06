# Keychron K10 Pro — hardware keymap (QMK/VIA)

The same Mac-style layout as WinMacKeys, but flashed **into the keyboard** instead of running as software.

**Why you may want this:** kernel-level anti-cheats (FACEIT, Vanguard, EAC…) block the low-level keyboard hooks AutoHotkey relies on, so software remaps silently stop working inside those games. A QMK keymap lives in the keyboard's firmware — the OS just receives ordinary key presses, so it works everywhere: games, BIOS, another PC, a fresh Windows install.

## What's here

`k10-pro-keymap.json` — exported from [Keychron Launcher](https://launcher.keychron.com). Restore it with **Import**.

The file holds **all four layers** as `{col, row, val}` entries (`val` is the numeric QMK keycode), so importing it also replaces layers 0/1 — including the *Mac* half of someone else's board. If you only want the Windows behaviour, apply the table below by hand instead.

> Exported from a K10 Pro RGB (ANSI). Other Keychron models have a different key count — use this as a reference, not a drop-in file.

## Layout

Keychron Pro boards keep two independent profiles selected by the physical Mac/Win slider:
**Layers 0/1 = Mac (untouched)**, **Layers 2/3 = Windows**. Only the Windows layers are changed, so the same keyboard still behaves natively on a Mac.

| Key | Windows layer (2/3) | Notes |
| --- | --- | --- |
| **Caps Lock** | `LALT(KC_LSFT)` | Sends Alt+Shift → switches input language |
| **Fn + Caps Lock** | `KC_CAPS` | The real Caps Lock lives here now |
| Bottom row, left | **Win · Alt · Ctrl** | Ctrl ends up next to space, like Cmd on a Mac |
| Bottom row, right | **Ctrl · Alt** … **Win** | Mirrors the left side |
| **Print Screen** | `LGUI(LSFT(KC_S))` | Win+Shift+S region screenshot |

Both non-trivial bindings are plain QMK keycodes, not macros — in Launcher: select the key → **Custom → Any** → type the keycode → Enter.

## Recreating it by hand

1. Connect the keyboard **by cable** (WebHID doesn't work over Bluetooth) and open [launcher.keychron.com](https://launcher.keychron.com) in Chrome/Edge.
2. Put the physical slider in **Win** and select **Layer 2**.
3. Apply the table above (**Layer 3** only for the Caps Lock entry).

Changes are written to the keyboard immediately — there is no save button. The red **Reset** button wipes them, and a firmware update may too, so keep the exported JSON.

## Bonus: debounce

**Advanced Mode → Keyboard Bounce Time Settings.** The stock value can be as high as 50 ms; with the recommended `Eager Per Key` mode that also delays key *release*, which is noticeable when counter-strafing in a shooter. **5 ms** is the long-standing QMK default and a safer floor than 0 ms, which invites double-clicks from switch chatter.
