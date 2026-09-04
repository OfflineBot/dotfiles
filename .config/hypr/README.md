# Hyprland config

Lua config for Hyprland 0.56, ported from `~/.config/niri/config.kdl`.

## Layout

```
hyprland.lua            entry point, loads modules and sets package.path
config/
  programs.lua          programs, paths and commands
  monitors.lua          DP-1 / DP-2 / DP-3 + direction helpers
  workspaces.lua        per-monitor workspace blocks + workspace rules
  env.lua               cursor theme, desktop identity
  input.lua             keyboard, mouse, touchpad
  theme.lua             colours, borders, gaps, rounding, blur
  animations.lua        curves and springs
  layout.lua            dwindle layout
  rules.lua             window and layer rules
  autostart.lua         awww, quickshell, gsettings, EasyEffects
binds/
  init.lua              loads all bind modules
  apps.lua              programs, quickshell IPC, overview
  window.lua            focus, moving, column width, fullscreen
  monitors.lua          monitor navigation (Alt+HJKL)
  workspaces.lua        workspaces 1-10 per monitor
  media.lua             volume, brightness, playerctl
  screenshot.lua        grim / slurp
  system.lua            quit, monitors off
  mouse.lua             drag / resize
```

`general.layout = "dwindle"` (in `config/theme.lua`). The former scrolling
experiment is gone; the binds below are dwindle binds (`togglesplit`,
`swapsplit`, `preselect`).

## Navigation

| Key | Effect | Scope |
|---|---|---|
| `Mod+H/L` | window left/right | current workspace |
| `Mod+J/K` | window below/above | current workspace |
| `Mod+1 … Mod+0` | workspace 1-10 | current monitor |
| `Mod+Scroll` | next/previous workspace | current monitor |
| `Alt+H/J/K/L` | switch monitor | the only thing that does |
| `Alt+Shift+H/J/K/L` | window to neighbouring monitor | — |
| `Mod+O`, `Alt+Tab` | overview | — |

`Mod+HJKL` stays on the current workspace on purpose: no paging to the next
workspace, no empty workspaces created. `Mod+Scroll` only rotates through
workspaces that already exist on the monitor.

Keeping `Mod+J/K` on the monitor needs this in `config/layout.lua`:

```lua
binds = { window_direction_monitor_fallback = false }
```

It defaults to **on**, which carries directional focus over the monitor edge
and would turn `Mod+H/J/K/L` at the edges into a monitor switch.

While the overview is open, `Mod+HJKL` moves the tile selection instead —
`binds/window.lua` checks `mons.overview_open()`.

## Per-monitor workspaces

niri gives every output its own workspace stack; Hyprland has one global
numbered set. `config/workspaces.lua` splits it into blocks of ten, pinned
with `workspace_rule`:

| Monitor | internal ids | keys |
|---|---|---|
| DP-2 (main) | 1 – 10 | Mod+1 … Mod+0 |
| DP-1 | 11 – 20 | Mod+1 … Mod+0 |
| DP-3 | 21 – 30 | Mod+1 … Mod+0 |

The binds are Lua **functions**, not fixed dispatchers: which block applies is
only known at keypress time (`ws.id_for(n)` looks up the focused monitor).

Everything user-facing shows 1-10. `Ws.qml` in quickshell folds the real ids
back with `((id - 1) % 10) + 1`; its `perMonitor` must match `M.per_monitor`.

Adding a monitor: put its name in `M.monitors` — the order decides the block.
Unknown monitors get a block behind the configured ones. Set
`M.persistent = true` to always show all ten tiles instead of only the used
ones.

## Monitor navigation

`config/monitors.lua` resolves the neighbour geometrically, like niri: the
candidate must lie entirely in that direction, and of those the nearest centre
wins. No wrapping. Hyprland has `focusmonitor l` but no dispatcher that moves
a window to a neighbour in a direction, which is why the target is resolved
manually.

For this setup (all three side by side, left to right DP-1, DP-2, DP-3):

```
DP-1: r -> DP-2
DP-2: l -> DP-1   r -> DP-3
DP-3: l -> DP-2
```

`Alt+J/K` (up/down) have no targets in this arrangement.

Check without pressing anything:

```sh
hyprctl dispatch 'function()
  local m = require("config.monitors")
  hl.notification.create({ text = m.describe(), timeout = 8000 }) end'
```

## Overview (Mod+O / Alt+Tab)

niri's `toggle-overview`, rebuilt in quickshell rather than as a plugin:
`~/.config/quickshell/modules/Overview.qml` and `OverviewTile.qml`, triggered
from `binds/apps.lua` via `qs ipc call overview toggle`.

Each monitor shows the workspaces holding windows plus the next free one, with
**live thumbnails** at their real positions.

| Input | Effect |
|---|---|
| `Mod+O` / `Alt+Tab` | open / close |
| `Esc` | close |
| `Mod+HJKL` or plain `hjkl` / arrows | move the selection |
| `Enter` / `Space` | go to the selected workspace |
| `1` … `0` | jump to that workspace |
| click a window | focus exactly that window |
| click empty space | go to that workspace |
| click outside the grid | close |

### Why not a plugin

`hyprexpo` was the obvious candidate but has been **removed** from
`hyprwm/hyprland-plugins`, including the `drop-unmaintained` branch. The old
binds pointed at nothing. Everything else (hyprtasking, hycov) needs `cmake`
and root, and an ABI mismatch in a plugin takes the compositor down with it.

### How the thumbnails work

`ScreencopyView` from `Quickshell.Wayland` captures through
`hyprland-toplevel-export`, which also reaches windows on **invisible**
workspaces. Positions come from `HyprlandToplevel.lastIpcObject` (`at` /
`size`), scaled to the tile.

Three traps, all commented in the code:

1. `HyprlandWorkspace.toplevels` is not reliably populated for workspaces that
   are not currently visible. The tiles filter the global `Hyprland.toplevels`
   by `workspace.id` instead.
2. `HyprlandToplevel.address` has no `0x` prefix but Hyprland's `address:`
   selector needs one — without fixing that every click on a window is a
   no-op.
3. `input.lua` sets `follow_mouse = 1`. Once the overlay is gone Hyprland
   focuses whatever is under the pointer, so the pick is dispatched only
   **after** closing (timer in `Overview.qml`).

Tiles are locked to the monitor's aspect ratio, so `Overview.qml` picks the
column count that makes them largest while the rows still fit.

## Cursor

`config/env.lua` sets **`catppuccin-mocha-dark-cursors`** at size 24 in four
variables — `XCURSOR_THEME`/`SIZE` for Wayland clients, XWayland and Qt,
`HYPRCURSOR_THEME`/`SIZE` for Hyprland itself. Plus gsettings in
`config/autostart.lua` (GTK apps, and Hyprland's `cursor:sync_gsettings_theme`
reads from there) and `~/.icons/default/index.theme` for X11.

`cursor:enable_hyprcursor` is on by default, so Hyprland looks for a
hyprcursor theme — a directory with `manifest.hl` — first. Adwaita has none,
and when that lookup fails Hyprland falls back to its own **built-in light
blue pointer**. `catppuccin-mocha-dark-cursors` ships both formats.

Check it (`-c` includes the pointer):

```sh
grim -c -s 4 -g "$(hyprctl cursorpos | tr -d ' ') 40x40" /tmp/cursor.png
```

## Colours

Catppuccin Mocha (see `config/theme.lua`):

| Role | Colour |
|---|---|
| active border | `#cba6f7` -> `#eba0ac` (gradient) |
| urgent | `#f38ba8` |
| text | `#cdd6f4` |
| background | `#1e1e2e` |

## Deliberately missing

* `Mod+Escape` (keyboard-shortcuts-inhibit) and `Mod+Shift+Slash` (hotkey
  overlay) have no Hyprland equivalent. Use `hyprctl binds` instead.
* `Mod+Ctrl+R` (reset-window-height) has no dwindle equivalent.
* `xwayland-satellite` — Hyprland ships XWayland itself.
* Brightness binds — this desktop has no backlight (`/sys/class/backlight`
  is empty); monitor brightness would need `ddcutil`.

`Mod+N` locks via `hyprlock` (`hyprlock.conf` next to this file, found via
the default search path). `Mod+T` opens the WireGuard menu, `Mod+Ctrl+V` the
clipboard history (cliphist) — both are fzf pickers in a floating kitty
(`scripts/vpn-menu`, `scripts/clipboard-menu`, window rule `menu-float` in
`config/rules.lua`).
`Mod+X` / `Mod+Shift+X` cycle wallpapers from `~/Pictures/wallpapers`
(`scripts/wallpapers`, symlinked as `~/.local/bin/wallpapers`).

## Testing

```sh
hyprctl reload
hyprctl binds
hyprctl monitors
hyprctl workspacerules
```

With a Lua config `hyprctl dispatch` parses its argument as **Lua**, not
`.conf` syntax:

```sh
hyprctl dispatch 'hl.dsp.focus({ workspace = 13 })'    # works
hyprctl dispatch 'workspace 13'                        # syntax error
```

The same applies to anything else speaking the Hyprland IPC, quickshell's
`Hyprland.dispatch(...)` included. `hl.dispatch` also takes a function, which
makes bind logic testable from the shell:

```sh
hyprctl dispatch 'function() local ws = require("config.workspaces")
                  hl.dispatch(hl.dsp.focus({ workspace = ws.id_for(7) })) end'
```
