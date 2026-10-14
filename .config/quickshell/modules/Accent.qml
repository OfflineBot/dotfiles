pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Single source for the accent color. Reads ~/.config/theme/accent (first
// line = hex), the same file hyprland and neovim read, and updates live when
// the `accent` script cycles it.
Singleton {
    id: root

    property color color: "#cba6f7"

    function parse(s) {
        const t = (s || "").split("\n")[0].trim().replace(/[^0-9a-fA-F]/g, "")
        if (t.length >= 6)
            root.color = "#" + t.substring(0, 6)
    }

    FileView {
        id: file
        path: Quickshell.env("HOME") + "/.config/theme/accent"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.parse(text())
        // the file only exists once `accent` ran; a missing file can't be
        // watched, so poll until it shows up.
        onLoadFailed: retry.start()
    }

    Timer {
        id: retry
        interval: 2000
        onTriggered: file.reload()
    }
}
