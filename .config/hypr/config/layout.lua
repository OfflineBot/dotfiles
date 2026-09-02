hl.config({
    dwindle = {
        preserve_split = true,

        smart_split = false,

        force_split = 0,

        smart_resizing = true,
    },

    master = { new_status = "master" },
})

---- scrolling (inert) ---------------------------------------------------

hl.config({
    scrolling = {
        column_width = 0.5,

        explicit_column_widths = "0.333, 0.5, 0.667",

        focus_fit_method = 1,

        fullscreen_on_one_column = true,

        follow_focus       = true,
        follow_min_visible = 0.4,

        wrap_focus   = true,
        wrap_swapcol = true,

        direction = "right",
    },
})

hl.config({
    misc = {
        disable_autoreload = false,
    },
    binds = {
        scroll_event_delay = 0,

        window_direction_monitor_fallback = false,
    },
})
