import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick

Rectangle {
    id: tile

    required property int wsId
    required property int slot
    required property var hMon
    required property real monW
    required property real monH

    property bool selected: false
    property color textColor: "#d5dde8"
    property color borderColor: "#d5dde8"
    property color accentColor: "#8ec07b"
    property color windowBackdrop: "#1b1b25"
    property bool live: true

    signal activated()
    signal windowPicked(string address)

    readonly property var wins: [...Hyprland.toplevels.values].filter(
        t => t.workspace && t.workspace.id === tile.wsId)
    readonly property bool isActive:
        hMon && hMon.activeWorkspace && hMon.activeWorkspace.id === wsId
    readonly property bool used: wins.length > 0

    radius: 8
    color: Qt.rgba(0, 0, 0, used ? 0.45 : 0.22)
    border.width: selected ? 3 : isActive ? 2 : 1
    border.color: selected ? textColor
        : isActive ? accentColor
        : hover.hovered ? Qt.rgba(1, 1, 1, 0.35)
        : used ? "#45475a"
        : "transparent"

    Behavior on border.color { ColorAnimation { duration: 120 } }

    HoverHandler { id: hover }

    MouseArea {
        anchors.fill: parent
        z: -1
        cursorShape: Qt.PointingHandCursor
        onClicked: tile.activated()
    }

    Repeater {
        model: tile.wins

        delegate: Item {
            id: thumb
            required property var modelData

            readonly property var ipc: modelData.lastIpcObject
            readonly property bool ok: ipc && ipc.at && ipc.size && tile.monW > 0

            visible: ok
            x:      ok ? (ipc.at[0] - tile.hMon.x) / tile.monW * tile.width  : 0
            y:      ok ? (ipc.at[1] - tile.hMon.y) / tile.monH * tile.height : 0
            width:  ok ? ipc.size[0] / tile.monW * tile.width  : 0
            height: ok ? ipc.size[1] / tile.monH * tile.height : 0

            Rectangle {
                anchors.fill: parent
                radius: 3
                clip: true
                color: tile.windowBackdrop
                border.width: 1
                border.color: modelData.activated ? tile.accentColor
                    : winHover.hovered ? Qt.rgba(1, 1, 1, 0.45)
                    : Qt.rgba(1, 1, 1, 0.18)

                ScreencopyView {
                    anchors.fill: parent
                    anchors.margins: 1
                    captureSource: thumb.modelData.wayland
                    live: tile.live
                }

                Rectangle {
                    anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                    height: Math.min(18, parent.height * 0.28)
                    color: Qt.rgba(0, 0, 0, 0.78)
                    visible: winHover.hovered && height >= 10
                    Text {
                        anchors { fill: parent; leftMargin: 5; rightMargin: 5 }
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                        text: thumb.modelData.title
                        color: tile.textColor
                        font.pixelSize: 10
                        font.family: "FiraCode Nerd Font Mono"
                    }
                }
            }

            HoverHandler { id: winHover }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: tile.windowPicked(thumb.modelData.address)
            }
        }
    }

    Rectangle {
        anchors { left: parent.left; top: parent.top; margins: 5 }
        width: 20; height: 18; radius: 4
        color: tile.isActive ? tile.accentColor : Qt.rgba(0, 0, 0, 0.6)
        Text {
            anchors.centerIn: parent
            text: tile.slot
            color: tile.isActive ? "#11121a" : tile.textColor
            opacity: tile.isActive ? 1.0 : (tile.used ? 0.85 : 0.35)
            font.pixelSize: 11
            font.family: "FiraCode Nerd Font Mono"
        }
    }
}
