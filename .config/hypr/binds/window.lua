local p    = require("config.programs")
local mons = require("config.monitors")
local ws   = require("config.workspaces")
local mod  = p.mainMod

local function nav(dir, fallback)
    return function()
        if mons.overview_open() then
            hl.exec_cmd(p.qs("overview", "move", dir))
        else
            hl.dispatch(fallback)
        end
    end
end

hl.bind(mod .. " + C", hl.dsp.window.close(),
    { description = "Close window" })

hl.bind(mod .. " + F", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }),
    { description = "Maximize window" })

hl.bind(mod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }),
    { description = "Fullscreen" })
hl.bind("ALT + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }),
    { description = "Fullscreen" })

hl.bind(mod .. " + V", hl.dsp.window.float({ action = "toggle" }),
    { description = "Toggle floating" })
hl.bind("ALT + backslash", hl.dsp.window.float({ action = "toggle" }),
    { description = "Toggle floating" })

hl.bind(mod .. " + SHIFT + V", hl.dsp.window.cycle_next({ floating = true }),
    { description = "Focus floating window" })

hl.bind(mod .. " + G", hl.dsp.group.toggle(),
    { description = "Toggle tabbed group" })

---- focus ---------------------------------------------------------------

local function nav_side(dir, focusdir, delta)
    return function()
        if mons.overview_open() then
            hl.exec_cmd(p.qs("overview", "move", dir))
            return
        end
        local before = hl.get_active_window()
        hl.dispatch(hl.dsp.focus({ direction = focusdir }))
        local after = hl.get_active_window()
        if before and after and after.address ~= before.address then return end

        local id = ws.existing_neighbour_id(delta)
        if id then hl.dispatch(hl.dsp.focus({ workspace = id })) end
    end
end

hl.bind(mod .. " + H", nav_side("h", "left", -1),
    { description = "Window left / previous workspace" })
hl.bind(mod .. " + L", nav_side("l", "right", 1),
    { description = "Window right / next workspace" })
hl.bind(mod .. " + J", nav("j", hl.dsp.focus({ direction = "down" })),
    { description = "Window below" })
hl.bind(mod .. " + K", nav("k", hl.dsp.focus({ direction = "up" })),
    { description = "Window above" })

hl.bind(mod .. " + Tab", hl.dsp.window.cycle_next(),
    { description = "Next window" })

hl.bind(mod .. " + left",  nav_side("h", "left", -1))
hl.bind(mod .. " + right", nav_side("l", "right", 1))
hl.bind(mod .. " + up",    nav("k", hl.dsp.focus({ direction = "up" })))
hl.bind(mod .. " + down",  nav("j", hl.dsp.focus({ direction = "down" })))

---- move window ---------------------------------------------------------

hl.bind(mod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }),
    { description = "Move window left" })
hl.bind(mod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }),
    { description = "Move window right" })

hl.bind(mod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }),
    { description = "Move window down" })
hl.bind(mod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }),
    { description = "Move window up" })

---- split tree and window size ------------------------------------------

hl.bind(mod .. " + R", hl.dsp.layout("togglesplit"),
    { description = "Rotate split" })

hl.bind(mod .. " + SHIFT + R", hl.dsp.layout("swapsplit"),
    { description = "Swap split sides" })

hl.bind(mod .. " + CTRL + F", hl.dsp.window.pseudo(),
    { description = "Pseudotile" })

hl.bind(mod .. " + E", hl.dsp.layout("movetoroot"),
    { description = "Window to tree root" })

hl.bind(mod .. " + CTRL + C", hl.dsp.window.center(),
    { description = "Center floating window" })

hl.bind(mod .. " + minus", hl.dsp.window.resize({ x = -100, y = 0, relative = true }),
    { description = "Narrower" })
hl.bind(mod .. " + equal", hl.dsp.window.resize({ x = 100, y = 0, relative = true }),
    { description = "Wider" })

hl.bind(mod .. " + SHIFT + minus", hl.dsp.window.resize({ x = 0, y = -50, relative = true }),
    { description = "Shorter" })
hl.bind(mod .. " + SHIFT + equal", hl.dsp.window.resize({ x = 0, y = 50, relative = true }),
    { description = "Taller" })

---- groups and preselect ------------------------------------------------

hl.bind(mod .. " + bracketleft", hl.dsp.group.move_window({ direction = "left" }),
    { description = "Move left in group" })
hl.bind(mod .. " + bracketright", hl.dsp.group.move_window({ direction = "right" }),
    { description = "Move right in group" })

hl.bind(mod .. " + comma", hl.dsp.layout("preselect l"),
    { description = "Next window left" })
hl.bind(mod .. " + period", hl.dsp.layout("preselect r"),
    { description = "Next window right" })

---- floating: move and resize -------------------------------------------

hl.bind("CTRL + SHIFT + up",    hl.dsp.window.move({ x = 0,   y = -50, relative = true }))
hl.bind("CTRL + SHIFT + down",  hl.dsp.window.move({ x = 0,   y = 50,  relative = true }))
hl.bind("CTRL + SHIFT + left",  hl.dsp.window.move({ x = -50, y = 0,   relative = true }))
hl.bind("CTRL + SHIFT + right", hl.dsp.window.move({ x = 50,  y = 0,   relative = true }))

hl.bind("CTRL + ALT + left",  hl.dsp.window.resize({ x = -50, y = 0, relative = true }))
hl.bind("CTRL + ALT + right", hl.dsp.window.resize({ x = 50,  y = 0, relative = true }))
hl.bind("CTRL + ALT + up",    hl.dsp.window.resize({ x = 0, y = -50, relative = true }))
hl.bind("CTRL + ALT + down",  hl.dsp.window.resize({ x = 0, y = 50,  relative = true }))
