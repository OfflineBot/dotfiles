---- hyprglass (Liquid Glass) ---------------------------------------------

local plugin_so = (os.getenv("HOME") or "") .. "/.local/src/hyprglass/hyprglass.so"

-- Load on startup; the subsequent reload lets the guard below kick in
-- (same pattern as `hyprpm reload -n`).
hl.on("hyprland.start", function()
    hl.exec_cmd("hyprctl plugin load " .. plugin_so .. " && hyprctl reload")
end)

if hl.plugin.hyprglass then
    local hg = hl.plugin.hyprglass

    hg.config({
        default_theme  = "dark",
        default_preset = "default",

        refraction_strength  = 0.9,
        chromatic_aberration = 0.9,
        lens_distortion      = 0.8,
        edge_thickness       = 0.10,

        blur_strength     = 1.0,
        blur_iterations   = 2,
        specular_strength = 0.70,
        fresnel_strength  = 0.50,
        tint_color        = 0x1e1e2e10,

        saturation   = 1.0,
        vibrancy     = 0.90,
        contrast     = 1.2,
        brightness   = 0.85,
        adaptive_dim = 0.4,
    })
end

-- The glass is drawn behind the window, so it only shows through translucent
-- ones: kitty (own background alpha) and empty firefox windows (rules.lua).
-- Everything else stays opaque via theme.lua.

-- Fullscreen (videos, games): no glass, full opacity. Kitty is exempt —
-- its own background alpha would show a flat grey backdrop without glass.
hl.window_rule({
    name  = "fullscreen-no-glass",
    match = { fullscreen = true, class = "negative:^kitty$" },

    tag     = "+hyprglass_disabled",
    opacity = 1.0,
})

-- "+" tags stick after the rule stops matching, so strip it again
-- once the window leaves fullscreen.
hl.window_rule({
    name  = "restore-glass-after-fullscreen",
    match = { fullscreen = false },

    tag = "-hyprglass_disabled",
})
