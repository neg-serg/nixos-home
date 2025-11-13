import QtQuick
import qs.Settings
import "../Helpers/CapsuleMetrics.js" as Capsule
import "../Helpers/WidgetBg.js" as WidgetBg
import "../Helpers/Color.js" as ColorHelpers

Rectangle {
    id: root

    property string backgroundKey: ""
    property color fallbackColor: Qt.rgba(10/255, 12/255, 20/255, 0.2)
    property color backgroundColorOverride: "transparent"
    property bool hoverEnabled: true
    property color hoverColorOverride: "transparent"
    property real hoverMixAmount: 0.18
    property color hoverMixColor: Qt.rgba(1, 1, 1, 1)
    property bool borderVisible: true
    property color borderColorOverride: "transparent"
    property real borderOpacity: 0.08
    property real paddingScale: 1.0
    property real minPadding: 4
    property real verticalPaddingScale: 0.6
    property bool forceHeightFromMetrics: true
    property bool centerContent: true
    property real cornerRadiusOverride: -1
    property real borderWidthOverride: -1
    property real contentYOffset: 0
    property int cursorShape: Qt.ArrowCursor

    readonly property real _scale: Theme.scale(Screen)
    readonly property var _metrics: Capsule.metrics(Theme, _scale)
    readonly property var capsuleMetrics: _metrics
    readonly property color _baseColor: backgroundColorOverride.a > 0
            ? backgroundColorOverride
            : WidgetBg.color(Settings.settings, backgroundKey, fallbackColor)
    readonly property int horizontalPadding: Math.max(minPadding, Math.round(_metrics.padding * paddingScale))
    readonly property int verticalPadding: Math.max(2, Math.round(_metrics.padding * verticalPaddingScale))
    readonly property color _hoverColor: ColorHelpers.mix(_baseColor, hoverMixColor, hoverMixAmount)

    implicitWidth: 0
    implicitHeight: forceHeightFromMetrics ? _metrics.height : 0
    width: implicitWidth
    height: implicitHeight

    radius: cornerRadiusOverride >= 0 ? cornerRadiusOverride : Theme.cornerRadiusSmall
    antialiasing: true
    border.width: borderVisible
            ? (borderWidthOverride >= 0 ? borderWidthOverride : Theme.uiBorderWidth)
            : 0
    border.color: borderVisible
            ? (borderColorOverride.a > 0
                ? borderColorOverride
                : ColorHelpers.withAlpha(Theme.textPrimary, borderOpacity))
            : "transparent"
    color: hoverEnabled && hoverTracker.hovered
        ? (hoverColorOverride.a > 0 ? hoverColorOverride : _hoverColor)
        : _baseColor

    HoverHandler {
        id: hoverTracker
        enabled: root.hoverEnabled
        acceptedDevices: PointerDevice.Mouse | PointerDevice.Stylus | PointerDevice.TouchPad
        cursorShape: root.cursorShape
    }
    readonly property bool hovered: hoverTracker.hovered

    Item {
        id: contentArea
        anchors {
            fill: parent
            leftMargin: horizontalPadding
            rightMargin: horizontalPadding
            topMargin: verticalPadding
            bottomMargin: verticalPadding
        }

    }

    default property alias content: contentArea.data
}
