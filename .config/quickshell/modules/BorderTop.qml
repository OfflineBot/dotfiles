
import Quickshell
import QtQuick


Variants {
    id: horizontalBorder
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
        anchors.left: true
        anchors.right: true

        implicitHeight: horizontalBorder.borderSize
        color: "transparent"  // so internal rectangles show fully

        // LEFT RECTANGLE
        Rectangle {
            x: 0
            width: horizontalBorder.cornerRadius
            height: parent.height
            color: horizontalBorder.backgroundColor
        }

        // MAIN RECTANGLE
        Rectangle {
            x: horizontalBorder.cornerRadius
            width: parent.width - 2 * horizontalBorder.cornerRadius
            height: parent.height
            color: horizontalBorder.backgroundColor
        }

        // RIGHT RECTANGLE
        Rectangle {
            x: parent.width - horizontalBorder.cornerRadius
            width: horizontalBorder.cornerRadius
            height: parent.height
            color: horizontalBorder.backgroundColor
        }
    }
}
