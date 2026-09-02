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

    hl.exec_cmd("flatpak run com.github.wwmm.easyeffects --gapplication-service")
end)
