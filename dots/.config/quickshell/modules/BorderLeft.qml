
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
        //aboveWindows: false

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

            IconImage {
                source: "file://" + Quickshell.shellPath("images/arch.png")
                width: parent.width - 20
                height: 50
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 20
                anchors.horizontalCenter: parent.horizontalCenter
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
