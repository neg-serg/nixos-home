import QtQuick
import qs.Components
import qs.Services as Services
import qs.Settings
import "../../Helpers/ConnectivityUi.js" as ConnUi

// Standalone indicator for physical link / internet availability
ConnectivityCapsule {
    id: root

    property bool showLabel: false
    property string labelTextValue: "NET"
    property real iconScaleFactor: Theme.networkLinkIconScale
    property int iconVAdjustPx: Theme.networkLinkIconVAdjust
    // Icon selection pool (Material Symbols names). Picked randomly on init.
    property var iconPool: ([
        "graph_1", "graph_2", "graph_3", "graph_4",
        "graph_5", "graph_6", "graph_7",
        "schema", "family_history"
    ])
    property string iconConnected: "network_check"
    property string iconNoInternet: "network_ping"
    property string iconDisconnected: "link_off"
    property bool useStatusFallbackIcons: false
    property string _selectedIcon: "schema"

    readonly property color connectedColor: Theme.textSecondary
    readonly property color warningColor: ConnUi.warningColor(Settings.settings, Theme)
    readonly property color errorColor: ConnUi.errorColor(Settings.settings, Theme)
    property bool hasLink: Services.Connectivity.hasLink
    property bool hasInternet: Services.Connectivity.hasInternet
    backgroundKey: "networkLink"
    iconMode: "material"
    materialIconName: currentIconName()
    iconAutoTune: true
    iconScale: root.iconScaleFactor
    iconVAdjust: root.iconVAdjustPx
    iconColor: currentIconColor()
    labelVisible: root.showLabel
    labelText: root.labelTextValue
    labelColor: currentIconColor()

    function currentIconName() {
        if (useStatusFallbackIcons) {
            if (!hasLink) return iconDisconnected;
            if (!hasInternet) return iconNoInternet;
        }
        return _selectedIcon;
    }

    function currentIconColor() {
        return ConnUi.iconColor(hasLink, hasInternet, Settings.settings, Theme);
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
