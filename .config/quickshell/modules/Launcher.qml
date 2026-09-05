import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls

Scope {
    id: root

    property color backgroundColor: "#1e1e2e"
    property color borderColor: "#cdd6f4"
    property color searchBorderColor: "#7f849c"
    property color textColor: "#cdd6f4"
    property color selectionColor: "#cba6f7"
    property real backgroundOpacity: 0.78
    property int borderWidth: 1
    property int cornerRadius: 14

    property int boxWidth: 460
    property int rowH: 36
    property int maxRows: 5

    property bool shown: false

    function toggle() { root.shown = !root.shown }
    function show()   { root.shown = true }
    function hide()   { root.shown = false }

    IpcHandler {
        target: "launcher"
        function toggle() { root.toggle() }
        function show()   { root.show() }
        function hide()   { root.hide() }
    }

    // ---- fullscreen click-catcher (no blur) -------------
    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData
            visible: root.shown
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            aboveWindows: true
            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
            WlrLayershell.namespace: "quickshell-launcher-catch"

            anchors.top: true; anchors.bottom: true
            anchors.left: true; anchors.right: true

            MouseArea {
                anchors.fill: parent
                onClicked: root.hide()
            }
        }
    }

    // ---- the box ----------------------------------------
    PanelWindow {
        id: panel

        visible: root.shown
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        aboveWindows: true
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        WlrLayershell.namespace: "quickshell-launcher"

        property var results: []
        property int selectedIndex: 0
        property string query: ""
        property bool queryIsUrl: false
        property string queryUrl: ""

        readonly property int visibleRows: Math.min(results.length, root.maxRows)
        readonly property int listH: visibleRows * root.rowH
        // Index hinter der Liste = die DuckDuckGo-Zeile unten
        readonly property int totalCount: results.length + (query !== "" ? 1 : 0)

        implicitWidth: root.boxWidth
        implicitHeight: col.implicitHeight + 16
        Behavior on implicitHeight {
            NumberAnimation { duration: 110; easing.type: Easing.OutCubic }
        }

        function fuzzyScore(q, s) {
            let si = 0, score = 0, run = 0, prev = -2
            for (let qi = 0; qi < q.length; qi++) {
                let found = -1
                for (let k = si; k < s.length; k++) {
                    if (s[k] === q[qi]) { found = k; break }
                }
                if (found === -1) return -1
                if (found === prev + 1) { run++; score += 5 + run }
                else run = 0
                if (found === 0 || " -_.".includes(s[found - 1])) score += 10
                score -= (found - si)
                prev = found
                si = found + 1
            }
            return score
        }

        function score(q, e) {
            const name = (e.name || "").toLowerCase()
            if (name === q) return 10000
            if (name.startsWith(q)) return 9000 - name.length
            const words = name.split(/[\s\-_.]+/)
            for (let i = 0; i < words.length; i++)
                if (words[i].startsWith(q)) return 8000 - name.length
            const idx = name.indexOf(q)
            if (idx >= 0) return 7000 - idx * 5 - name.length
            const f = panel.fuzzyScore(q, name)
            if (f >= 0) return 4000 + f
            // Kommentar/Keywords nur als schwacher Notnagel — sonst matcht
            // "steam" jedes Spiel mit "Play this game on Steam" im Comment
            const extra = ((e.genericName || "") + " " + (e.comment || "") + " "
                          + ((e.keywords || []).join(" "))).toLowerCase()
            if (extra.includes(q)) return 500
            return -1
        }

        function fmtNum(v) {
            return String(Math.round(v * 1e10) / 1e10)
        }

        function updateResults() {
            const q = search.text.toLowerCase().trim()
            panel.query = q

            // leer -> nichts anzeigen
            if (q === "") {
                panel.results = []
                panel.selectedIndex = 0
                panel.queryIsUrl = false
                panel.queryUrl = ""
                return
            }

            let items = []

            // Rechner: "6 * 6" -> 36 (Enter kopiert das Ergebnis)
            if (/^[0-9+\-*/(). ,%^]+$/.test(q) && /[0-9]/.test(q)
                && /[+*/%^]/.test(q) || /^-?[0-9.,() ]+-[0-9.,() ]+/.test(q)) {
                try {
                    const expr = q.replace(/,/g, ".").replace(/\^/g, "**")
                    const v = Function('"use strict"; return (' + expr + ')')()
                    if (typeof v === "number" && isFinite(v))
                        items.push({ kind: "calc", name: q + " = " + panel.fmtNum(v),
                                     copy: panel.fmtNum(v), s: 11000 })
                } catch (err) {}
            }

            // sieht die Eingabe wie eine URL aus, wird die Aktions-Zeile
            // unten zum "öffnen" statt zur DuckDuckGo-Suche
            panel.queryIsUrl = q.includes(".") && !q.includes(" ")
                              && q.length > 3 && !/^[0-9.,]+$/.test(q)
            panel.queryUrl = panel.queryIsUrl
                             ? (q.startsWith("http") ? q : "https://" + q) : ""

            // Apps
            const all = DesktopEntries.applications.values
            for (let i = 0; i < all.length; i++) {
                const e = all[i]
                if (e.noDisplay) continue
                const s = panel.score(q, e)
                if (s > -1) items.push({ kind: "app", name: e.name, entry: e, s: s })
            }

            // gibt es starke Treffer, fliegen die schwachen App-Treffer
            // (Comment-Matches, wackelige Fuzzy-Treffer) komplett raus;
            // Aktionen wie Rechner/Web bleiben immer
            const top = items.reduce((m, x) => Math.max(m, x.s), 0)
            if (top >= 7000) items = items.filter(x => x.kind !== "app" || x.s >= 3000)

            items.sort((a, b) => b.s - a.s || a.name.localeCompare(b.name))
            panel.results = items.slice(0, 40)
            panel.selectedIndex = 0
        }

        function openUrl(u) {
            Quickshell.execDetached(["sh", "-c",
                "exec \"$HOME/.config/hypr/scripts/open-url\" \"$1\"", "x", u])
        }

        function move(delta) {
            if (panel.totalCount === 0) return
            panel.selectedIndex = Math.max(0, Math.min(panel.selectedIndex + delta, panel.totalCount - 1))
            if (panel.selectedIndex < panel.results.length)
                list.positionViewAtIndex(panel.selectedIndex, ListView.Contain)
        }

        function cycle(delta) {
            if (panel.totalCount === 0) return
            panel.selectedIndex = (panel.selectedIndex + delta + panel.totalCount) % panel.totalCount
            if (panel.selectedIndex < panel.results.length)
                list.positionViewAtIndex(panel.selectedIndex, ListView.Contain)
        }

        function launchSelected() {
            if (panel.selectedIndex >= panel.results.length) {
                if (panel.queryIsUrl)
                    panel.openUrl(panel.queryUrl)
                else if (panel.query !== "")
                    panel.openUrl("https://duckduckgo.com/?q=" + encodeURIComponent(panel.query))
                root.hide()
                return
            }
            const r = panel.results[panel.selectedIndex]
            if (r.kind === "app") r.entry.execute()
            else if (r.kind === "web") panel.openUrl(r.url)
            else if (r.kind === "calc")
                Quickshell.execDetached(["sh", "-c", "printf %s " + JSON.stringify(r.copy) + " | wl-copy"])
            root.hide()
        }

        onVisibleChanged: {
            if (visible) {
                search.text = ""
                updateResults()
                search.forceActiveFocus()
            }
        }

        Component.onCompleted: panel.updateResults()

        Connections {
            target: DesktopEntries.applications
            function onValuesChanged() { panel.updateResults() }
        }

        Rectangle {
            id: box
            anchors.fill: parent
            color: Qt.rgba(root.backgroundColor.r, root.backgroundColor.g,
                           root.backgroundColor.b, root.backgroundOpacity)
            radius: root.cornerRadius
            border.color: Qt.rgba(root.borderColor.r, root.borderColor.g,
                                  root.borderColor.b, 0.3)
            border.width: root.borderWidth

            opacity: 0
            scale: 0.98
            transformOrigin: Item.Top
            states: State {
                name: "on"; when: root.shown
                PropertyChanges { target: box; opacity: 1; scale: 1 }
            }
            transitions: Transition {
                NumberAnimation { properties: "opacity,scale"; duration: 130; easing.type: Easing.OutQuad }
            }

            Column {
                id: col
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 8
                spacing: 6

                TextField {
                    id: search
                    width: parent.width
                    placeholderText: "Search…"
                    placeholderTextColor: Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.4)
                    color: root.textColor
                    font.pixelSize: 17
                    padding: 10
                    leftPadding: 12

                    // Spotlight-Look: keine eigene Box, nur Text
                    background: null

                    onTextChanged: panel.updateResults()

                    Keys.onDownPressed:   panel.move(1)
                    Keys.onUpPressed:     panel.move(-1)
                    Keys.onTabPressed:    panel.cycle(1)
                    Keys.onBacktabPressed: panel.cycle(-1)
                    Keys.onReturnPressed: panel.launchSelected()
                    Keys.onEnterPressed:  panel.launchSelected()
                    Keys.onEscapePressed: root.hide()
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    visible: panel.query !== ""
                    color: Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.12)
                }

                ListView {
                    id: list
                    width: parent.width
                    height: panel.listH
                    visible: panel.results.length > 0
                    clip: true
                    model: panel.results

                    delegate: Rectangle {
                        id: item
                        required property var modelData
                        required property int index

                        width: list.width
                        height: root.rowH
                        radius: 6
                        color: index === panel.selectedIndex ? root.selectionColor : "transparent"

                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            spacing: 8

                            IconImage {
                                anchors.verticalCenter: parent.verticalCenter
                                visible: item.modelData.kind === "app"
                                implicitSize: 20
                                source: item.modelData.kind === "app"
                                        ? Quickshell.iconPath(item.modelData.entry.icon, true) : ""
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                visible: item.modelData.kind !== "app"
                                text: item.modelData.kind === "calc" ? "󰃬" : "󰖟"
                                font.family: "MesloLGS Nerd Font Mono"
                                font.pixelSize: 17
                                color: item.index === panel.selectedIndex
                                       ? root.backgroundColor : root.selectionColor
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: item.modelData.name
                                font.pixelSize: 14
                                color: item.index === panel.selectedIndex ? root.backgroundColor : root.textColor
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onPositionChanged: panel.selectedIndex = item.index
                            onClicked: {
                                panel.selectedIndex = item.index
                                panel.launchSelected()
                            }
                        }
                    }
                }

                // ---- Aktion als eigene, abgesetzte Zeile darunter ----
                Item {
                    width: parent.width
                    height: 4
                    visible: panel.query !== ""
                }

                Rectangle {
                    id: searchAction
                    width: parent.width
                    height: root.rowH
                    visible: panel.query !== ""
                    radius: 6
                    color: panel.selectedIndex >= panel.results.length
                           ? root.selectionColor : "transparent"

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        spacing: 8

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: panel.queryIsUrl ? "󰖟" : "󰍉"
                            font.family: "MesloLGS Nerd Font Mono"
                            font.pixelSize: 17
                            color: panel.selectedIndex >= panel.results.length
                                   ? root.backgroundColor : root.selectionColor
                        }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: panel.queryIsUrl ? panel.query + " öffnen"
                                                   : "Mit DuckDuckGo suchen: " + panel.query
                            font.pixelSize: 14
                            elide: Text.ElideRight
                            width: searchAction.width - 50
                            color: panel.selectedIndex >= panel.results.length
                                   ? root.backgroundColor : root.textColor
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onPositionChanged: panel.selectedIndex = panel.results.length
                        onClicked: {
                            panel.selectedIndex = panel.results.length
                            panel.launchSelected()
                        }
                    }
                }
            }
        }
    }
}
