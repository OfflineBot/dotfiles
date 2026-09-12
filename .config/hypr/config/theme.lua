---- palette: catppuccin mocha -------------------------------------------

-- accent color, shared with quickshell and neovim via ~/.config/theme/accent
-- (two lines: gradient head and tail). the `accent` script cycles it live.
local function read_accent()
    local head, tail = "cba6f7", "eba0ac"
    local f = io.open(os.getenv("HOME") .. "/.config/theme/accent", "r")
    if f then
        local a, b = f:read("l"), f:read("l")
        f:close()
        a = a and a:gsub("[^%x]", "")
        b = b and b:gsub("[^%x]", "")
        if a and #a == 6 then head = a end
        if b and #b == 6 then tail = b end
    end
    return head, tail
end

local accent_head, accent_tail = read_accent()

local colors = {
    active   = { colors = { "rgb(" .. accent_head .. ")", "rgb(" .. accent_tail .. ")" }, angle = 45 },
    inactive = "rgba(3f3f4fff)",
    urgent   = "rgb(f38ba8)",
    bright   = "rgb(cdd6f4)",
    bg       = "rgb(1e1e2e)",
}

hl.config({
    general = {
        gaps_in  = 5,
        gaps_out = 8,

        border_size = 2,

        col = {
            active_border   = colors.active,
            inactive_border = colors.inactive,
        },

        resize_on_border = false,

        layout = "dwindle",
    },

    decoration = {
        rounding       = 6,
        rounding_power = 2,

        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = 0xee11111b,
        },

        blur = {
            enabled    = true,
            size       = 2,
            passes     = 3,
            noise      = 0.05,
            vibrancy   = 0.1696,
            xray       = false,
            popups     = true,
        },
    },

    animations = {
        enabled = true,
    },

    misc = {
        disable_hyprland_logo   = true,
        disable_splash_rendering = true,
        background_color        = colors.bg,
        force_default_wallpaper = 0,

        -- Stirbt der Locker im gesperrten Zustand, darf ein neu gestartetes
        -- hyprlock (Mod+N) die Sperre übernehmen statt auszusperren.
        allow_session_lock_restore = true,
    },
})

return colors
