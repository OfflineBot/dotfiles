
import Quickshell
import QtQuick


Variants {
    id: cornerTR
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
            right: true
        }
        margins.right: -cornerTR.innerBorderSize
        margins.top: -cornerTR.innerBorderSize
        
        implicitWidth: cornerTR.cornerRadius
        implicitHeight: cornerTR.cornerRadius
        
        color: "transparent"
        
        Canvas {
            anchors.fill: parent
            onPaint: {

                var ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);

                var r = cornerTR.cornerRadius;
                var b = cornerTR.innerBorderSize;

                // Fill the main square/corner area
                ctx.fillStyle = cornerTR.backgroundColor;
                ctx.fillRect(0, 0, width, height);

                // Cut out the inverted arc (bottom-right area)
                ctx.globalCompositeOperation = "destination-out";
                ctx.beginPath();
                ctx.arc(0, height, r, Math.PI * 1.5, 2.0 * Math.PI, false);
                ctx.lineTo(0, height);
                ctx.closePath();
                ctx.fill();

                // Reset to normal for border drawing
                ctx.globalCompositeOperation = "source-over";

                // Draw inner border along the arc
                ctx.strokeStyle = cornerTR.borderColor;
                ctx.lineWidth = b;
                ctx.beginPath();
                ctx.arc(0, height, r - b/2, Math.PI * 1.5, 2.0 * Math.PI, false);
                ctx.stroke();

                // Draw inner borders along top and left edges
                ctx.fillStyle = cornerTR.borderColor;
            }
        }
    }
}
