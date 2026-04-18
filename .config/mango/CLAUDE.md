# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

This is a personal configuration directory for the **Mango** Wayland tiling window manager (wlroots-based compositor). There is no build system — these config files are read directly by the Mango compositor at runtime.

## Configuration Architecture

`config.conf` is the single entry point that sources all other configs:

```
config.conf          # Main config — global options, workspace layout assignments, axis bindings
├── src/autostart.conf   # Autostart daemons and env vars (Wayland, cursor, GTK theme)
├── src/keybinds.conf    # All keyboard shortcuts (Super/Alt/Ctrl modifier groups)
├── src/mousebinds.conf  # Mouse bindings
├── src/theme.conf       # Colors, borders, gaps, animations (Catppuccin Mocha Dark)
├── src/monitors.conf    # Three-monitor layout (DP-1 144Hz, HDMI-A-2 60Hz, DP-3 75Hz)
├── src/layouts.conf     # Active layout selection (right_tile / scroller)
├── layouts/master.conf  # Master-stack layout parameters
└── layouts/scroller.conf # Scroller layout parameters
```

`autostart.sh` is a shell script run at startup to export Wayland environment variables before the compositor reads `config.conf`.

## Key Design Decisions

- **Modifier groups:** Super key = window/workspace management; Alt key = layout/focus/floating; Ctrl = pixel-precise move/resize
- **Two layouts toggled at runtime:** `tile` (Super+t) uses `right_tile` / `master.conf`; `scroller` (Super+s) uses `scroller.conf`
- **Smart home bindings:** Super+b and Super+v send `curl` requests to devices at `192.168.188.50`, `.59`, `.54` for RGB lighting control
- **Music controls:** Alt+q/w/e use `playerctl` with Spotify-specific logic and a fallback for other players
- **Theme:** Catppuccin Mocha Dark throughout — root `#201b14`, border `#45475a`, focus `#cdd6f4`, gaps 5px inner / 10px outer

## Applying Changes

Configuration changes take effect when Mango reloads its config. No compilation or restart is required for most options; keybinds and theme changes typically need a config reload. Monitor and layout changes may require a full compositor restart.
