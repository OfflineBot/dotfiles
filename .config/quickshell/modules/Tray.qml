import Quickshell
import Quickshell.Io
import Quickshell.Services.SystemTray
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick

Row {
    id: root

    property var screen
    property int barHeight: 30
    property int barMargin: 0
    property real backgroundOpacity: 0.65
    property color textColor: "#cdd6f4"
    property color backgroundColor: "#1e1e2e"
    property color borderColor: "#cdd6f4"
    spacing: 10

    property var hiddenIds: ["Arch-Update"]

    readonly property int dropTop: barMargin + barHeight + 8

    // ---- tooltip state ----------------------------------
    property Item tipAnchor: null
    property string tipLabel: ""

    function showTip(item, label) {
        root.tipAnchor = item
        root.tipLabel = label
        Qt.callLater(root.placeTip)
    }
    function hideTip(item) {
        if (root.tipAnchor === item) {
            root.tipAnchor = null
            root.tipLabel = ""
        }
    }
    function placeTip() {
        if (!root.tipAnchor) return
        const w = tipText.implicitWidth + 20
        let left = Math.round(root.tipAnchor.mapToItem(null, 0, 0).x
                              + root.tipAnchor.width / 2 - w / 2)
        const sw = root.screen ? root.screen.width : 1920
        if (left + w > sw - 6) left = sw - w - 6
        if (left < 6) left = 6
        tipWindow.margins.left = left
    }

    // ---- Linksklick: existierendes Fenster der App suchen und dorthin
    // springen (Workspace-Wechsel inklusive); ohne Treffer oder unter niri
    // faellt es auf das normale activate() der App zurueck.
    readonly property string focusScript:
        "q=$(printf %s \"$1\" | tr -d ' '); t=$(printf %s \"$2\" | tr -d ' '); " +
        "addr=$(hyprctl -j clients 2>/dev/null | jq -r --arg q \"$q\" --arg t \"$t\" " +
        "'[.[] | (.class|ascii_downcase|gsub(\" \";\"\")) as $cl | select($cl != \"\" and " +
        "((($q|length)>2 and (($cl|contains($q)) or ($q|contains($cl)))) or " +
        "(($t|length)>2 and (($cl|contains($t)) or ($t|contains($cl)))))) | .address] | first // empty'); " +
        "[ -n \"$addr\" ] || exit 3; " +
        "exec hyprctl dispatch \"hl.dsp.focus({ window = \\\"address:$addr\\\" })\" >/dev/null"

    Process {
        id: focusProc
        property var fallback: null
        onExited: (code) => {
            if (code !== 0 && focusProc.fallback) focusProc.fallback.activate()
            focusProc.fallback = null
        }
    }

    function smartActivate(item) {
        if (focusProc.running) return
        focusProc.fallback = item
        focusProc.command = ["sh", "-c", root.focusScript, "tray",
                             (item.id || "").toLowerCase(),
                             (item.title || "").toLowerCase()]
        focusProc.running = true
    }

    Repeater {
        model: SystemTray.items

        delegate: MouseArea {
            id: entry
            required property var modelData

            visible: root.hiddenIds.indexOf(entry.modelData.id) === -1
            implicitWidth: visible ? 18 : 0
            implicitHeight: 18
            anchors.verticalCenter: parent.verticalCenter
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton

            readonly property string label:
                entry.modelData.tooltipTitle || entry.modelData.title || entry.modelData.id

            onContainsMouseChanged:
                containsMouse ? root.showTip(entry, entry.label) : root.hideTip(entry)

            // Linksklick: zum Fenster der App springen (oder App aktivieren),
            // Rechtsklick: Kontextmenü der App
            onClicked: mouse => {
                if (mouse.button === Qt.LeftButton) root.smartActivate(entry.modelData)
                else entry.modelData.secondaryActivate()
            }

            IconImage {
                anchors.fill: parent
                source: entry.modelData.icon
                opacity: entry.containsMouse ? 1.0 : 0.5
                Behavior on opacity { NumberAnimation { duration: 120; easing.type: Easing.OutQuad } }
            }
        }
    }

    // ---- tooltip (gleicher Stil wie Network) ------------
    PanelWindow {
        id: tipWindow
        screen: root.screen
        visible: root.tipAnchor !== null && root.tipLabel.length > 0
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        aboveWindows: true
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.namespace: "quickshell-tip"

        anchors.top: true
        anchors.left: true
        margins.top: root.dropTop
        implicitWidth: tipText.implicitWidth + 20
        implicitHeight: 28

        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(root.backgroundColor.r, root.backgroundColor.g,
                           root.backgroundColor.b, root.backgroundOpacity)
            radius: 8
            border.color: Qt.rgba(root.borderColor.r, root.borderColor.g,
                                  root.borderColor.b, 0.3)
            border.width: 1
            Text {
                id: tipText
                anchors.centerIn: parent
                text: root.tipLabel
                color: root.textColor
                font.family: "FiraCode Nerd Font Mono"
                font.pixelSize: 12
            }
        }
    }
}
