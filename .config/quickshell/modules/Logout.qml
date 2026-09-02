import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick

Scope {
    id: root

    property color backgroundColor: "#1e1e2e"
    property color borderColor: "#cdd6f4"
    property color textColor: "#cdd6f4"
    property int borderWidth: 1
    property int cornerRadius: 14

    property real backgroundOpacity: 0.65
    property real backdropOpacity: 0.35

    property color logoutColor: "#cba6f7"
    property color poweroffColor: "#f38ba8"
    property color rebootColor: "#89dceb"

    property int gap: 10
    property int margin: 10

    property bool shown: false
    property int selectedIndex: -1

    readonly property var actions: [
        {
            icon: "󰍃", ox: 12, label: "Logout", hint: "L",
            accent: root.logoutColor,
            cmd: ["sh", "-c", "hyprctl dispatch exit; niri msg action quit --skip-confirmation; mmsg -s -d quit"]
        },
        {
            icon: "󰐥", ox: 0, label: "Shutdown", hint: "P",
            accent: root.poweroffColor,
            cmd: ["systemctl", "poweroff"]
        },
        {
            icon: "󰁪", ox: 0, label: "Reboot", hint: "R",
            accent: root.rebootColor,
            cmd: ["systemctl", "reboot"]
        }
    ]

    function toggle() { root.shown = !root.shown }
    function show()   { root.shown = true }
    function hide()   { root.shown = false }
    function run(cmd) { Quickshell.execDetached(cmd); root.hide() }

    IpcHandler {
        target: "logout"
        function toggle() { root.toggle() }
        function show()   { root.show() }
        function hide()   { root.hide() }
    }

    PanelWindow {
        id: panel

        visible: root.shown
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        aboveWindows: true
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        WlrLayershell.namespace: "quickshell-logout"

        anchors.top: true
        anchors.bottom: true
        anchors.left: true
        anchors.right: true

        onVisibleChanged: {
            if (visible) {
                root.selectedIndex = -1
                keys.forceActiveFocus()
            }
        }

        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(root.backgroundColor.r, root.backgroundColor.g,
                           root.backgroundColor.b, root.backdropOpacity)
            opacity: root.shown ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 160; easing.type: Easing.OutQuad } }

            MouseArea {
                anchors.fill: parent
                onClicked: root.hide()
            }
        }

        Item {
            id: keys
            anchors.fill: parent
            focus: true
            Keys.onPressed: (e) => {
                switch (e.key) {
                    case Qt.Key_Escape: root.hide(); break
                    case Qt.Key_L: root.run(root.actions[0].cmd); break
                    case Qt.Key_P: case Qt.Key_S: root.run(root.actions[1].cmd); break
                    case Qt.Key_R: root.run(root.actions[2].cmd); break
                    case Qt.Key_Left:
                        root.selectedIndex = root.selectedIndex < 0 ? 0 : Math.max(0, root.selectedIndex - 1); break
                    case Qt.Key_Right: case Qt.Key_Tab:
                        root.selectedIndex = root.selectedIndex < 0 ? 0 : Math.min(root.actions.length - 1, root.selectedIndex + 1); break
                    case Qt.Key_Return: case Qt.Key_Enter:
                        if (root.selectedIndex >= 0) root.run(root.actions[root.selectedIndex].cmd); break
                }
            }
        }

        Row {
            id: row
            anchors.fill: parent
            anchors.margins: root.margin
            spacing: root.gap

            Repeater {
                model: root.actions

                Rectangle {
                    id: tile
                    required property var modelData
                    required property int index

                    readonly property color accent: modelData.accent
                    readonly property bool active: hover.containsMouse || root.selectedIndex === index

                    width: (row.width - 2 * row.spacing) / 3
                    height: row.height
                    radius: root.cornerRadius
                    color: Qt.rgba(root.backgroundColor.r, root.backgroundColor.g,
                                   root.backgroundColor.b, root.backgroundOpacity)
                    border.width: tile.active ? 2 : root.borderWidth
                    border.color: tile.active
                                  ? Qt.rgba(tile.accent.r, tile.accent.g, tile.accent.b, 0.8)
                                  : Qt.rgba(root.borderColor.r, root.borderColor.g, root.borderColor.b, 0.25)
                    clip: true

                    Behavior on border.color { ColorAnimation { duration: 160 } }
                    Behavior on border.width { NumberAnimation { duration: 160 } }

                    opacity: root.shown ? 1 : 0
                    transform: Translate { y: root.shown ? 0 : 28 }
                    Behavior on opacity {
                        SequentialAnimation {
                            PauseAnimation { duration: tile.index * 60 }
                            NumberAnimation { duration: 240; easing.type: Easing.OutCubic }
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: parent.radius
                        color: tile.accent
                        opacity: tile.active ? 0.20 : 0
                        Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutQuad } }
                    }

                    Column {
                        anchors.centerIn: parent
                        spacing: 28

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.horizontalCenterOffset: tile.modelData.ox
                            text: tile.modelData.icon
                            font.family: "MesloLGS Nerd Font Mono"
                            font.pixelSize: 150
                            color: tile.active
                                   ? tile.accent
                                   : Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.92)
                            scale: tile.active ? 1.06 : 1.0
                            Behavior on color { ColorAnimation { duration: 160 } }
                            Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutBack } }
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: tile.modelData.label.toUpperCase()
                            font.family: "FiraCode Nerd Font Mono"
                            font.pixelSize: 22
                            font.letterSpacing: 4
                            font.weight: Font.Medium
                            color: tile.active
                                   ? tile.accent
                                   : Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.85)
                            Behavior on color { ColorAnimation { duration: 160 } }
                        }

                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: hintText.implicitWidth + 18
                            height: hintText.implicitHeight + 8
                            radius: 6
                            color: "transparent"
                            border.width: 1
                            border.color: tile.active
                                          ? Qt.rgba(tile.accent.r, tile.accent.g, tile.accent.b, 0.7)
                                          : Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.2)
                            Behavior on border.color { ColorAnimation { duration: 160 } }

                            Text {
                                id: hintText
                                anchors.centerIn: parent
                                text: tile.modelData.hint
                                font.family: "FiraCode Nerd Font Mono"
                                font.pixelSize: 13
                                font.weight: Font.Medium
                                color: tile.active
                                       ? tile.accent
                                       : Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.45)
                                Behavior on color { ColorAnimation { duration: 160 } }
                            }
                        }
                    }

                    MouseArea {
                        id: hover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: root.selectedIndex = tile.index
                        onClicked: root.run(tile.modelData.cmd)
                    }
                }
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: root.margin + 18
            text: "esc cancel"
            font.family: "FiraCode Nerd Font Mono"
            font.pixelSize: 13
            font.letterSpacing: 2
            color: Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.4)
            opacity: root.shown ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.OutQuad } }
        }
    }
}
