local env = require("config.env")

hl.on("hyprland.start", function()
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("quickshell")

    hl.exec_cmd("dbus-update-activation-environment --systemd "
        .. "WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP "
        .. "XDG_SESSION_TYPE HYPRLAND_INSTANCE_SIGNATURE")

    hl.exec_cmd("systemctl --user restart xdg-desktop-portal.service")

    hl.exec_cmd("gsettings set org.gnome.desktop.interface gtk-theme 'catppuccin-mocha-maroon-standard+default'")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'")

    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-theme '" .. env.cursor_theme .. "'")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-size " .. env.cursor_size)

    -- EasyEffects läuft über die (enablete) systemd-User-Unit, nicht mehr hier.

    -- Clipboard: überlebt das Schließen der Quell-App + History für Mod+Shift+V.
    -- Guards, damit vor der Installation der Tools nichts fehlschlägt.
    hl.exec_cmd("sh -c 'command -v wl-clip-persist >/dev/null && exec wl-clip-persist --clipboard regular'")
    hl.exec_cmd("sh -c 'command -v cliphist >/dev/null && exec wl-paste --type text --watch cliphist store'")
    hl.exec_cmd("sh -c 'command -v cliphist >/dev/null && exec wl-paste --type image --watch cliphist store'")
end)
