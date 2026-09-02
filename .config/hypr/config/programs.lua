local M = {}

M.mainMod = "SUPER"

M.terminal    = "kitty"
M.browser     = "firefox"
M.mixer       = "pavucontrol"
M.fileManager = "nautilus"

M.lock       = "hyprlock"
M.altLock    = "swaylock"
M.brightness = "brightnessctl"

M.vpnMenu = "$HOME/.local/bin/vpn-menu"

M.wallpaper = "$HOME/.config/hypr/scripts/wallpaper.sh"

M.screenshotDir      = "$HOME/Pictures/Screenshots"
M.screenshotDirSuper = "$HOME/Pictures/Screenshots-Super"

M.focusedMonitor = [[$(hyprctl -j monitors | jq -r '.[] | select(.focused) | .name')]]

function M.qs(...)
    local parts = { "qs", "ipc", "call" }
    for _, arg in ipairs({ ... }) do
        parts[#parts + 1] = arg
    end
    return table.concat(parts, " ")
end

function M.qsOnFocusedMonitor(...)
    return M.qs(...) .. ' "' .. M.focusedMonitor .. '"'
end

function M.player(action)
    return "$HOME/.config/hypr/scripts/player.sh " .. action
end

return M
