---- window rules --------------------------------------------------------

hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})

hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_initial_focus = true,
})

hl.window_rule({
    name  = "kitty-xray-blur",
    match = { class = "^kitty$" },

    xray = true,
})

hl.window_rule({
    name  = "firefox-xray-blur",
    match = { class = "firefox$", title = "negative:^Picture-in-Picture$" },

    xray = true,
})


hl.window_rule({
    name  = "firefox-pip-float",
    match = { class = "firefox$", title = "^Picture-in-Picture$" },

    float = true,
    pin   = true,
})

-- glass only on empty windows; any loaded page changes the title and goes opaque
hl.window_rule({
    name  = "firefox-opaque",
    match = { class = "firefox$" },

    opacity = "1.0 override 1.0 override",
})

hl.window_rule({
    name  = "firefox-glass-when-empty",
    match = { class = "firefox$", title = "^(Mozilla Firefox|Neuer Tab.*|New Tab.*)$" },

    opacity = "0.92 override 0.85 override",
})


hl.window_rule({
    name  = "xwaylandvideobridge",
    match = { class = "^xwaylandvideobridge$" },

    float            = true,
    no_initial_focus = true,
})


hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    float = true,
    move  = { 20, "monitor_h-120" },
})

---- layer rules ---------------------------------------------------------

hl.layer_rule({
    name  = "blur-quickshell-bar",
    match = { namespace = "^quickshell-bar$" },
    blur  = true,
})

for _, ns in ipairs({ "quickshell-clockpopup", "quickshell-network", "quickshell-launcher" }) do
    hl.layer_rule({
        name  = "blur-" .. ns,
        match = { namespace = "^" .. ns .. "$" },
        blur  = true,
    })
end

hl.layer_rule({
    name  = "blur-quickshell-overview",
    match = { namespace = "^quickshell-overview$" },
    blur  = true,
})

hl.layer_rule({
    name  = "blur-quickshell-tip",
    match = { namespace = "^quickshell-tip$" },
    blur  = true,
})

hl.layer_rule({
    name  = "blur-quickshell-logout",
    match = { namespace = "^quickshell-logout$" },
    blur  = true,
})

hl.layer_rule({
    name  = "blur-notifications",
    match = { namespace = "^notifications$" },
    blur  = true,
})

hl.layer_rule({
    name  = "blur-launcher",
    match = { namespace = "^launcher$" },
    blur  = true,
})
