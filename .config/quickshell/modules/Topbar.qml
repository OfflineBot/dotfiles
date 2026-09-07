import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick

Scope {
    id: root

    property color backgroundColor: "#1e1e2e"
    property color borderColor: "#cdd6f4"
    property color textColor: "#cdd6f4"
    property color accentColor: "#cba6f7"
    property real backgroundOpacity: 0.65
    property int barHeight: 30
    property int barMargin: 0
    property int barPadding: 12

    property var shownScreens: ({})
    function _set(name, val) {
        const next = Object.assign({}, root.shownScreens)
        next[name] = val
        root.shownScreens = next
    }
    function toggle(name) { root._set(name, !(root.shownScreens[name] ?? true)) }
    function show(name)   { root._set(name, true) }
    function hide(name)   { root._set(name, false) }

    property string clockOpenOn: ""
    function toggleClock(name) {
        root.clockOpenOn = (root.clockOpenOn === name ? "" : name)
    }

    IpcHandler {
        target: "topbar"
        function toggle(name: string) { root.toggle(name) }
        function show(name: string)   { root.show(name) }
        function hide(name: string)   { root.hide(name) }
        function toggleClock(name: string) { root.toggleClock(name) }
    }

    WorkspaceProvider { id: workspaceProvider }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar
            required property var modelData
            screen: modelData

            visible: root.shownScreens[modelData.name] ?? true
            color: "transparent"
            implicitHeight: root.barHeight

            anchors.top: true
            anchors.left: true
            anchors.right: true

            exclusionMode: ExclusionMode.Normal
            exclusiveZone: root.barHeight

            WlrLayershell.namespace: "quickshell-bar"

            Rectangle {
                anchors.fill: parent
                radius: 0
                color: Qt.rgba(root.backgroundColor.r, root.backgroundColor.g,
                               root.backgroundColor.b, root.backgroundOpacity)

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: 1
                    color: Qt.rgba(root.borderColor.r, root.borderColor.g,
                                   root.borderColor.b, 0.18)
                }

                Workspaces {
                    anchors.left: parent.left
                    anchors.leftMargin: root.barPadding
                    anchors.verticalCenter: parent.verticalCenter
                    provider: workspaceProvider
                    screenName: bar.modelData.name
                    textColor: root.textColor
                    activeColor: root.accentColor
                    scratchActive: workspaceProvider.scratchVisible
                    focusedOutput: workspaceProvider.focusedOutput
                }

                Clock {
                    anchors.centerIn: parent
                    textColor: root.textColor
                    onClicked: root.toggleClock(bar.modelData.name)
                }

                Row {
                    anchors.right: parent.right
                    anchors.rightMargin: root.barPadding
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 14

                    Tray {
                        anchors.verticalCenter: parent.verticalCenter
                        screen: bar.modelData
                        barHeight: root.barHeight
                        barMargin: root.barMargin
                        backgroundOpacity: root.backgroundOpacity
                        textColor: root.textColor
                        backgroundColor: root.backgroundColor
                        borderColor: root.borderColor
                    }
                    Network {
                        anchors.verticalCenter: parent.verticalCenter
                        screen: bar.modelData
                        barHeight: root.barHeight
                        barMargin: root.barMargin
                        backgroundOpacity: root.backgroundOpacity
                        textColor: root.textColor
                        accentColor: root.accentColor
                        backgroundColor: root.backgroundColor
                        borderColor: root.borderColor
                    }
                    MicMute {
                        anchors.verticalCenter: parent.verticalCenter
                        textColor: root.textColor
                    }
                    Volume {
                        anchors.verticalCenter: parent.verticalCenter
                        textColor: root.textColor
                    }
                    Battery {
                        anchors.verticalCenter: parent.verticalCenter
                        textColor: root.textColor
                        accentColor: root.accentColor
                    }
                }
            }
        }
    }

    Variants {
        model: Quickshell.screens

        ClockPopup {
            active: root.clockOpenOn === modelData.name
            barHeight: root.barHeight
            barMargin: root.barMargin
            backgroundColor: root.backgroundColor
            borderColor: root.borderColor
            textColor: root.textColor
            accentColor: root.accentColor
            backgroundOpacity: root.backgroundOpacity
            onDismissed: root.clockOpenOn = ""
        }
    }
}
