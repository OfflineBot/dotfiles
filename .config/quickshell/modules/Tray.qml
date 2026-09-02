import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import QtQuick

Row {
    id: root
    property color textColor: "#cdd6f4"
    spacing: 10

    property var hiddenIds: ["Arch-Update"]

    Repeater {
        model: SystemTray.items

        delegate: MouseArea {
            id: entry
            required property var modelData

            visible: root.hiddenIds.indexOf(entry.modelData.id) === -1
            implicitWidth: visible ? 18 : 0
            implicitHeight: 18
            anchors.verticalCenter: parent.verticalCenter
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton

            onClicked: mouse => {
                if (mouse.button === Qt.LeftButton) entry.modelData.activate()
                else entry.modelData.secondaryActivate()
            }

            IconImage {
                anchors.fill: parent
                source: entry.modelData.icon
                opacity: entry.containsMouse ? 1.0 : 0.85
            }
        }
    }
}
