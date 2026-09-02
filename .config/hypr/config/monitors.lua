hl.monitor({ output = "DP-2", mode = "2560x1440@180.002", position = "1920x0",   scale = 1, transform = 0 })
hl.monitor({ output = "DP-1", mode = "1920x1080@144.001", position = "0x180",    scale = 1, transform = 0 })
hl.monitor({ output = "DP-3", mode = "1280x1024@75.025",  position = "4480x500", scale = 1, transform = 0 })

hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })

local M = {}

M.order = { "DP-1", "DP-2", "DP-3" }

---- neighbouring monitor ------------------------------------------------

local function geom(m)
    local scale = m.scale or 1
    if scale == 0 then scale = 1 end
    return m.x, m.y, m.width / scale, m.height / scale
end

local function beyond(dir, cur, cand)
    local cx, cy, cw, ch = geom(cur)
    local nx, ny, nw, nh = geom(cand)

    if dir == "l" then return nx + nw <= cx end
    if dir == "r" then return nx >= cx + cw end
    if dir == "u" then return ny + nh <= cy end
    if dir == "d" then return ny >= cy + ch end
    return false
end

local function centre_dist(a, b)
    local ax, ay, aw, ah = geom(a)
    local bx, by, bw, bh = geom(b)
    local dx = (ax + aw / 2) - (bx + bw / 2)
    local dy = (ay + ah / 2) - (by + bh / 2)
    return dx * dx + dy * dy
end

function M.neighbour(dir, from)
    local cur = from or hl.get_active_monitor()
    if not cur then return nil end

    local best, best_dist
    for _, m in ipairs(hl.get_monitors()) do
        if m.name ~= cur.name and beyond(dir, cur, m) then
            local d = centre_dist(cur, m)
            if not best_dist or d < best_dist then
                best, best_dist = m, d
            end
        end
    end
    return best
end

function M.describe(from)
    local cur = from or hl.get_active_monitor()
    if not cur then return "no focused monitor" end
    local out = {}
    for _, dir in ipairs({ "l", "r", "u", "d" }) do
        local n = M.neighbour(dir, cur)
        out[#out + 1] = dir .. " -> " .. (n and n.name or "-")
    end
    return cur.name .. ": " .. table.concat(out, "  ")
end

function M.overview_open()
    local layers = hl.get_layers({ namespace = "quickshell-overview" })
    return layers ~= nil and #layers > 0
end

return M
