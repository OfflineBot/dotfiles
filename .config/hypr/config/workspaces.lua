local M = {}

M.per_monitor = 10

M.monitors = { "DP-2", "DP-1", "DP-3" }

M.persistent = false

local block_of = {}
for i, name in ipairs(M.monitors) do
    block_of[name] = i - 1
end

function M.base(monitor)
    if not monitor then return 0 end
    local block = block_of[monitor.name]
    if not block then
        block = #M.monitors + (monitor.id or 0)
    end
    return block * M.per_monitor
end

function M.id_for(n)
    return M.base(hl.get_active_monitor()) + n
end

function M.display(id)
    if id < 1 then return id end
    return ((id - 1) % M.per_monitor) + 1
end

function M.current_display()
    local ws = hl.get_active_workspace()
    if not ws then return 1 end
    return M.display(ws.id)
end

function M.neighbour_id(delta, wrap)
    local n = M.current_display() + delta

    if wrap then
        n = ((n - 1) % M.per_monitor) + 1
    elseif n < 1 or n > M.per_monitor then
        return nil
    end

    return M.id_for(n)
end

function M.cycle_existing_id(delta)
    local mon = hl.get_active_monitor()
    local cur = hl.get_active_workspace()
    if not mon or not cur then return nil end

    local ids = {}
    for _, w in ipairs(hl.get_workspaces()) do
        if w.id > 0 and w.monitor and w.monitor.name == mon.name then
            ids[#ids + 1] = w.id
        end
    end
    if #ids < 2 then return nil end
    table.sort(ids)

    local pos
    for i, id in ipairs(ids) do
        if id == cur.id then pos = i break end
    end
    if not pos then return nil end

    return ids[((pos - 1 + delta) % #ids) + 1]
end

function M.existing_neighbour_id(delta)
    local mon = hl.get_active_monitor()
    local cur = hl.get_active_workspace()
    if not mon or not cur then return nil end

    local ids = {}
    for _, w in ipairs(hl.get_workspaces()) do
        if w.id > 0 and w.monitor and w.monitor.name == mon.name then
            ids[#ids + 1] = w.id
        end
    end
    table.sort(ids)

    for i, id in ipairs(ids) do
        if id == cur.id then return ids[i + delta] end
    end
    return nil
end

for _, name in ipairs(M.monitors) do
    local base = block_of[name] * M.per_monitor
    for n = 1, M.per_monitor do
        hl.workspace_rule({
            workspace  = tostring(base + n),
            monitor    = name,
            default    = (n == 1) or nil,
            persistent = M.persistent or nil,
        })
    end
end

return M
