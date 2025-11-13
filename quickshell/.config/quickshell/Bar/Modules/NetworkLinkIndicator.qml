import QtQuick
import qs.Components
import qs.Services as Services
import qs.Settings
import "../../Helpers/CapsuleMetrics.js" as Capsule

// Standalone indicator for physical link / internet availability
WidgetCapsule {
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

    readonly property color connectedColor: Theme.textSecondary
    readonly property color warningColor: (Settings.settings.networkNoInternetColor || Theme.warning)
    readonly property color errorColor: (Settings.settings.networkNoLinkColor || Theme.error)
    property bool hasLink: Services.Connectivity.hasLink
    property bool hasInternet: Services.Connectivity.hasInternet
    property int horizontalPadding: Math.max(4, Math.round(Theme.panelRowSpacingSmall * _scale))
    backgroundKey: "networkLink"
    paddingScale: capsuleMetrics.padding > 0
        ? horizontalPadding / capsuleMetrics.padding
        : 1

    SmallInlineStat {
        id: inlineView
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
