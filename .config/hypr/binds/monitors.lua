local p    = require("config.programs")
local mons = require("config.monitors")

local dirs = {
    H = { "l", "left"  },
    L = { "r", "right" },
    K = { "u", "up"    },
    J = { "d", "down"  },
}

---- direct selection ----------------------------------------------------

for i, name in ipairs(mons.order) do
    local key = tostring(i)

    hl.bind("ALT + " .. key, function()
        if mons.overview_open() then
            hl.exec_cmd(p.qs("overview", "monitor", name))
        else
            hl.dispatch(hl.dsp.focus({ monitor = name }))
        end
    end, { description = "Monitor " .. name })

    hl.bind("ALT + SHIFT + " .. key, function()
        for _, m in ipairs(hl.get_monitors()) do
            if m.name == name and m.active_workspace then
                hl.dispatch(hl.dsp.window.move({
                    workspace = m.active_workspace.id, follow = true }))
                return
            end
        end
    end, { description = "Window to monitor " .. name })
end

for key, spec in pairs(dirs) do
    local dir, label = spec[1], spec[2]

    hl.bind("ALT + " .. key, function()
        local m = mons.neighbour(dir)
        if not m then return end

        if mons.overview_open() then
            hl.exec_cmd(p.qs("overview", "monitor", m.name))
        else
            hl.dispatch(hl.dsp.focus({ monitor = m.name }))
        end
    end, { description = "Monitor " .. label })

    hl.bind("ALT + SHIFT + " .. key, function()
        local m = mons.neighbour(dir)
        if not m then return end
        local target = m.active_workspace
        if not target then return end
        hl.dispatch(hl.dsp.window.move({ workspace = target.id, follow = true }))
    end, { description = "Window to monitor " .. label })
end
