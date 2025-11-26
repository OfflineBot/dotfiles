
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import QtQuick


Variants {
    id: verticalBorder
    model: Quickshell.screens
    property int borderSize: 2
    property int cornerRadius: 20
    property color backgroundColor: "#ffffff"
    property color borderColor: "#ffffff"

    PanelWindow {
        required property var modelData
        screen: modelData

        anchors.top: true
        anchors.left: true
        anchors.bottom: true
        aboveWindows: false
        visible: screen.name === "DP-1"

        implicitWidth: verticalBorder.borderSize
        color: "transparent" 

        Rectangle {
            x: 0
            y: 0
            width: parent.width
            height: verticalBorder.cornerRadius
            color: verticalBorder.backgroundColor
        }

        Rectangle {
            x: 0
            y: verticalBorder.cornerRadius
            width: parent.width
            height: parent.height - 2 * verticalBorder.cornerRadius
            color: verticalBorder.backgroundColor


            Column {
                id: clockColumn
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottomMargin: 20
                spacing: 20
                width: parent.width - 10
                Text {
                    id: timeText
                    text: timeText.text
                    font.family: "Arkitech"
                    font.bold: true
                    font.pixelSize: 18
                    color: "#a89983"
                    horizontalAlignment: Text.AlignRight
                    anchors.horizontalCenter: parent.horizontalCenter                   
                }


                IconImage {
                    source: "file://" + Quickshell.shellPath("images/arch.png")
                    width: parent.width - 10
                    height: 50
                    anchors.horizontalCenter: parent.horizontalCenter                   
                }
            }



            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: {
                    timeText.text = Qt.formatDateTime(new Date(), "HH:mm")
                }
            }

        }

        // BOTTOM RECTANGLE (overlaps bottom corner area)
        Rectangle {
            x: 0
            y: parent.height - verticalBorder.cornerRadius
            width: parent.width
            height: verticalBorder.cornerRadius
            color: verticalBorder.backgroundColor
        }
    }
}
