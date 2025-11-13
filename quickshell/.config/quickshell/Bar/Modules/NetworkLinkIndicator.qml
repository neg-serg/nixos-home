import QtQuick
import QtQuick.Controls
import qs.Components
import qs.Services as Services
import qs.Settings
import "../../Helpers/Color.js" as Color
import "../../Helpers/WidgetBg.js" as WidgetBg
import "../../Helpers/CapsuleMetrics.js" as Capsule

// Standalone indicator for physical link / internet availability
Rectangle {
    id: root

    property var screen: null
    readonly property real _scale: Theme.scale(Screen)
    readonly property var capsuleMetrics: Capsule.metrics(Theme, _scale)
    readonly property int capsulePadding: capsuleMetrics.padding
    property int desiredHeight: capsuleMetrics.inner
    readonly property int capsuleHeight: capsuleMetrics.height
    property int fontPixelSize: Math.round(Theme.fontSizeSmall * _scale)

    property bool showLabel: false
    property string labelText: "NET"
    property int iconSpacing: Theme.panelRowSpacingSmall
    property int textPadding: Theme.panelRowSpacingSmall

    property real iconScale: Theme.networkLinkIconScale
    property int iconVAdjust: Theme.networkLinkIconVAdjust
    // Icon selection pool (Material Symbols names). Picked randomly on init.
    property var iconPool: ([
        "graph_1", "graph_2", "graph_3", "graph_4",
        "graph_5", "graph_6", "graph_7",
        "schema", "family_sharing", "family_history"
    ])
    property string iconConnected: "network_check"
    property string iconNoInternet: "network_ping"
    property string iconDisconnected: "link_off"
    property bool useStatusFallbackIcons: false
    property string _selectedIcon: "schema"
    property color bgColor: WidgetBg.color(Settings.settings, "networkLink", "rgba(10, 12, 20, 0.2)")
    readonly property real hoverMixAmount: 0.18
    readonly property color hoverColor: Color.mix(bgColor, Qt.rgba(1, 1, 1, 1), hoverMixAmount)

    readonly property color connectedColor: Theme.textSecondary
    readonly property color warningColor: (Settings.settings.networkNoInternetColor || Theme.warning)
    readonly property color errorColor: (Settings.settings.networkNoLinkColor || Theme.error)
    property bool hasLink: Services.Connectivity.hasLink
    property bool hasInternet: Services.Connectivity.hasInternet
    property int horizontalPadding: Math.max(4, Math.round(Theme.panelRowSpacingSmall * _scale))

    implicitHeight: capsuleHeight
    implicitWidth: inlineView.implicitWidth + 2 * horizontalPadding
    width: implicitWidth
    height: implicitHeight
    color: hoverHandler.hovered ? hoverColor : bgColor
    radius: Theme.cornerRadiusSmall
    border.width: Theme.uiBorderWidth
    border.color: Color.withAlpha(Theme.textPrimary, 0.08)
    antialiasing: true

    HoverHandler { id: hoverHandler }

    SmallInlineStat {
        id: inlineView
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        desiredHeight: Math.max(1, capsuleMetrics.inner)
        fontPixelSize: root.fontPixelSize
        textPadding: root.textPadding
        iconSpacing: root.iconSpacing
        iconMode: "material"
        materialIconName: root.currentIconName()
        iconAutoTune: true
        iconScale: root.iconScale
        iconVAdjust: root.iconVAdjust
        iconColor: root.currentIconColor()
        labelVisible: root.showLabel
        labelText: root.labelText
        labelColor: root.currentIconColor()
        centerContent: true
    }

    function currentIconName() {
        if (useStatusFallbackIcons) {
            if (!hasLink) return iconDisconnected;
            if (!hasInternet) return iconNoInternet;
        }
        return _selectedIcon;
    }

    function currentIconColor() {
        if (!hasLink) return errorColor;
        if (!hasInternet) return warningColor;
        return connectedColor;
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
