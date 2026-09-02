import Quickshell
import Quickshell.Io
import QtQuick

Item {
    id: root

    property color textColor: "#cdd6f4"

    implicitWidth: indicator.implicitWidth
    implicitHeight: 18

    // ---- live state -------------------------------------
    property real volume: 0.0
    property bool muted: false

    function volIcon() {
        if (root.muted) return "󰖁"
        if (root.volume < 0.34) return "󰕿"
        if (root.volume < 0.67) return "󰖀"
        return "󰕾"
    }

    function toggleMute() {
        if (muteProc.running) return
        root.muted = !root.muted
        muteProc.running = true
    }

    Process {
        id: muteProc
        command: ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]
        onExited: volProc.running = true
    }

    // ---- indicator --------------------------------------
    Text {
        id: indicator
        anchors.verticalCenter: parent.verticalCenter
        text: root.volIcon()
        font.family: "MesloLGS Nerd Font Mono"
        font.pixelSize: 16
        color: root.textColor
        opacity: root.muted ? 0.4 : 1.0
        Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
    }

    MouseArea {
        anchors.fill: parent
        anchors.topMargin: -8
        anchors.bottomMargin: -8
        anchors.leftMargin: -6
        anchors.rightMargin: -6
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggleMute()
    }

    // ---- polled state -----------------------------------
    Timer {
        id: pollTimer
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: volProc.running = true
    }

    Process {
        id: volProc
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: StdioCollector {
            onStreamFinished: {
                const m = this.text.match(/Volume:\s*([0-9.]+)/)
                if (m) root.volume = parseFloat(m[1])
                root.muted = this.text.indexOf("[MUTED]") !== -1
            }
        }
    }
}
