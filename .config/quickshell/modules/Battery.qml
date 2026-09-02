import Quickshell.Services.UPower
import QtQuick

Row {
    id: root
    property color textColor: "#cdd6f4"
    property color accentColor: "#cba6f7"
    property color warnColor: "#f38ba8"

    spacing: 4
    visible: UPower.displayDevice && UPower.displayDevice.isLaptopBattery

    readonly property real _raw: UPower.displayDevice ? UPower.displayDevice.percentage : 0
    readonly property real pct: _raw <= 1.0 ? _raw * 100 : _raw
    readonly property bool charging:
        UPower.displayDevice && UPower.displayDevice.state === UPowerDeviceState.Charging

    function icon(p, ch) {
        if (ch) return "󰂄"
        if (p >= 90) return "󰁹"
        if (p >= 60) return "󰂁"
        if (p >= 35) return "󰁾"
        if (p >= 15) return "󰁻"
        return "󰂎"
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: root.icon(root.pct, root.charging)
        font.family: "MesloLGS Nerd Font Mono"
        font.pixelSize: 16
        color: (!root.charging && root.pct <= 15) ? root.warnColor
               : root.charging ? root.accentColor : root.textColor
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: Math.round(root.pct) + "%"
        font.family: "FiraCode Nerd Font Mono"
        font.pixelSize: 13
        color: root.textColor
        opacity: 0.85
    }
}
