local p   = require("config.programs")
local ws  = require("config.workspaces")
local mod = p.mainMod

for n = 1, ws.per_monitor do
    local key = (n == 10) and "0" or tostring(n)

    hl.bind(mod .. " + " .. key, function()
        hl.dispatch(hl.dsp.focus({ workspace = ws.id_for(n) }))
    end, { description = "Workspace " .. n })

    hl.bind(mod .. " + SHIFT + " .. key, function()
        hl.dispatch(hl.dsp.window.move({ workspace = ws.id_for(n), follow = true }))
    end, { description = "Window to workspace " .. n })
end

hl.bind(mod .. " + CTRL + H", function()
    local id = ws.neighbour_id(-1, false)
    if id then hl.dispatch(hl.dsp.window.move({ workspace = id, follow = true })) end
end, { description = "Window to previous workspace" })

hl.bind(mod .. " + CTRL + L", function()
    local id = ws.neighbour_id(1, false)
    if id then hl.dispatch(hl.dsp.window.move({ workspace = id, follow = true })) end
end, { description = "Window to next workspace" })

-- Scratchpad: Hyprlands "Minimieren" — Fenster auf den unsichtbaren
-- Special-Workspace packen und per Toggle ein-/ausblenden.
hl.bind(mod .. " + CTRL + S", hl.dsp.window.move({ workspace = "special:scratch" }),
    { description = "Window to scratchpad" })
hl.bind(mod .. " + CTRL + A", hl.dsp.workspace.toggle_special("scratch"),
    { description = "Toggle scratchpad" })

hl.bind(mod .. " + mouse_down", function()
    local id = ws.cycle_existing_id(1)
    if id then hl.dispatch(hl.dsp.focus({ workspace = id })) end
end, { description = "Next workspace" })

hl.bind(mod .. " + mouse_up", function()
    local id = ws.cycle_existing_id(-1)
    if id then hl.dispatch(hl.dsp.focus({ workspace = id })) end
end, { description = "Previous workspace" })
