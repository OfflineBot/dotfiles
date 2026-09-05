local p   = require("config.programs")
local mod = p.mainMod

hl.bind(mod .. " + Q", hl.dsp.exec_cmd(p.terminal),
    { description = "Terminal" })
hl.bind(mod .. " + W", hl.dsp.exec_cmd(p.browser),
    { description = "Browser" })

---- quickshell ----------------------------------------------------------

hl.bind(mod .. " + Space", hl.dsp.exec_cmd(p.qs("launcher", "toggle")),
    { description = "Launcher" })
hl.bind(mod .. " + SHIFT + Space", hl.dsp.exec_cmd(p.qs("scriptlauncher", "toggle")),
    { description = "Script launcher" })
hl.bind(mod .. " + M", hl.dsp.exec_cmd(p.qs("logout", "toggle")),
    { description = "Logout overlay" })

hl.bind(mod .. " + R", hl.dsp.exec_cmd(p.qsOnFocusedMonitor("topbar", "toggleClock")),
    { description = "Info panel" })
hl.bind(mod .. " + B", hl.dsp.exec_cmd(p.qsOnFocusedMonitor("topbar", "toggle")),
    { description = "Toggle topbar" })

---- overview ------------------------------------------------------------

hl.bind(mod .. " + O", hl.dsp.exec_cmd(p.qs("overview", "toggle")),
    { description = "Overview" })
hl.bind("ALT + Tab", hl.dsp.exec_cmd(p.qs("overview", "toggle")),
    { description = "Overview" })

---- other ---------------------------------------------------------------

hl.bind(mod .. " + P", hl.dsp.exec_cmd(p.mixer),
    { description = "Pavucontrol" })
hl.bind(mod .. " + T", hl.dsp.exec_cmd(p.vpnMenu),
    { description = "VPN menu" })

hl.bind(mod .. " + X", hl.dsp.exec_cmd(p.wallpaper .. " next"),
    { description = "Wallpaper: next (focused monitor)" })
hl.bind(mod .. " + SHIFT + X", hl.dsp.exec_cmd(p.wallpaper .. " random"),
    { description = "Wallpaper: random on all monitors" })

hl.bind(mod .. " + N", hl.dsp.exec_cmd(p.lock),
    { description = "Lock: hyprlock" })

hl.bind(mod .. " + CTRL + V", hl.dsp.exec_cmd(p.clipboardMenu),
    { description = "Clipboard history (cliphist)" })
