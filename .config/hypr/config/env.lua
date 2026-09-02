local M = {}

---- cursor --------------------------------------------------------------

M.cursor_theme = "catppuccin-mocha-dark-cursors"
M.cursor_size  = "24"

hl.env("XCURSOR_THEME", M.cursor_theme)
hl.env("XCURSOR_SIZE", M.cursor_size)
hl.env("HYPRCURSOR_THEME", M.cursor_theme)
hl.env("HYPRCURSOR_SIZE", M.cursor_size)

---- desktop identity ----------------------------------------------------

hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")

return M
