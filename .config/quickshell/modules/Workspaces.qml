import QtQuick

Row {
    id: root

    property var provider
    property string screenName
    property color textColor: "#cdd6f4"
    property color activeColor: "#cba6f7"

    // scratchpad indicator: no extra chip, just recolor the active chip on the
    // monitor the scratchpad is showing on
    property bool scratchActive: false
    property string focusedOutput: ""
    property color scratchColor: "#fab387"

    spacing: 6

    Repeater {
        model: root.provider
               ? root.provider.workspaces.filter(w => (w.output || "") === root.screenName)
               : []

        delegate: Rectangle {
            id: chip
            required property var modelData

            readonly property bool isFocused: modelData.focused
            readonly property string label:
                (modelData.name && modelData.name.length) ? modelData.name : String(modelData.idx)

            // scratchpad is up over this workspace: paint the chip peach instead
            // of the usual focus/active colors, no layout change
            readonly property bool scratchHere:
                root.scratchActive && modelData.active
                && root.screenName === root.focusedOutput

            width: Math.max(22, txt.implicitWidth + 14)
            height: 22
            radius: 6
            color: scratchHere ? root.scratchColor
                   : isFocused ? root.activeColor
                   : modelData.active ? Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.12)
                   : "transparent"

            Behavior on color { ColorAnimation { duration: 120 } }

            Text {
                id: txt
                anchors.centerIn: parent
                text: chip.label
                font.pixelSize: 13
                font.family: "FiraCode Nerd Font Mono"
                color: (chip.isFocused || chip.scratchHere) ? "#1e1e2e" : root.textColor
                opacity: chip.isFocused || chip.scratchHere || chip.modelData.active ? 1.0 : 0.55
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: if (root.provider) root.provider.focus(chip.modelData)
            }
        }
    }
}
