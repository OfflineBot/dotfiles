
import Quickshell
import QtQuick


Variants {
    id: cornerBL
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
            left: true
        }
        margins.left: -cornerBL.innerBorderSize
        margins.bottom: -cornerBL.innerBorderSize
        
        implicitWidth: cornerBL.cornerRadius
        implicitHeight: cornerBL.cornerRadius
        
        color: "transparent"
        
        Canvas {
            anchors.fill: parent
            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);

                var r = cornerBL.cornerRadius;
                var b = cornerBL.innerBorderSize;

                ctx.fillStyle = cornerBL.backgroundColor;
                ctx.fillRect(0, 0, width, height);

                // cutout top-right
                ctx.globalCompositeOperation = "destination-out";
                ctx.beginPath();
                ctx.arc(width, 0, r, 0.5 * Math.PI, Math.PI, false);
                ctx.lineTo(width, 0);
                ctx.closePath();
                ctx.fill();

                ctx.globalCompositeOperation = "source-over";

                // inner arc border
                ctx.strokeStyle = cornerBL.borderColor;
                ctx.lineWidth = b;
                ctx.beginPath();
                ctx.arc(width, 0, r - b/2, 0.5 * Math.PI, Math.PI, false);
                ctx.stroke();
            }
        }
    }
}
