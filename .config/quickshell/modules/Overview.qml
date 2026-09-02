import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick

Scope {
    id: root

    property color backgroundColor: "#11121a"
    property color borderColor: "#d5dde8"
    property color textColor: "#d5dde8"
    property color accentColor: "#8ec07b"
    property real backgroundOpacity: 0.93

    property bool open: false

    property string activeScreen: ""

    signal navigate(string dir)

    function show() {
        Hyprland.refreshToplevels()
        Hyprland.refreshWorkspaces()
        root.activeScreen = Hyprland.focusedMonitor ? Hyprland.focusedMonitor.name : ""
        root.open = true
    }
    function hide()   { root.open = false }
    function toggle() { root.open ? root.hide() : root.show() }

    IpcHandler {
        target: "overview"
        function toggle() { root.toggle() }
        function open()   { root.show() }
        function close()  { root.hide() }
        function move(dir: string) { root.navigate(dir) }

        function monitor(name: string) {
            if ([...Quickshell.screens].some(s => s.name === name))
                root.activeScreen = name
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win
            required property var modelData
            screen: modelData

            visible: root.open
            color: "transparent"

            anchors { top: true; left: true; right: true; bottom: true }
            exclusionMode: ExclusionMode.Ignore

            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "quickshell-overview"
            WlrLayershell.keyboardFocus: (root.open && win.isActiveScreen)
                ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

            readonly property var hMon:
                [...Hyprland.monitors.values].find(m => m.name === modelData.name) ?? null
            readonly property bool isFocusedScreen:
                Hyprland.focusedMonitor ? Hyprland.focusedMonitor.name === modelData.name : false
            readonly property bool isActiveScreen: root.activeScreen !== ""
                ? root.activeScreen === modelData.name : win.isFocusedScreen

            readonly property int base:
                hMon && hMon.activeWorkspace ? Ws.baseOf(hMon.activeWorkspace.id) : 0

            readonly property var slots: {
                const used = []
                for (const t of Hyprland.toplevels.values) {
                    if (!t.workspace || !t.monitor) continue
                    if (t.monitor.name !== modelData.name) continue
                    const s = Ws.display(t.workspace.id)
                    if (s >= 1 && !used.includes(s)) used.push(s)
                }
                const active = hMon && hMon.activeWorkspace
                    ? Ws.display(hMon.activeWorkspace.id) : 1
                if (!used.includes(active)) used.push(active)
                for (let i = 1; i <= Ws.perMonitor; i++) {
                    if (!used.includes(i)) { used.push(i); break }
                }
                used.sort((a, b) => a - b)
                return used
            }

            readonly property real gap: 14
            readonly property real pad: 36
            readonly property real headerH: 28

            readonly property real monW: hMon ? hMon.width / hMon.scale : width
            readonly property real monH: hMon ? hMon.height / hMon.scale : height
            readonly property real aspect: monH > 0 ? monW / monH : 1.6

            readonly property var grid: {
                const n = Math.max(1, slots.length)
                const availH = height - 2 * pad - headerH
                let best = null
                for (let c = 1; c <= n; c++) {
                    const r = Math.ceil(n / c)
                    const tw = (width - 2 * pad - (c - 1) * gap) / c
                    const th = tw / aspect
                    if (r * th + (r - 1) * gap > availH) continue
                    if (!best || tw > best.w) best = { cols: c, rows: r, w: tw, h: th }
                }
                if (!best) {
                    const tw = (width - 2 * pad - (n - 1) * gap) / n
                    best = { cols: n, rows: 1, w: tw, h: tw / aspect }
                }
                return best
            }
            readonly property int cols: grid.cols
            readonly property int rows: grid.rows
            readonly property real tileW: Math.max(40, grid.w)
            readonly property real tileH: Math.max(30, grid.h)

            property int sel: 0

            onSlotsChanged: win.syncSel()
            Connections {
                target: root
                function onOpenChanged() { if (root.open) win.syncSel() }
                function onNavigate(dir) { if (win.isActiveScreen) win.moveSel(dir) }
            }

            function syncSel() {
                const active = hMon && hMon.activeWorkspace
                    ? Ws.display(hMon.activeWorkspace.id) : 1
                const i = slots.indexOf(active)
                win.sel = i >= 0 ? i : 0
            }

            function moveSel(dir) {
                const n = win.slots.length
                if (n === 0) return
                let i = win.sel

                if (dir === "h") {
                    i = Math.max(0, i - 1)
                } else if (dir === "l") {
                    i = Math.min(n - 1, i + 1)
                } else {
                    const rowLen = r => Math.min(win.cols, n - r * win.cols)
                    const offset = r => (win.cols - rowLen(r)) / 2
                    const row = Math.floor(i / win.cols)
                    const target = row + (dir === "j" ? 1 : -1)
                    if (target < 0 || target * win.cols >= n) return
                    const vx = (i % win.cols) + offset(row)
                    const c = Math.max(0, Math.min(rowLen(target) - 1,
                        Math.round(vx - offset(target))))
                    i = target * win.cols + c
                }
                win.sel = i
            }

            property string pending: ""

            function run(cmd) {
                win.pending = cmd
                root.hide()
                settle.restart()
            }

            Timer {
                id: settle
                interval: 80
                onTriggered: {
                    if (win.pending === "") return
                    Hyprland.dispatch(win.pending)
                    win.pending = ""
                }
            }

            function goto(slot) {
                win.run("hl.dsp.focus({ workspace = " + (win.base + slot) + " })")
            }

            function focusWindow(addr) {
                const sel = addr.startsWith("0x") ? addr : "0x" + addr
                win.run('hl.dsp.focus({ window = "address:' + sel + '" })')
            }

            Rectangle {
                anchors.fill: parent
                color: root.backgroundColor
                opacity: root.backgroundOpacity
                MouseArea { anchors.fill: parent; onClicked: root.hide() }
            }

            Loader {
                id: contentLoader
                anchors.fill: parent
                active: root.open
                sourceComponent: content

                focus: true
                onLoaded: if (win.isActiveScreen) item.forceActiveFocus()

                Connections {
                    target: win
                    function onIsActiveScreenChanged() {
                        if (win.isActiveScreen && contentLoader.item)
                            contentLoader.item.forceActiveFocus()
                    }
                }
            }

            Component {
                id: content

                FocusScope {
                    anchors.fill: parent
                    focus: true

                    Keys.onPressed: event => {
                        const k = event.key
                        if (k === Qt.Key_Escape) {
                            root.hide()
                        } else if (k === Qt.Key_Return || k === Qt.Key_Enter
                                   || k === Qt.Key_Space) {
                            win.goto(win.slots[win.sel])
                        } else if (k === Qt.Key_H || k === Qt.Key_Left) {
                            win.moveSel("h")
                        } else if (k === Qt.Key_L || k === Qt.Key_Right) {
                            win.moveSel("l")
                        } else if (k === Qt.Key_J || k === Qt.Key_Down) {
                            win.moveSel("j")
                        } else if (k === Qt.Key_K || k === Qt.Key_Up) {
                            win.moveSel("k")
                        } else if (k >= Qt.Key_1 && k <= Qt.Key_9) {
                            win.goto(k - Qt.Key_0)
                        } else if (k === Qt.Key_0) {
                            win.goto(Ws.perMonitor)
                        } else {
                            return
                        }
                        event.accepted = true
                    }

                    Column {
                        anchors.centerIn: parent
                        spacing: win.gap

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            height: win.headerH
                            verticalAlignment: Text.AlignVCenter
                            text: win.modelData.name
                            color: root.textColor
                            opacity: win.isActiveScreen ? 0.75 : 0.25
                            font.pixelSize: 13
                            font.family: "FiraCode Nerd Font Mono"
                        }

                        Repeater {
                            model: win.rows

                            delegate: Row {
                                id: gridRow
                                required property int index
                                readonly property int first: index * win.cols
                                readonly property int count:
                                    Math.max(0, Math.min(win.cols, win.slots.length - first))

                                anchors.horizontalCenter: parent.horizontalCenter
                                spacing: win.gap

                                Repeater {
                                    model: gridRow.count

                                    delegate: OverviewTile {
                                        required property int index
                                        readonly property int pos: gridRow.first + index

                                        slot: win.slots[pos]
                                        wsId: win.base + slot
                                        hMon: win.hMon
                                        monW: win.monW
                                        monH: win.monH
                                        selected: win.isActiveScreen && win.sel === pos
                                        width: win.tileW
                                        height: win.tileH
                                        live: root.open

                                        textColor: root.textColor
                                        borderColor: root.borderColor
                                        accentColor: root.accentColor
                                        windowBackdrop: Qt.lighter(root.backgroundColor, 1.35)

                                        onActivated: win.goto(slot)
                                        onWindowPicked: addr => win.focusWindow(addr)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
