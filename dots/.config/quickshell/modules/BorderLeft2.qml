import Quickshell
import QtQuick

Variants {
    id: borderRight
    model: Quickshell.screens
    
    property int borderSize: 4
    property int cornerRadius: 20  // Add this property
    property color borderColor: "#ff00f0"
    
    PanelWindow {
        required property var modelData
        screen: modelData
        
        anchors {
            top: true
            bottom: true
            left: true
        }
        
        margins {                              // Add this block
            top: borderRight.cornerRadius
            bottom: borderRight.cornerRadius
        }
        
        color: "transparent"
        implicitWidth: 2  // You can use 1px now
        
        Rectangle {
            anchors.fill: parent
            color: borderRight.borderColor
        }
    }
}
