---- palette -------------------------------------------------------------

local colors = {
    active   = "rgb(a4a9a8)",
    inactive = "rgb(484848)",
    urgent   = "rgb(ad401f)",
    bright   = "rgb(d4c9c8)",
    bg       = "rgb(201b14)",
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
            color        = 0xee1a1a1a,
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
