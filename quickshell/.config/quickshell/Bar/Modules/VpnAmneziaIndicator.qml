import QtQuick
import qs.Settings
import qs.Components
import "../../Helpers/Color.js" as Color
import "../../Helpers/Utils.js" as Utils
import qs.Services as Services

// Amnezia VPN status indicator (polls `ip -j -br a`)
CenteredCapsuleRow {
    id: root

    CapsuleContext { id: capsuleCtx; screen: Screen }
    readonly property real _scale: capsuleCtx.scale
    readonly property var capsuleMetrics: capsuleCtx.metrics

    // Match network usage label size with standard small font
    property int labelPixelSize:Math.round(Theme.fontSizeSmall * _scale)
    property bool useTheme:true
    property bool showLabel:true
    property int iconSpacingPx:Theme.vpnIconSpacing
    property int textPaddingPx:Theme.vpnTextPadding
    property int iconBaselineAdjustPx:Theme.vpnIconVAdjust
    property real iconScaleFactor:Theme.vpnIconScale
    property string iconName: "verified_user"
    property bool iconRounded:false

    property real accentSaturateBoost: Theme.vpnAccentSaturateBoost
    property real accentLightenTowardWhite: Theme.vpnAccentLightenTowardWhite
    property color onColor: Color.towardsWhite(Color.saturate(Theme.accentPrimary, accentSaturateBoost), accentLightenTowardWhite)
    property color offColor: useTheme ? Theme.textDisabled  : Theme.textDisabled
    property real desaturateAmount:Theme.vpnDesaturateAmount
    property color accentBase: Color.saturate(Theme.accentPrimary, accentSaturateBoost)
    property color accentColor: desaturateColor(accentBase, desaturateAmount)

    property real connectedOpacity: Theme.vpnConnectedOpacity
    property real disconnectedOpacity: Theme.vpnDisconnectedOpacity
    property bool connected: false
    property string matchedIf: ""
    property int horizontalPadding: Math.max(4, Math.round(Theme.panelRowSpacingSmall * _scale))
    backgroundKey: "vpn"
    paddingScale: capsuleMetrics.padding > 0
        ? horizontalPadding / capsuleMetrics.padding
        : 1
    visible: connected
    desiredInnerHeight: capsuleCtx.inner
    fontPixelSize: root.labelPixelSize
    textPadding: root.textPaddingPx
    iconSpacing: root.iconSpacingPx
    iconMode: "material"
    materialIconName: root.iconName
    materialIconRounded: root.iconRounded
    iconScale: root.iconScaleFactor
    iconVAdjust: root.iconBaselineAdjustPx
    iconAutoTune: true
    iconColor: root.iconColor()
    labelVisible: root.showLabel
    labelText: "VPN"
    labelColor: root.iconColor()
    labelFontFamily: Theme.fontFamily

    Connections {
        target: Services.Connectivity
        function onInterfacesChanged() {
            try { checkInterfaces(Services.Connectivity.interfaces) }
            catch (e) { root.connected = false; root.matchedIf = "" }
        }
    }

    function mixColor(a, b, t) {
        return Qt.rgba(
            a.r * (1 - t) + b.r * t,
            a.g * (1 - t) + b.g * t,
            a.b * (1 - t) + b.b * t,
            a.a * (1 - t) + b.a * t
        )
    }
    function grayOf(c) {
        const y = 0.2126 * c.r + 0.7152 * c.g + 0.0722 * c.b
        return Qt.rgba(y, y, y, c.a)
    }
    function desaturateColor(c, amount) {
        amount = Utils.clamp(amount || 0, 0, 1)
        return mixColor(c, grayOf(c), amount)
    }

    function checkInterfaces(arr) {
        if (!Array.isArray(arr)) { root.connected = false; root.matchedIf = ""; return }
        let found = false
        let name = ""
        for (let it of arr) {
            const ifname = (it && it.ifname) ? String(it.ifname) : ""
            const nlow = ifname.toLowerCase()
            const looksAmnezia = nlow.includes("awg") || nlow.includes("amnez")
            if (!looksAmnezia) continue
            const addrs = Array.isArray(it.addr_info) ? it.addr_info : []
            if (addrs.length > 0) { found = true; name = ifname; break }
        }
        root.connected = found
        root.matchedIf = name
    }

    property bool muted:true
    opacity: root.hovered ? 1.0 : (connected ? connectedOpacity : disconnectedOpacity)
    function iconColor() {
        if (!connected) return offColor
        return accentColor
    }

    Component.onCompleted: { try { checkInterfaces(Services.Connectivity.interfaces) } catch (_) {} }
}
