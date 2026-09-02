import Quickshell
import Quickshell.Io
import QtQuick

Item {
    id: root

    property color textColor: "#cdd6f4"
    property color mutedColor: "#f38ba8"

    property bool muted: false

    visible: muted
    implicitWidth: visible ? indicator.implicitWidth : 0
    implicitHeight: 18

    function toggleMute() {
        if (muteProc.running) return
        root.muted = !root.muted
        muteProc.running = true
    }

    Process {
        id: muteProc
        command: ["wpctl", "set-mute", "@DEFAULT_AUDIO_SOURCE@", "toggle"]
        onExited: volProc.running = true
    }

    Text {
        id: indicator
        anchors.verticalCenter: parent.verticalCenter
        text: "󰍭"
        font.family: "MesloLGS Nerd Font Mono"
        font.pixelSize: 16
        color: root.mutedColor
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

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: volProc.running = true
    }

    Process {
        id: volProc
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SOURCE@"]
        stdout: StdioCollector {
            onStreamFinished: { root.muted = this.text.indexOf("[MUTED]") !== -1 }
        }
    }
}
