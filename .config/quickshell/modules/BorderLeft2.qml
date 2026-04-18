import Quickshell
import QtQuick

Variants {
    id: borderRight
    model: Quickshell.screens
    
    property int borderSize: 4
    property int marginRight: 20
    property color borderColor: "#ff00f0"

    PanelWindow {
        required property var modelData
        screen: modelData
        aboveWindows: true

        anchors {
            top: true
            bottom: true
            left: true  // or left: true
        }

        implicitWidth: borderRight.borderSize
        color: borderRight.borderColor
    }
}

