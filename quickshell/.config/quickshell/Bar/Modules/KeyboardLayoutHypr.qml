import QtQuick
import QtQuick.Controls
import Quickshell
import qs.Components
import qs.Settings
import qs.Services as Services

Item {
    id: kb

    property string deviceMatch: ""
    property int fontPixelSize: Math.round(Theme.fontSizeSmall * sc())
    property var screen:null

    property int iconSpacing:Theme.keyboardIconSpacing
    property color iconColor:Theme.keyboardIconColor


    property color textColor:Theme.keyboardTextColor

    property string layoutText: "??"
    property string deviceName: ""
    // Normalized device selector for pinned device (if any)
    property string deviceNeedle: ""
    // Track main keyboard to ignore noise from pseudo-keyboards
    property string mainDeviceName: ""
    property string mainDeviceNeedle: ""
    property var knownKeyboards:[]
    // If true, we only accept events for the pinned deviceName
    // This prevents the indicator from jumping between multiple keyboards.
    readonly property bool hasPinnedDevice: deviceName.length > 0

    /*
     * Strategy (why this module behaves this way):
     * - Update the indicator immediately from Hyprland's event payload for zero‑lag UI.
     * - Identify and prefer the main:true keyboard to ignore noise from pseudo/input helper
     *   devices (e.g., power-button, video-bus, virtual keyboards).
     * - Only when an event does not come from the main device, run a single hyprctl -j devices
     *   snapshot to confirm/correct the state. This avoids persistent inversion seen on some
     *   Hyprland versions where payload could briefly reflect the previous layout.
     * Rationale:
     * - Snapshot on every event introduced noticeable delay and stutter; dropping it restores
     *   responsiveness without sacrificing correctness for the common case.
     * - Pure payload-only was fastest but could be wrong in edge cases; the "non‑main confirm"
     *   compromise keeps the UI snappy and accurate.
     */

    readonly property var resolvedScreen: kb.screen
        ? kb.screen
        : ((Quickshell.screens && Quickshell.screens.length) ? Quickshell.screens[0] : null)

    function sc() {
        return capsule.capsuleScale
    }

    readonly property int capsuleHeight: capsule.capsuleHeight
    readonly property int iconPaddingPx: Math.round(Theme.keyboardIconPadding * sc())
    readonly property int textPaddingPx: Math.round(Theme.keyboardTextPadding * sc())
    readonly property int iconSizePx: Math.max(1, kb.fontPixelSize)
    readonly property int iconBoxWidth: iconSizePx + iconPaddingPx * 2
    readonly property int iconBoxHeight: capsule.capsuleInner

    implicitWidth: Math.max(Math.round(Theme.keyboardMinWidth * sc()), Math.ceil(keyboardRow.implicitWidth + 2 * capsule.horizontalPadding))
    implicitHeight: capsuleHeight

    WidgetCapsule {
        id: capsule
        width: parent.width
        height: parent.height
        anchors.centerIn: parent
        backgroundKey: "keyboard"
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true

        Row {
            id: keyboardRow
            spacing: kb.iconSpacing * sc()
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

            Item {
                id: iconBox
                width: iconBoxWidth
                height: iconBoxHeight
                anchors.verticalCenter: parent.verticalCenter

                MaterialIcon {
                    anchors.centerIn: parent
                    icon: "keyboard"
                    size: iconSizePx
                    color: kb.iconColor
                }
            }

            Label {
                id: keyboardLabel
                text: kb.layoutText
                color: kb.textColor
                font.family: Theme.fontFamily
                font.weight: Theme.keyboardTextBold ? Font.DemiBold : Font.Medium
                font.pixelSize: kb.fontPixelSize
                padding: 0
                leftPadding: textPaddingPx
                rightPadding: textPaddingPx
                verticalAlignment: Text.AlignVCenter
            }
        }

        TapHandler {
            acceptedButtons: Qt.LeftButton
            gesturePolicy: TapHandler.ReleaseWithinBounds
            onTapped: {
                switchProc.cmd = ["hyprctl", "switchxkblayout", "current", "next"]
                switchProc.start()
            }
        }
    }

    Connections {
        target: Services.HyprlandWatcher
        function onKeyboardDevicesChanged() { kb.applyDeviceSnapshot(Services.HyprlandWatcher.keyboardDevices); }
        // Event path: prefer payload from HyprlandWatcher for snappy UI; fallback snapshot only for non-main events.
        function onKeyboardLayoutEvent(deviceName, layoutName) {
            const kbd = String(deviceName || "")
            const layout = String(layoutName || "")
            const fromMain = (norm(kbd) === kb.mainDeviceNeedle)
            const evTxt = shortenLayout(layout)
            if (evTxt && evTxt !== kb.layoutText) kb.layoutText = evTxt
            if (!fromMain) Services.HyprlandWatcher.refreshDevices()
        }
    }

    Component.onCompleted: {
        Services.HyprlandWatcher.refreshDevices();
    }

    ProcessRunner {
        id: switchProc
        autoStart: false
        restartOnExit: false
        env: Services.HyprlandWatcher.hyprEnvObject
    }

    function norm(s) { return (String(s || "").toLowerCase().replace(/[^a-z0-9]+/g, "-")) }
    function deviceAllowed(name, identifier) {
        const needle = (kb.deviceMatch || kb.deviceName || "").toLowerCase().trim()
        if (!needle) return true
        const n1 = (name || "").toLowerCase();
        const n2 = (identifier || "").toLowerCase();
        if (n1.includes(needle) || n2.includes(needle)) return true
        // Try normalized match to be resilient to hyphens/spaces
        return norm(name).includes(norm(needle)) || norm(identifier).includes(norm(needle))
    }
    function pickDevice(list) {
        if (!Array.isArray(list) || list.length === 0) return null
        // 1) If explicitly matched/pinned, honor it
        const needle = (kb.deviceMatch || kb.deviceName || "").toLowerCase().trim()
        if (needle.length) {
            for (let k of list) {
                if ((k.name || "").toLowerCase().includes(needle) ||
                    (k.identifier || "").toLowerCase().includes(needle) ||
                    norm(k.name).includes(norm(needle)) ||
                    norm(k.identifier).includes(norm(needle)))
                    return k
            }
        }
        // 2) Prefer the main keyboard (actual input device)
        for (let k of list) { if (k.main) return k }
        // 3) Otherwise a reasonable non-virtual choice with a keymap
        for (let k of list) {
            const n = (k.name || "").toLowerCase()
            if (!n.includes("virtual") && (k.active_keymap || k.layout)) return k
        }
        // 4) Fallback
        return list[0]
    }
    function shortenLayout(s) {
        if (!s) return "??"
        s = String(s).trim()
        const lower = s.toLowerCase()
        // Common names and codes from Hyprland events/devices
        const map = {
            "english (us)": "en",
            "english (uk)": "en-uk",
            "russian": "ru",
            "us": "en",
            "us-intl": "en",
            "us(international)": "en",
            "en_us": "en",
            "en-us": "en",
            "ru": "ru",
            "ru_ru": "ru",
            "ru-ru": "ru",
            "german": "de",
            "french": "fr",
            "finnish": "fi"
        }
        if (map[lower]) return map[lower]
        const m = s.match(/\(([^)]+)\)/)
        if (m && m[1]) {
            const code = m[1].toLowerCase()
            if (code === "us" || code.startsWith("en")) return "en"
            if (code === "ru" || code.startsWith("ru")) return "ru"
            return m[1].toUpperCase()
        }
        if (/\b(us|en)\b/i.test(s)) return "en"
        if (/\bru\b/i.test(s)) return "ru"
        return s.split(/\s+/)[0].toUpperCase().slice(0, 3)
    }

    function applyDeviceSnapshot(devs) {
        try {
            const list = Array.isArray(devs) ? devs : (Array.isArray(devs?.keyboards) ? devs.keyboards : [])
            if (!Array.isArray(list) || list.length === 0) return
            kb.knownKeyboards = list.map(k => (k.name || ""))
            let main = null
            for (let k of list) {
                if (k.main) { main = k; break }
            }
            if (main) {
                kb.mainDeviceName = main.name || kb.mainDeviceName
                kb.mainDeviceNeedle = norm(main.name || main.identifier || kb.mainDeviceName)
            }
            const pick = pickDevice(list)
            const chosen = pick || main || list[0]
            if (chosen) {
                const txt = shortenLayout(chosen.active_keymap || chosen.layout || kb.layoutText)
                if (txt && txt !== kb.layoutText) kb.layoutText = txt
            }
        } catch (e) {}
    }
}
