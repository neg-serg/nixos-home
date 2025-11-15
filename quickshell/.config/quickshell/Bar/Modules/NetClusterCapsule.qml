import QtQuick
import qs.Components
import qs.Settings
import "../../Components" as LocalComponents
import "../../Helpers/Color.js" as Color
import "../../Helpers/ConnectivityUi.js" as ConnUi

ConnectivityCapsule {
    id: root

    property bool vpnVisible: ConnectivityState.vpnConnected
    property bool linkVisible: true
    property string throughputText: ConnectivityState.throughputText
    property bool vpnIconRounded: false
    property bool linkIconRounded: false
    property bool iconSquare: true

    property real accentSaturateBoost: Theme.vpnAccentSaturateBoost
    property real accentLightenTowardWhite: Theme.vpnAccentLightenTowardWhite
    property real desaturateAmount: Theme.vpnDesaturateAmount
    property color accentBase: Color.saturate(Theme.accentPrimary, accentSaturateBoost)
    property color accentColor: desaturateColor(accentBase, desaturateAmount)
    property color vpnOffColor: Theme.textDisabled

    property var iconPool: (["graph_1", "graph_2", "graph_3", "graph_4", "graph_5", "graph_6", "graph_7", "schema", "family_history"])
    property string iconConnected: "network_check"
    property string iconNoInternet: "network_ping"
    property string iconDisconnected: "link_off"
    property bool useStatusFallbackIcons: false
    property string _selectedIcon: "schema"

    readonly property bool vpnConnected: ConnectivityState.vpnConnected
    readonly property bool hasLink: ConnectivityState.hasLink
    readonly property bool hasInternet: ConnectivityState.hasInternet
    readonly property bool _hasLeading: vpnVisible || linkVisible
    readonly property int clusterSpacing: Math.max(0, Theme.networkCapsuleIconSpacing)
    readonly property color vpnIconColor: vpnConnected ? accentColor : vpnOffColor
    readonly property color linkIconColor: ConnUi.iconColor(hasLink, hasInternet, Settings.settings, Theme)
    readonly property string currentLinkIconName: useStatusFallbackIcons ? (!hasLink ? iconDisconnected : (!hasInternet ? iconNoInternet : iconConnected)) : _selectedIcon

    backgroundKey: "network"
    iconVisible: false
    glyphLeadingActive: _hasLeading
    labelText: throughputText
    labelVisible: throughputText && throughputText.length > 0

    leadingContent: Row {
        id: iconRow
        visible: root._hasLeading
        spacing: root.clusterSpacing
        height: root.desiredInnerHeight

        LocalComponents.ConnectivityIconSlot {
            id: vpnSlot
            active: root.vpnVisible
            square: root.iconSquare
            box: root.desiredInnerHeight
            mode: "material"
            icon: "verified_user"
            rounded: root.vpnIconRounded
            color: root.vpnIconColor
            screen: root.screen
            labelRef: root.labelItem
            alignTarget: root.labelItem
            anchors.verticalCenter: parent.verticalCenter
        }

        LocalComponents.ConnectivityIconSlot {
            id: linkSlot
            active: root.linkVisible
            square: root.iconSquare
            box: root.desiredInnerHeight
            mode: "material"
            icon: root.currentLinkIconName
            rounded: root.linkIconRounded
            color: root.linkIconColor
            screen: root.screen
            labelRef: root.labelItem
            alignTarget: root.labelItem
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    function mixColor(a, b, t) {
        return Qt.rgba(a.r * (1 - t) + b.r * t, a.g * (1 - t) + b.g * t, a.b * (1 - t) + b.b * t, a.a * (1 - t) + b.a * t);
    }

    function grayOf(c) {
        const y = 0.2126 * c.r + 0.7152 * c.g + 0.0722 * c.b;
        return Qt.rgba(y, y, y, c.a);
    }

    function desaturateColor(c, amount) {
        const clamped = Math.min(1, Math.max(0, amount || 0));
        return mixColor(c, grayOf(c), clamped);
    }

    function _pickRandomIcon() {
        try {
            const pool = Array.isArray(iconPool) && iconPool.length ? iconPool : ["schema"];
            const idx = Math.floor(Math.random() * pool.length);
            _selectedIcon = pool[Math.max(0, Math.min(pool.length - 1, idx))];
        } catch (e) {
            _selectedIcon = "schema";
        }
    }

    Component.onCompleted: _pickRandomIcon()
    onIconPoolChanged: _pickRandomIcon()
}
