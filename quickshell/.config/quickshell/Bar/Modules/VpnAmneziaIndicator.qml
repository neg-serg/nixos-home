import QtQuick
import qs.Settings
import qs.Components
import "../../Helpers/Color.js" as Color
import "../../Helpers/Utils.js" as Utils

// Amnezia VPN status indicator (polls `ip -j -br a`)
ConnectivityCapsule {
    id: root

    property bool useTheme:true
    property bool showLabel:true
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
    readonly property bool connected: ConnectivityState.vpnConnected
    readonly property string matchedIf: ConnectivityState.vpnInterface
    backgroundKey: "vpn"
    visible: connected
    iconMode: "material"
    materialIconName: root.iconName
    materialIconRounded: root.iconRounded
    iconAutoTune: true
    iconColor: root.iconColor()
    labelVisible: root.showLabel
    labelText: "VPN"
    labelColor: root.iconColor()
    labelFontFamily: Theme.fontFamily

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

    property bool muted:true
    opacity: root.hovered ? 1.0 : (connected ? connectedOpacity : disconnectedOpacity)
    function iconColor() {
        if (!connected) return offColor
        return accentColor
    }

}
