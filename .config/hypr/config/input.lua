hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "altgr-intl",
        kb_options = "compose:rctrl,lv3:ralt_switch",
        kb_model   = "",
        kb_rules   = "",

        numlock_by_default = true,

        repeat_delay = 600,
        repeat_rate  = 25,

        follow_mouse = 1,

        sensitivity   = -0.7,
        accel_profile = "flat",

        touchpad = {
            tap_to_click   = true,
            natural_scroll = true,
        },
    },
})

hl.config({
    cursor = {
        warp_on_change_workspace = 2,
    },
})

hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})
