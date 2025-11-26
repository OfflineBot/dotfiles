
import Quickshell
import QtQuick

import "./modules"

ShellRoot {
    id: root

    property int leftBorderSize: 60
    property int borderSize: 4
    property int fromBorder: 2
    property color backgroundColor: "#1e2326"
    property color borderColor: Qt.rgba(0.727, 0.676, 0.567, 0.8)
    //property color borderColor: Qt.rgba(0.5, 0.5, 0.5, 1.0)
    property int cornerRadius: 8

    Time { }


    BorderTop {
        borderSize: root.borderSize
        cornerRadius: root.cornerRadius
        backgroundColor: root.backgroundColor
        borderColor: root.borderColor
    }

    BorderBottom {
        borderSize: root.borderSize
        cornerRadius: root.cornerRadius
        backgroundColor: root.backgroundColor
        borderColor: root.borderColor
    }

    BorderLeft {
        borderSize: root.leftBorderSize
        cornerRadius: root.cornerRadius
        backgroundColor: root.backgroundColor
        borderColor: root.borderColor
    }

    BorderLeft21 {
        borderSize: root.borderSize
        cornerRadius: root.cornerRadius
        backgroundColor: root.backgroundColor
        borderColor: root.borderColor
    }

    BorderRight {
        borderSize: root.borderSize
        cornerRadius: root.cornerRadius
        backgroundColor: root.backgroundColor
        borderColor: root.borderColor
    }

    BorderLeft2 { 
        borderSize: root.fromBorder 
        borderColor: root.borderColor
    }

    BorderRight2 { 
        borderSize: root.fromBorder
        borderColor: root.borderColor
    }

    BorderTop2 { 
        borderSize: root.fromBorder
        borderColor: root.borderColor
    }

    BorderBottom2 { 
        borderSize: root.fromBorder
        borderColor: root.borderColor
    }

    CornerTopRight {
        cornerRadius: root.cornerRadius
        backgroundColor: root.backgroundColor
        borderColor: root.borderColor
        innerBorderSize: root.fromBorder
    }

    CornerTopLeft {
        cornerRadius: root.cornerRadius
        backgroundColor: root.backgroundColor
        borderColor: root.borderColor
        innerBorderSize: root.fromBorder
    }

    CornerBottomRight {
        cornerRadius: root.cornerRadius
        backgroundColor: root.backgroundColor
        borderColor: root.borderColor
        innerBorderSize: root.fromBorder
    }

    CornerBottomLeft {
        cornerRadius: root.cornerRadius
        backgroundColor: root.backgroundColor
        borderColor: root.borderColor
        innerBorderSize: root.fromBorder
    }


}
