local p   = require("config.programs")
local mod = p.mainMod

hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind(mod .. " + S", hl.dsp.window.resize(),
    { mouse = true, description = "Resize with mouse" })
