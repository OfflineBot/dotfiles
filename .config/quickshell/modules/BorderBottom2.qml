
import Quickshell
import QtQuick

Variants {
    id: borderBottom
    model: Quickshell.screens
    
    property int borderSize: 4
    property int marginRight: 20
    property color borderColor: "#ff00f0"

    PanelWindow {
        required property var modelData
        screen: modelData
        aboveWindows: true
        
        anchors {
            bottom: true
            left: true
            right: true 
        }
        
        
        implicitHeight: borderBottom.borderSize
        color: borderBottom.borderColor
    }
}

