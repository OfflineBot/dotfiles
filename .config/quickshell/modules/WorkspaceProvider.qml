import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick

Scope {
    id: root

    property var workspaces: []

    // true while a special workspace (scratchpad) is shown/focused, plus the
    // monitor it sits on. the bar tints that monitor's active chip instead of
    // adding a scratch chip that would reflow the row.
    property bool scratchVisible: false
    property string focusedOutput: ""

    // ---- hyprland per-monitor blocks --------------------
    readonly property int hyprPerMonitor: Ws.perMonitor

    function hyprDisplayIndex(id) {
        return Ws.display(id)
    }

    readonly property string backend:
        Quickshell.env("NIRI_SOCKET") ? "niri"
        : Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE") ? "hyprland"
        : (Quickshell.env("XDG_SESSION_DESKTOP") === "mango"
           || Quickshell.env("DESKTOP_SESSION") === "mango") ? "mango"
        : "none"

    function focus(ws) {
        if (root.backend === "niri") {
            const ref = (ws.name && ws.name.length) ? ws.name : String(ws.idx)
            Quickshell.execDetached(["niri", "msg", "action", "focus-workspace", ref])
        } else if (root.backend === "hyprland") {
            const sel = ws.id < 0 ? JSON.stringify(ws.hyprName) : String(ws.id)
            Hyprland.dispatch("hl.dsp.focus({ workspace = " + sel + " })")
        } else if (root.backend === "mango") {
            Quickshell.execDetached(["mmsg", "-s", "-d", "view," + String(ws.idx)])
        }
    }

    // ---- niri -------------------------------------------
    Process {
        id: niriProc
        running: root.backend === "niri"
        command: ["niri", "msg", "--json", "event-stream"]
        stdout: SplitParser { onRead: line => root._onNiriLine(line) }
    }

    function _onNiriLine(line) {
        let ev
        try { ev = JSON.parse(line) } catch (e) { return }

        if (ev.WorkspacesChanged) {
            const ws = ev.WorkspacesChanged.workspaces.map(w => ({
                id: w.id, idx: w.idx, name: w.name, output: w.output,
                active: w.is_active, focused: w.is_focused
            }))
            ws.sort((a, b) => (a.output || "").localeCompare(b.output || "") || a.idx - b.idx)
            root.workspaces = ws
        } else if (ev.WorkspaceActivated) {
            const id = ev.WorkspaceActivated.id
            const focused = ev.WorkspaceActivated.focused
            const cur = root.workspaces.slice()
            const target = cur.find(w => w.id === id)
            if (!target) return
            for (let w of cur) {
                if (w.output === target.output) {
                    w.active = (w.id === id)
                    if (focused) w.focused = (w.id === id)
                }
            }
            root.workspaces = cur
        }
    }

    // ---- mango ------------------------------------------
    Process {
        id: mangoProc
        running: root.backend === "mango"
        command: ["mmsg", "-w", "-t", "-o"]
        stdout: SplitParser { onRead: line => root._onMangoLine(line) }
    }

    property var _mangoMons: ({})

    function _onMangoLine(line) {
        const p = line.trim().split(/\s+/)
        if (p.length < 3) return
        const mons = root._mangoMons
        const m = mons[p[0]] || (mons[p[0]] = { selmon: false, tags: {} })

        if (p[1] === "selmon") {
            m.selmon = p[2] === "1"
        } else if (p[1] === "tag" && p.length >= 5) {
            const state = parseInt(p[3])
            m.tags[parseInt(p[2])] = {
                active: (state & 1) !== 0,
                urgent: (state & 2) !== 0,
                clients: parseInt(p[4])
            }
        } else if (p[1] === "tags") {
            root._rebuildMango()
        }
    }

    function _rebuildMango() {
        const ws = []
        for (const mon in root._mangoMons) {
            const m = root._mangoMons[mon]
            for (const key in m.tags) {
                const t = m.tags[key]
                if (!t.active && t.clients <= 0) continue
                const idx = parseInt(key)
                ws.push({
                    id: mon + ":" + idx,
                    idx: idx,
                    name: "",
                    output: mon,
                    active: t.active,
                    focused: t.active && m.selmon,
                    urgent: t.urgent,
                    occupied: t.clients > 0
                })
            }
        }
        ws.sort((a, b) => (a.output || "").localeCompare(b.output || "") || a.idx - b.idx)
        root.workspaces = ws
    }

    // ---- hyprland ---------------------------------------
    Connections {
        enabled: root.backend === "hyprland"
        target: Hyprland.workspaces
        function onValuesChanged() { root._syncHyprland() }
    }
    Connections {
        enabled: root.backend === "hyprland"
        target: Hyprland
        function onFocusedWorkspaceChanged() { root._syncHyprland() }
    }
    Component.onCompleted: if (root.backend === "hyprland") root._syncHyprland()

    // a special workspace is an overlay that never changes the focused
    // workspace, so its visibility is tracked from hyprland's activespecial
    // event ("name,monitor"; an empty name means it was hidden)
    function _applyScratch(data) {
        const c = data.indexOf(",")
        const name = c >= 0 ? data.slice(0, c) : data
        root.scratchVisible = name.length > 0
        root.focusedOutput = name.length > 0 ? (c >= 0 ? data.slice(c + 1) : "") : ""
    }

    Connections {
        enabled: root.backend === "hyprland"
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "activespecial") root._applyScratch(event.data)
        }
    }

    function _syncHyprland() {
        const fw = Hyprland.focusedWorkspace
        const focusedId = fw ? fw.id : 0

        // special workspaces (id < 0) never get a chip of their own
        const ws = [...Hyprland.workspaces.values].filter(w => w.id >= 0).map(w => ({
            id: w.id,
            idx: root.hyprDisplayIndex(w.id),
            name: "",
            hyprName: w.name,
            output: w.monitor ? w.monitor.name : "",
            active: w.monitor && w.monitor.activeWorkspace
                    ? w.monitor.activeWorkspace.id === w.id : false,
            focused: w.id === focusedId
        }))
        ws.sort((a, b) => (a.output || "").localeCompare(b.output || "") || a.idx - b.idx)
        root.workspaces = ws
    }
}
