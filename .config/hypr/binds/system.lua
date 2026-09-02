local p   = require("config.programs")
local mod = p.mainMod

hl.bind(mod .. " + SHIFT + E",
    hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch exit"),
    { description = "Quit Hyprland" })

hl.bind(mod .. " + SHIFT + P", function()
    hl.timer(function()
        hl.dispatch(hl.dsp.dpms({ action = "off" }))
    end, { timeout = 500, type = "oneshot" })
end, { description = "Turn monitors off" })
