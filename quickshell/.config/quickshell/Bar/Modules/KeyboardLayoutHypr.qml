import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs.Components
import qs.Settings
import "../../Helpers/Utils.js" as Utils

Item {
    id: kb

    property string deviceMatch: ""
    property alias fontPixelSize:label.font.pixelSize
    property int desiredHeight:Math.round(Theme.keyboardHeight * Theme.scale(Screen))
    property var screen:null
    property bool useTheme:true
    property int yNudge:0

    property real iconScale:Theme.keyboardIconScale
    property int iconSpacing:Theme.keyboardIconSpacing
    property color iconColor:useTheme ? Theme.keyboardIconColor : Theme.textSecondary

    property int iconBaselineAdjust:Theme.keyboardIconBaselineOffset
    property int textBaselineAdjust:Theme.keyboardTextBaselineOffset

    property color bgColor:useTheme ? Theme.keyboardBgColor : Theme.background
    property color textColor:useTheme ? Theme.keyboardTextColor : Theme.textPrimary
    property color hoverBgColor:useTheme ? Theme.keyboardHoverBgColor : Theme.surfaceHover

    property string layoutText: "??"
    property string deviceName: ""
    // Normalized device selector used for matching JSON devices reliably
    property string deviceNeedle: ""
    property var knownKeyboards:[]
    // If true, we only accept events for the pinned deviceName
    // This prevents the indicator from jumping between multiple keyboards.
    readonly property bool hasPinnedDevice: deviceName.length > 0

    function sc() {
        const s = kb.screen || (Quickshell.screens && Quickshell.screens.length ? Quickshell.screens[0] : null)
        return s ? Theme.scale(s) : 1
    }

    readonly property int margin: Math.round(Theme.keyboardMargin * sc())

    implicitWidth: Math.ceil(row.implicitWidth + 2 * margin)
    implicitHeight: capsule.height

    Rectangle {
        id: capsule
        readonly property bool hovered: ma.containsMouse
        height: Utils.clamp(row.implicitHeight + 2 * kb.margin, kb.desiredHeight, row.implicitHeight + 2 * kb.margin)
        width: Utils.clamp(row.implicitWidth + 2 * kb.margin, Math.round(Theme.keyboardMinWidth * sc()), row.implicitWidth + 2 * kb.margin)
        color: hovered ? kb.hoverBgColor : kb.bgColor
        radius: Math.round(Theme.keyboardRadius * sc())
        opacity: hovered ? Theme.keyboardHoverOpacity : Theme.keyboardNormalOpacity
        antialiasing: true

        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: kb.yNudge

        // Metrics used for baseline alignment
        FontMetrics { id: fmText; font: label.font }
        FontMetrics { id: fmIcon; font: iconLabel.font }

        Row {
            id: row
            anchors.fill: parent
            anchors.margins: kb.margin
            spacing: kb.iconSpacing * sc()

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

        MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                const target = (kb.deviceName && kb.deviceName.length) ? kb.deviceName : "current"
                // Execute hyprctl directly (avoid spawning a shell) for faster switching
                switchProc.cmd = ["hyprctl", "switchxkblayout", target, "next"]
                switchProc.start()
            }
        }
    }

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

            // Filter strictly to keyboard-layout events to avoid false positives
            if (!eventName) return
            const ev = String(eventName).toLowerCase()
            if (ev.indexOf("keyboard-layout") === -1) return

            const i = payload.indexOf(","); if (i < 0) return
            const kbd = payload.slice(0, i)
            const layout = payload.slice(i + 1)

            const byMatch = deviceAllowed(kbd)
            const byKnown = kb.knownKeyboards.length ? kb.knownKeyboards.some(n => n === kbd) : true
            const byPinned = kb.hasPinnedDevice ? (kb.deviceName === kbd) : true

            // Prefer the keyboard that emitted the event; keep a normalized needle for matching
            if (kbd) {
                kb.deviceName = kbd
                kb.deviceNeedle = norm(kbd)
            }

            if (!(byMatch && byKnown)) return

            // Update immediately from event payload for snappy UI
            const evTxt = shortenLayout(layout)
            if (evTxt && evTxt !== kb.layoutText) kb.layoutText = evTxt

            // Confirm with devices snapshot right away (no artificial delay)
            postEventProc.start()
        }
    }

    ProcessRunner {
        id: initProc
        cmd: ["hyprctl", "-j", "devices"]
        parseJson: true
        onJson: (obj) => {
            try {
                const list = (obj?.keyboards || [])
                kb.knownKeyboards = list.map(k => (k.name || ""))
                const pick = pickDevice(list)
                if (pick) kb.layoutText = shortenLayout(pick.active_keymap || pick.layout || kb.layoutText)
            } catch (_) { }
        }
    }

    ProcessRunner { id: switchProc; autoStart: false; restartOnExit: false }

    ProcessRunner {
        id: postEventProc
        cmd: ["hyprctl", "-j", "devices"]
        parseJson: true
        onJson: (obj) => {
            try {
                const list = (obj?.keyboards || [])
                const dev = pickDevice(list)
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
