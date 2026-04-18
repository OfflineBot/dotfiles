import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import QtQuick
import Quickshell.Services.UPower

Variants {
    id: verticalBorder
    model: Quickshell.screens
    property int borderSize: 2
    property int cornerRadius: 20
    property color backgroundColor: "#ffffff"
    property color borderColor: "#ffffff"

    // Add this debugging component
    Component.onCompleted: {
        console.log("UPower displayDevice ready:", UPower.displayDevice.ready)
        console.log("UPower displayDevice percentage:", UPower.displayDevice.percentage)
        console.log("UPower onBattery:", UPower.onBattery)
        console.log("Number of devices:", UPower.devices.length)
        for (var i = 0; i < UPower.devices.length; i++) {
            console.log("Device", i, ":", UPower.devices[i].nativePath, 
            "percentage:", UPower.devices[i].percentage,
            "ready:", UPower.devices[i].ready)
        }
    }

    PanelWindow {
        required property var modelData
        screen: modelData
        anchors.top: true
        anchors.left: true
        anchors.bottom: true
        aboveWindows: true
        visible: screen.name === "DP-1"
        implicitWidth: verticalBorder.borderSize
        color: "transparent" 

        Rectangle {
            x: 0
            y: 0
            width: parent.width
            height: verticalBorder.cornerRadius
            color: verticalBorder.backgroundColor
        }

        Rectangle {
            x: 0
            y: verticalBorder.cornerRadius
            width: parent.width
            height: parent.height - 2 * verticalBorder.cornerRadius
            color: verticalBorder.backgroundColor



            // Hyprland Workspaces
            Column {
                id: workspaces
                spacing: 5
                anchors.top: parent.top
                anchors.topMargin: 100
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width

                property int activeWorkspace: 1

                Repeater {
                    model: 10

                    Rectangle {
                        property int wsNumber: index === 9 ? 10 : (index + 1)

                        width: parent.width - 10
                        height: 30
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: workspaces.activeWorkspace === wsNumber ? "#d3c6aa" : "#1e2326"
                        radius: 5

                        Text {
                            text: parent.wsNumber
                            anchors.centerIn: parent
                            font.family: "Arkitech"
                            font.bold: true
                            font.pixelSize: 16
                            color: workspaces.activeWorkspace === parent.wsNumber ? "#1d2021" : "#a89983"
                        }
                    }
                }

                // Process to get active workspace
                Process {
                    id: workspaceProc
                    command: ["sh", "-c", "hyprctl activeworkspace -j | grep -o '\"id\": [0-9]*' | grep -o '[0-9]*'"]
                    running: true

                    stdout: SplitParser {
                        onRead: data => {
                            var ws = parseInt(data.trim())
                            if (!isNaN(ws)) {
                                workspaces.activeWorkspace = ws
                            }
                        }
                    }
                }

                // Timer to update active workspace
                Timer {
                    interval: 100
                    running: true
                    repeat: true
                    onTriggered: workspaceProc.running = true
                }
            }


            Column {
                id: clockColumn
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottomMargin: 20
                spacing: 20
                width: parent.width - 10









                // CPU Usage
                Text {
                    id: cpuText
                    text: "..."
                    font.family: "Arkitech"
                    font.bold: true
                    font.pixelSize: 18
                    color: "#7fbbb3"
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width

                    Process {
                        id: cpuProc
                        command: ["sh", "-c", "mpstat 1 1 2>&1 | awk 'END {print 1}'"]
                        running: true

                        stdout: SplitParser {
                            onRead: data => {
                                var usage = parseInt(data.trim())
                                cpuText.text = "CPU\n" + usage + "%"
                            }
                        }
                    }
Timer {
    interval: 5000
    running: true
    repeat: true
    onTriggered: {
        cpuProc.running = false
        cpuProc.running = true
    }
}

                }

                // RAM Usage
                Text {
                    id: ramText
                    text: "RAM: ..."
                    font.family: "Arkitech"
                    font.bold: true
                    font.pixelSize: 18
                    color: "#d699b6"
                    anchors.horizontalCenter: parent.horizontalCenter
                    horizontalAlignment: Text.AlignHCenter
                    width: parent.width

                    Process {
                        id: ramProc
                        command: ["sh", "-c", "free | grep Mem | awk '{printf \"%.1f\", ($3/$2) * 100.0}'"]
                        running: true

                        stdout: SplitParser {
                            onRead: data => {
                                ramText.text = "RAM\n" + Math.floor(data.trim()) + "%"
                            }
                        }
                    }

                    Timer {
                        interval: 5000
                        running: true
                        repeat: true
                        onTriggered: ramProc.running = true
                    }
                }

                // GPU Usage (for NVIDIA)
                Text {
                    id: gpuText
                    text: "GPU: ..."
                    font.family: "Arkitech"
                    font.bold: true
                    font.pixelSize: 18
                    color: "#7fc1ca"
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: false  // Will be made visible if GPU is detected
                    horizontalAlignment: Text.AlignHCenter
                    width: parent.width

                    Process {
                        id: gpuProc
                        command: ["sh", "-c", "cat /sys/class/drm/card*/device/gpu_busy_percent 2>/dev/null | head -n1"]
                        running: true

                        stdout: SplitParser {
                            onRead: data => {
                                var usage = data.trim()
                                if (usage !== "") {
                                    gpuText.visible = true
                                    gpuText.text = "GPU\n" + usage + "%"
                                }
                            }
                        }
                    }

                    Timer {
                        interval: 5000
                        running: true
                        repeat: true
                        onTriggered: gpuProc.running = true
                    }
                }
                Item {
                    width: parent.width
                    height: batteryText.height + 40

                }

                Text {
                    id: timeText
                    text: Qt.formatDateTime(new Date(), "HH:mm")
                    font.family: "Arkitech"
                    font.bold: true
                    font.pixelSize: 18
                    color: "#a89983"
                    horizontalAlignment: Text.AlignRight
                    anchors.horizontalCenter: parent.horizontalCenter                   
                }

                IconImage {
                    source: "file://" + Quickshell.shellPath("images/arch.png")
                    width: parent.width - 10
                    height: 50
                    anchors.horizontalCenter: parent.horizontalCenter                   
                }
            }


            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: {
                    timeText.text = Qt.formatDateTime(new Date(), "HH:mm")
                }
            }
        }

        Rectangle {
            x: 0
            y: parent.height - verticalBorder.cornerRadius
            width: parent.width
            height: verticalBorder.cornerRadius
            color: verticalBorder.backgroundColor
        }
    }
}
