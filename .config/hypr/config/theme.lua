---- palette: catppuccin mocha -------------------------------------------

local colors = {
    active   = { colors = { "rgb(cba6f7)", "rgb(eba0ac)" }, angle = 45 },
    inactive = "rgb(6c7086)",
    urgent   = "rgb(f38ba8)",
    bright   = "rgb(cdd6f4)",
    bg       = "rgb(1e1e2e)",
}

hl.config({
    general = {
        gaps_in  = 3,
        gaps_out = 5,

        border_size = 2,

        col = {
            active_border   = colors.active,
            inactive_border = colors.inactive,
        },

        resize_on_border = false,
        allow_tearing    = false,

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
    },
})

return colors
