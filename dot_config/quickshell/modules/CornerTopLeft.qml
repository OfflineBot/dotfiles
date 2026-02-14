

import Quickshell
import QtQuick


Variants {

    id: cornerTL
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
            top: true
            left: true
        }

        margins.left: -cornerTL.innerBorderSize
        margins.top: -cornerTL.innerBorderSize
        
        implicitWidth: cornerTL.cornerRadius
        implicitHeight: cornerTL.cornerRadius
        
        color: "transparent"
        
        Canvas {
            z: 1000
            anchors.fill: parent
            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);

                var r = cornerTL.cornerRadius;
                var b = cornerTL.innerBorderSize;

                // Fill the main square/corner area
                ctx.fillStyle = cornerTL.backgroundColor;
                ctx.fillRect(0, 0, width, height);

                // Cut out the inverted arc (bottom-right area)
                ctx.globalCompositeOperation = "destination-out";
                ctx.beginPath();
                ctx.arc(width, height, r, Math.PI, 1.5 * Math.PI, false); // bottom-right
                ctx.lineTo(width, height);
                ctx.closePath();
                ctx.fill();

                // Reset to normal for border drawing
                ctx.globalCompositeOperation = "source-over";

                // Draw inner border along the arc
                ctx.strokeStyle = cornerTL.borderColor;
                ctx.lineWidth = b;
                ctx.beginPath();
                ctx.arc(width, height, r - b/2, Math.PI, 1.5 * Math.PI, false);
                ctx.stroke();

                // Draw inner borders along top and left edges
                ctx.fillStyle = cornerTL.borderColor;
            }
        }
    }
}
