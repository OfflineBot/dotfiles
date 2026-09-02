import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Layouts

Scope {
    id: root
    required property var modelData

    property color backgroundColor: "#11121a"
    property color borderColor: "#d5dde8"
    property color textColor: "#d5dde8"
    property color accentColor: "#8ec07b"
    property color mutedColor: "#fb4833"
    property real backgroundOpacity: 0.65
    property int barHeight: 30
    property int barMargin: 8
    property bool active: false

    property int boxW: 410
    property int gap: 8
    property int radius: 14

    signal dismissed()

    // ---- brightness (brightnessctl, backlight class) ----
    property bool brightnessAvailable: false
    property real brightness: 0
    property bool brightnessDragging: false

    function setBrightness(v) {
        const pct = Math.round(Math.max(0, Math.min(1, v)) * 100)
        root.brightness = pct / 100
        setBrightProc.command = ["sh", "-c", "brightnessctl -c backlight set " + pct + "% >/dev/null 2>&1"]
        setBrightProc.running = true
    }

    Process { id: setBrightProc }
    Process {
        id: brightProc
        command: ["sh", "-c", "brightnessctl -m -c backlight 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: {
                const f = this.text.trim().split(",")
                if (f.length >= 5 && parseInt(f[4]) > 0) {
                    root.brightnessAvailable = true
                    if (!root.brightnessDragging)
                        root.brightness = (parseInt(f[3]) || 0) / 100
                } else {
                    root.brightnessAvailable = false
                }
            }
        }
    }
    // ---- microphone (wpctl @DEFAULT_AUDIO_SOURCE@) ------
    property bool micMuted: false

    function toggleMic() {
        if (micToggleProc.running) return
        root.micMuted = !root.micMuted
        micToggleProc.running = true
    }

    Process {
        id: micToggleProc
        command: ["wpctl", "set-mute", "@DEFAULT_AUDIO_SOURCE@", "toggle"]
        onExited: micProc.running = true
    }
    Process {
        id: micProc
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SOURCE@"]
        stdout: StdioCollector {
            onStreamFinished: { root.micMuted = this.text.indexOf("[MUTED]") !== -1 }
        }
    }

    Timer {
        interval: 1000
        running: root.active
        repeat: true
        triggeredOnStart: true
        onTriggered: { brightProc.running = true; micProc.running = true }
    }

    // ---- media (MPRIS) ----------------------------------
    readonly property var player: {
        const ps = Mpris.players ? Mpris.players.values : []
        if (!ps || ps.length === 0) return null
        for (let i = 0; i < ps.length; i++)
            if (ps[i].playbackState === MprisPlaybackState.Playing) return ps[i]
        return ps[0]
    }
    readonly property bool hasPlayer: player !== null
    readonly property bool isPlaying: hasPlayer && player.playbackState === MprisPlaybackState.Playing

    function isoWeek(d) {
        const date = new Date(d.getFullYear(), d.getMonth(), d.getDate())
        const day = (date.getDay() + 6) % 7
        date.setDate(date.getDate() - day + 3)
        const firstThu = new Date(date.getFullYear(), 0, 4)
        const fday = (firstThu.getDay() + 6) % 7
        firstThu.setDate(firstThu.getDate() - fday + 3)
        return 1 + Math.round((date - firstThu) / (7 * 24 * 3600 * 1000))
    }

    component ThemeSlider: Item {
        id: sl
        property real value: 0
        property color fillColor: root.accentColor
        signal moved(real v)
        signal released()

        implicitHeight: 16

        Rectangle {
            id: track
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            height: 4
            radius: 2
            color: Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.15)
            Rectangle {
                width: Math.max(0, Math.min(1, sl.value)) * parent.width
                height: parent.height
                radius: 2
                color: sl.fillColor
            }
        }
        Rectangle {
            width: 14
            height: 14
            radius: 7
            x: Math.max(0, Math.min(1, sl.value)) * (sl.width - width)
            anchors.verticalCenter: parent.verticalCenter
            color: sl.fillColor
            border.width: 1
            border.color: Qt.rgba(root.backgroundColor.r, root.backgroundColor.g, root.backgroundColor.b, 0.6)
            scale: ma.pressed ? 1.2 : 1.0
            Behavior on scale { NumberAnimation { duration: 100 } }
        }
        MouseArea {
            id: ma
            anchors.fill: parent
            anchors.topMargin: -8
            anchors.bottomMargin: -8
            cursorShape: Qt.PointingHandCursor
            function setFromX(mx) { sl.moved(Math.max(0, Math.min(1, mx / sl.width))) }
            onPressed: (m) => setFromX(m.x)
            onPositionChanged: (m) => { if (pressed) setFromX(m.x) }
            onReleased: sl.released()
        }
    }

    // ---- fullscreen click-catcher (no blur) -------------
    PanelWindow {
        id: dismissWin
        screen: root.modelData
        visible: root.active
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        aboveWindows: true
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.namespace: "quickshell-clockpopup-catch"

        anchors.top: true; anchors.bottom: true
        anchors.left: true; anchors.right: true

        MouseArea {
            anchors.fill: parent
            onClicked: root.dismissed()
        }
    }

    // ---- the box ----------------------------------------
    PanelWindow {
        id: boxWin
        screen: root.modelData
        visible: root.active
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        aboveWindows: true
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.namespace: "quickshell-clockpopup"

        anchors.top: true
        margins.top: root.barMargin + root.barHeight + root.gap

        implicitWidth: root.boxW
        implicitHeight: col.implicitHeight + 32
        Behavior on implicitHeight {
            NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
        }

        Rectangle {
            id: content
            anchors.fill: parent
            radius: root.radius
            color: Qt.rgba(root.backgroundColor.r, root.backgroundColor.g,
                           root.backgroundColor.b, root.backgroundOpacity)
            border.width: 1
            border.color: Qt.rgba(root.borderColor.r, root.borderColor.g,
                                  root.borderColor.b, 0.3)

            opacity: 0
            scale: 0.96
            transformOrigin: Item.Top
            states: State {
                name: "on"; when: root.active
                PropertyChanges { target: content; opacity: 1; scale: 1 }
            }
            transitions: Transition {
                NumberAnimation { properties: "opacity,scale"; duration: 140; easing.type: Easing.OutQuad }
            }

            Column {
                id: col
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 20
                spacing: 16

                // ---- date / time ------------------------
                Column {
                    width: parent.width
                    spacing: 2
                    Text {
                        id: bigTime
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: root.textColor
                        font.family: "FiraCode Nerd Font Mono"
                        font.pixelSize: 58
                    }
                    Text {
                        id: bigDate
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: root.textColor
                        opacity: 0.85
                        font.family: "FiraCode Nerd Font Mono"
                        font.pixelSize: 16
                    }
                    Text {
                        id: subLine
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: root.textColor
                        opacity: 0.5
                        font.family: "FiraCode Nerd Font Mono"
                        font.pixelSize: 13
                    }
                }

                // ---- separator --------------------------
                Rectangle {
                    width: parent.width
                    height: 1
                    color: Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.12)
                }

                // ---- now playing ------------------------
                Column {
                    width: parent.width
                    spacing: 12

                    RowLayout {
                        width: parent.width
                        spacing: 12

                        Rectangle {
                            Layout.preferredWidth: 64
                            Layout.preferredHeight: 64
                            radius: 8
                            clip: true
                            color: Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.08)
                            border.width: 1
                            border.color: Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.12)

                            Image {
                                anchors.fill: parent
                                source: root.hasPlayer && root.player.trackArtUrl ? root.player.trackArtUrl : ""
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                                visible: status === Image.Ready
                            }
                            Text {
                                anchors.centerIn: parent
                                visible: !(root.hasPlayer && root.player.trackArtUrl)
                                text: "󰎈"
                                font.family: "MesloLGS Nerd Font Mono"
                                font.pixelSize: 30
                                color: Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.4)
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 3

                            Text {
                                Layout.fillWidth: true
                                text: root.hasPlayer && root.player.trackTitle
                                      ? root.player.trackTitle : "Nothing playing"
                                elide: Text.ElideRight
                                color: root.textColor
                                opacity: root.hasPlayer ? 1.0 : 0.5
                                font.family: "FiraCode Nerd Font Mono"
                                font.pixelSize: 15
                                font.weight: Font.Medium
                            }
                            Text {
                                Layout.fillWidth: true
                                visible: root.hasPlayer && !!root.player.trackArtist
                                text: root.hasPlayer ? root.player.trackArtist : ""
                                elide: Text.ElideRight
                                color: root.textColor
                                opacity: 0.6
                                font.family: "FiraCode Nerd Font Mono"
                                font.pixelSize: 13
                            }
                        }
                    }

                    Item {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: ctlRow.implicitWidth
                        height: 40

                        Row {
                            id: ctlRow
                            anchors.centerIn: parent
                            spacing: 30

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: "󰒮"
                                font.family: "MesloLGS Nerd Font Mono"
                                font.pixelSize: 24
                                color: root.textColor
                                enabled: root.hasPlayer && root.player.canGoPrevious
                                opacity: enabled ? (prevHover.containsMouse ? 1.0 : 0.8) : 0.25
                                Behavior on opacity { NumberAnimation { duration: 120 } }
                                MouseArea {
                                    id: prevHover
                                    anchors.fill: parent
                                    anchors.margins: -8
                                    hoverEnabled: true
                                    enabled: parent.enabled
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.player.previous()
                                }
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: root.isPlaying ? "󰏤" : "󰐊"
                                font.family: "MesloLGS Nerd Font Mono"
                                font.pixelSize: 34
                                color: root.hasPlayer ? root.accentColor : root.textColor
                                enabled: root.hasPlayer && root.player.canTogglePlaying
                                opacity: enabled ? (playHover.containsMouse ? 1.0 : 0.92) : 0.25
                                Behavior on opacity { NumberAnimation { duration: 120 } }
                                scale: playHover.containsMouse && enabled ? 1.12 : 1.0
                                Behavior on scale { NumberAnimation { duration: 130; easing.type: Easing.OutBack } }
                                MouseArea {
                                    id: playHover
                                    anchors.fill: parent
                                    anchors.margins: -8
                                    hoverEnabled: true
                                    enabled: parent.enabled
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.player.togglePlaying()
                                }
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: "󰒭"
                                font.family: "MesloLGS Nerd Font Mono"
                                font.pixelSize: 24
                                color: root.textColor
                                enabled: root.hasPlayer && root.player.canGoNext
                                opacity: enabled ? (nextHover.containsMouse ? 1.0 : 0.8) : 0.25
                                Behavior on opacity { NumberAnimation { duration: 120 } }
                                MouseArea {
                                    id: nextHover
                                    anchors.fill: parent
                                    anchors.margins: -8
                                    hoverEnabled: true
                                    enabled: parent.enabled
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.player.next()
                                }
                            }
                        }
                    }
                }

                // ---- separator --------------------------
                Rectangle {
                    width: parent.width
                    height: 1
                    color: Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.12)
                }

                // ---- brightness -------------------------
                RowLayout {
                    width: parent.width
                    spacing: 12
                    visible: root.brightnessAvailable

                    Text {
                        Layout.preferredWidth: 22
                        horizontalAlignment: Text.AlignHCenter
                        text: "󰃟"
                        font.family: "MesloLGS Nerd Font Mono"
                        font.pixelSize: 18
                        color: root.textColor
                    }
                    ThemeSlider {
                        Layout.fillWidth: true
                        value: root.brightness
                        fillColor: root.accentColor
                        onMoved: (v) => { root.brightnessDragging = true; root.setBrightness(v) }
                        onReleased: root.brightnessDragging = false
                    }
                    Text {
                        Layout.preferredWidth: 38
                        horizontalAlignment: Text.AlignRight
                        text: Math.round(root.brightness * 100) + "%"
                        color: root.textColor
                        opacity: 0.7
                        font.family: "FiraCode Nerd Font Mono"
                        font.pixelSize: 12
                    }
                }

                // ---- microphone -------------------------
                Item {
                    width: parent.width
                    implicitHeight: 24

                    RowLayout {
                        anchors.fill: parent
                        spacing: 12

                        Text {
                            Layout.preferredWidth: 22
                            horizontalAlignment: Text.AlignHCenter
                            text: root.micMuted ? "󰍭" : "󰍬"
                            font.family: "MesloLGS Nerd Font Mono"
                            font.pixelSize: 18
                            color: root.micMuted ? root.mutedColor : root.textColor
                        }
                        Text {
                            Layout.fillWidth: true
                            text: "Microphone"
                            color: root.textColor
                            opacity: 0.85
                            font.family: "FiraCode Nerd Font Mono"
                            font.pixelSize: 13
                        }
                        Text {
                            text: root.micMuted ? "Muted" : "Active"
                            color: root.micMuted ? root.mutedColor : root.accentColor
                            font.family: "FiraCode Nerd Font Mono"
                            font.pixelSize: 12
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -4
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.toggleMic()
                    }
                }

            }
        }

        Timer {
            interval: 1000
            running: root.active
            repeat: true
            triggeredOnStart: true
            onTriggered: {
                const now = new Date()
                bigTime.text = Qt.formatDateTime(now, "HH:mm")
                bigDate.text = Qt.formatDateTime(now, "dddd, dd MMMM")
                subLine.text = "Week " + root.isoWeek(now) + " · " + Qt.formatDateTime(now, "yyyy")
            }
        }
    }
}
