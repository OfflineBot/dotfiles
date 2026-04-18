import Quickshell
import Quickshell.Io
import QtQuick

Variants {
    id: centerClock
    model: Quickshell.screens

    PanelWindow {
        required property var modelData
        screen: modelData

        color: "transparent"
        implicitWidth: 600
        implicitHeight: 400
        exclusionMode: ExclusionMode.Ignore
        aboveWindows: false

        anchors.right: true
        anchors.bottom: true

        Column {
            id: clockColumn
            anchors.centerIn: parent
            spacing: -50

            Text {
                id: dateText
                text: dateText.text
                color: "#bac2de"
                font.pixelSize: 100
                horizontalAlignment: Text.AlignRight
            }

            Text {
                id: timeText
                text: timeText.text
                font.family: "Arkitech"
                font.bold: true
                font.pixelSize: 200
                color: "#bac2de"
                horizontalAlignment: Text.AlignRight
            }
        }

        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: {
                dateText.text = Qt.formatDateTime(new Date(), "ddd MMM dd")
                timeText.text = Qt.formatDateTime(new Date(), "HH:mm")
            }
        }
    }
}

