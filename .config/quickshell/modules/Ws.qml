pragma Singleton

import Quickshell

Singleton {
    id: root

    readonly property int perMonitor: 10

    function display(id) {
        return id < 1 ? id : ((id - 1) % root.perMonitor) + 1
    }

    function baseOf(id) {
        return id < 1 ? 0 : Math.floor((id - 1) / root.perMonitor) * root.perMonitor
    }
}
