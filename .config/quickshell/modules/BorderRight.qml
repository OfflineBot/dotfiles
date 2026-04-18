
import Quickshell
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
        aboveWindows: true

        anchors.top: true
        anchors.right: true
        anchors.bottom: true

        implicitWidth: verticalBorder.borderSize
        color: "transparent"  // allows internal rectangles to show

        // TOP RECTANGLE (overlaps top corner area)
        Rectangle {
            x: 0
            y: 0
            width: parent.width
            height: verticalBorder.cornerRadius
            color: verticalBorder.backgroundColor
        }

        // MAIN RECTANGLE (middle border)
        Rectangle {
            x: 0
            y: verticalBorder.cornerRadius
            width: parent.width
            height: parent.height - 2 * verticalBorder.cornerRadius
            color: verticalBorder.backgroundColor
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
