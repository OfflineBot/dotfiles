

import Quickshell
import QtQuick


Variants {
    id: cornerBR
    model: Quickshell.screens
    property int cornerRadius
    property color backgroundColor
    property color borderColor
    property int innerBorderSize

    
    PanelWindow {
        required property var modelData
        screen: modelData
        aboveWindows: true
        
        anchors {
            bottom: true
            right: true
        }
        margins.right: -cornerBR.innerBorderSize
        margins.bottom: -cornerBR.innerBorderSize
        
        implicitWidth: cornerBR.cornerRadius
        implicitHeight: cornerBR.cornerRadius
        
        color: "transparent"
        
        Canvas {
            anchors.fill: parent
            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);

                var r = cornerBR.cornerRadius;
                var b = cornerBR.innerBorderSize;

                ctx.fillStyle = cornerBR.backgroundColor;
                ctx.fillRect(0, 0, width, height);

                // cutout top-left
                ctx.globalCompositeOperation = "destination-out";
                ctx.beginPath();
                ctx.arc(0, 0, r, 0.0, 0.5 * Math.PI, false);
                ctx.lineTo(0, 0);
                ctx.closePath();
                ctx.fill();

                ctx.globalCompositeOperation = "source-over";

                // inner arc border
                ctx.strokeStyle = cornerBR.borderColor;
                ctx.lineWidth = b;
                ctx.beginPath();
                ctx.arc(0, 0, r - b/2, 0.0, 0.5 * Math.PI, false);
                ctx.stroke();
            }
        }
    }
}
