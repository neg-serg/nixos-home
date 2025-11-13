import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs.Components
import qs.Settings
import "../../Helpers/Utils.js" as Utils
import "../../Helpers/WidgetBg.js" as WidgetBg
import "../../Helpers/Color.js" as Color
import "../../Helpers/CapsuleMetrics.js" as Capsule

Item {
    id: kb

    property string deviceMatch: ""
    property alias fontPixelSize:label.font.pixelSize
    property int desiredHeight: capsuleMetrics.inner
    property var screen:null
    property bool useTheme:true
    property int yNudge:0

    property real iconScale:Theme.keyboardIconScale
    property int iconSpacing:Theme.keyboardIconSpacing
    property color iconColor:useTheme ? Theme.keyboardIconColor : Theme.textSecondary

    property int iconBaselineAdjust:Theme.keyboardIconBaselineOffset
    property int textBaselineAdjust:Theme.keyboardTextBaselineOffset

    property color widgetBgColor: WidgetBg.color(Settings.settings, "keyboard", "rgba(10, 12, 20, 0.2)")
    property color widgetBorderColor: Color.withAlpha(Theme.textPrimary, 0.08)
    property color bgColor:useTheme ? widgetBgColor : Theme.background
    property color textColor:useTheme ? Theme.keyboardTextColor : Theme.textPrimary
    property color hoverBgColor:useTheme
        ? Qt.rgba(widgetBgColor.r, widgetBgColor.g, widgetBgColor.b, Math.min(1, widgetBgColor.a + 0.12))
        : Theme.surfaceHover

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

    function sc() {
        const s = kb.screen || (Quickshell.screens && Quickshell.screens.length ? Quickshell.screens[0] : null)
        return s ? Theme.scale(s) : 1
    }

    readonly property var capsuleMetrics: Capsule.metrics(Theme, sc())
    readonly property int capsulePadding: capsuleMetrics.padding
    property int horizontalPadding: Math.max(4, Math.round(Theme.keyboardMargin * sc()))
    property int verticalPadding: Math.max(capsulePadding, Math.round(Theme.keyboardMargin * 0.8 * sc()))
    readonly property int capsuleHeight: capsuleMetrics.height

    implicitWidth: Math.max(Math.round(Theme.keyboardMinWidth * sc()), Math.ceil(row.implicitWidth + 2 * horizontalPadding))
    implicitHeight: capsuleHeight

    WidgetCapsule {
        id: capsule
        width: parent.width
        height: parent.height
        anchors.centerIn: parent
        anchors.verticalCenterOffset: kb.yNudge
        backgroundColorOverride: kb.bgColor
        hoverColorOverride: kb.hoverBgColor
        borderColorOverride: widgetBorderColor
        borderWidthOverride: Theme.uiBorderWidth
        cornerRadiusOverride: Math.round(Theme.keyboardRadius * sc())
        paddingScale: capsulePadding > 0 ? horizontalPadding / capsulePadding : 1
        verticalPaddingScale: capsulePadding > 0 ? verticalPadding / capsulePadding : 1
        backgroundKey: "keyboard"
        contentYOffset: kb.yNudge

        Row {
            id: row
            spacing: kb.iconSpacing * sc()

            // Metrics used for baseline alignment
            FontMetrics { id: fmText; font: label.font }
            FontMetrics { id: fmIcon; font: iconLabel.font }

            Label {
                id: iconLabel
                text: "\uf11c" // FA "keyboard"
                font.family: "Font Awesome 6 Free"
                font.styleName: "Regular"
                font.weight: Font.Normal
                font.pixelSize: Math.round(kb.fontPixelSize * kb.iconScale * Theme.keyboardFontScale)
                color: kb.iconColor
                verticalAlignment: Text.AlignVCenter
                padding: Math.round(Theme.keyboardIconPadding * sc())
                baselineOffset: fmIcon.ascent + kb.iconBaselineAdjust
            }

            Label {
                id: label
                text: kb.layoutText
                color: kb.textColor
                font.family: Theme.fontFamily
                font.weight: Theme.keyboardTextBold ? Font.DemiBold : Font.Medium
                verticalAlignment: Text.AlignVCenter
                padding: Math.round(Theme.keyboardTextPadding * sc())
                baselineOffset: fmText.ascent + kb.textBaselineAdjust
            }
        }

        TapHandler {
            target: capsule
            acceptedButtons: Qt.LeftButton
            gesturePolicy: TapHandler.ReleaseWithinBounds
            onTapped: {
                switchProc.cmd = ["hyprctl", "switchxkblayout", "current", "next"]
                switchProc.start()
            }
        }
        HoverHandler {
            target: capsule
            cursorShape: Qt.PointingHandCursor
        }
    }

    // Event path: prefer payload for snappy UI; fallback snapshot only for non‑main events.
    Connections {
        target: Hyprland
        function onRawEvent(a, b) {
            // Accept (eventName, payload), payload, or object { signal, data }
            let eventName =
                (typeof a === "string" && typeof b === "string") ? a :
                (a && typeof a === "object" && typeof a.signal === "string") ? a.signal :
                ""
            let payload =
                (typeof a === "string" && typeof b === "string") ? b :
                (typeof a === "string" && b === undefined)       ? a :
                (a && typeof a === "object")                     ? a.data :
                null
            if (!payload) return

            // Prefer explicit signal; otherwise heuristically treat payload as keyboard-layout if it matches known keyboards
            let isKbEvent = false
            if (eventName) {
                const ev = String(eventName).toLowerCase()
                isKbEvent = ev.indexOf("keyboard-layout") !== -1
            } else {
                const j = payload.indexOf(",")
                if (j > 0) {
                    const maybeKbd = payload.slice(0, j)
                    isKbEvent = kb.knownKeyboards.length ? kb.knownKeyboards.some(n => n === maybeKbd) : true
                }
            }
            if (!isKbEvent) return

            const i = payload.indexOf(","); if (i < 0) return
            const kbd = payload.slice(0, i)
            const layout = payload.slice(i + 1)

            const fromMain = (norm(kbd) === kb.mainDeviceNeedle)

            // Immediate UI update from event payload for snappy response
            const evTxt = shortenLayout(layout)
            if (evTxt && evTxt !== kb.layoutText) kb.layoutText = evTxt

            // If the event is not from the main keyboard, confirm quickly via devices snapshot
            // to correct a rare stale payload without penalizing the fast path.
            if (!fromMain) postEventProc.start()
        }
    }

    // Init path: detect main:true keyboard once and seed the initial label from the
    // devices snapshot so the indicator starts with a correct value.
    ProcessRunner {
        id: initProc
        cmd: ["hyprctl", "-j", "devices"]
        parseJson: true
        onJson: (obj) => {
            try {
                const list = (obj?.keyboards || [])
                kb.knownKeyboards = list.map(k => (k.name || ""))
                // Identify main keyboard once
                for (let k of list) {
                    if (k.main) {
                        kb.mainDeviceName = k.name || kb.mainDeviceName
                        kb.mainDeviceNeedle = norm(k.name || k.identifier || kb.mainDeviceName)
                        break
                    }
                }
                const pick = pickDevice(list)
                if (pick) kb.layoutText = shortenLayout(pick.active_keymap || pick.layout || kb.layoutText)
            } catch (_) { }
        }
    }

    ProcessRunner { id: switchProc; autoStart: false; restartOnExit: false }

    // Quick confirmation when we got an event from a non‑main device; this is intentionally
    // not run on every event to avoid introducing latency in the common path.
    ProcessRunner {
        id: postEventProc
        cmd: ["hyprctl", "-j", "devices"]
        parseJson: true
        onJson: (obj) => {
            try {
                const list = (obj?.keyboards || [])
                // Prefer main device snapshot
                let dev = null
                for (let k of list) { if (k.main) { dev = k; break } }
                if (!dev && list.length) dev = list[0]
                if (dev) {
                    const txt = shortenLayout(dev.active_keymap || dev.layout || kb.layoutText)
                    if (txt && txt !== kb.layoutText) kb.layoutText = txt
                }
            } catch (_) {}
        }
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
}
