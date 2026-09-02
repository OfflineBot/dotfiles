import QtQuick

Item {
    id: root
    property color textColor: "#d5dde8"

    signal clicked()

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    MouseArea {
        anchors.fill: parent
        anchors.topMargin: -8
        anchors.bottomMargin: -8
        anchors.leftMargin: -16
        anchors.rightMargin: -16
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 10

        Text {
            id: dateText
            color: root.textColor
            opacity: 0.6
            font.pixelSize: 13
            font.family: "FiraCode Nerd Font Mono"
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            id: timeText
            color: root.textColor
            font.pixelSize: 13
            font.family: "FiraCode Nerd Font Mono"
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            const now = new Date()
            dateText.text = Qt.formatDateTime(now, "ddd dd MMM")
            timeText.text = Qt.formatDateTime(now, "HH:mm")
        }
    }
}
