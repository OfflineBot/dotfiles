local p   = require("config.programs")
local mod = p.mainMod

local stamp = [[$(date '+%Y-%m-%d %H-%M-%S')]]

local function fileIn(dir)
    return '"' .. dir .. '/Screenshot from ' .. stamp .. '.png"'
end

local region = 'mkdir -p "' .. p.screenshotDir .. '" && grim -g "$(slurp)" ' .. fileIn(p.screenshotDir)

local screen = 'mkdir -p "' .. p.screenshotDir .. '" && grim -o "' .. p.focusedMonitor .. '" '
    .. fileIn(p.screenshotDir)

local activeGeom =
    [[$(hyprctl -j activewindow | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')]]
local window = 'mkdir -p "' .. p.screenshotDir .. '" && grim -g "' .. activeGeom .. '" '
    .. fileIn(p.screenshotDir)


local regionClip = 'grim -g "$(slurp)" - | wl-copy'

hl.bind("Print", hl.dsp.exec_cmd(region),
    { description = "Screenshot: region" })
hl.bind("SHIFT + Print", hl.dsp.exec_cmd(regionClip),
    { description = "Screenshot: region to clipboard" })
hl.bind("CTRL + Print", hl.dsp.exec_cmd(screen),
    { description = "Screenshot: whole monitor" })
hl.bind("ALT + Print", hl.dsp.exec_cmd(window),
    { description = "Screenshot: active window" })
hl.bind(mod .. " + Print",
    hl.dsp.exec_cmd("$HOME/.config/hypr/scripts/screenshot-menu.sh"),
    { description = "Screenshot: menu (clipboard/save/save as)" })
hl.bind(mod .. " + SHIFT + Print", hl.dsp.exec_cmd(region),
    { description = "Screenshot: region" })
