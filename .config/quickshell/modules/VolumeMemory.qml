pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import QtQuick

// Merkt sich pro App die eingestellte Stream-Lautstärke und wendet sie auf
// jeden neuen Stream der App wieder an. Nötig, weil z.B. Firefox für jedes
// Medium einen frischen Stream mit Standardlautstärke anlegt und kein
// MPRIS-Volume unterstützt. Persistiert in ~/.cache/quickshell-app-volumes.json.
Singleton {
    id: root

    readonly property var streams:
        [...Pipewire.nodes.values].filter(n => n.isStream && n.audio)

    PwObjectTracker { objects: root.streams }

    function appOf(n) {
        return (n.nickname || n.description || n.name || "").toLowerCase()
    }

    function remember(app, v) {
        if (!app) return
        data.volumes = Object.assign({}, data.volumes, { [app]: v })
        store.writeAdapter()
    }

    function applyAll() {
        for (const n of root.streams) {
            const v = data.volumes[root.appOf(n)]
            if (v !== undefined && n.audio && Math.abs(n.audio.volume - v) > 0.01)
                n.audio.volume = v
        }
    }

    onStreamsChanged: applyTimer.restart()

    // kleiner Aufschub: frisch aufgetauchte Nodes haben ihre Audio-Props
    // oft erst nach ein paar hundert ms
    Timer {
        id: applyTimer
        interval: 400
        onTriggered: root.applyAll()
    }

    FileView {
        id: store
        path: Quickshell.env("HOME") + "/.cache/quickshell-app-volumes.json"
        watchChanges: false

        JsonAdapter {
            id: data
            property var volumes: ({})
        }
    }
}
