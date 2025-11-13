import QtQuick
import qs.Settings
import qs.Components

CenteredCapsuleRow {
    id: clockWidget
    property var screen: (typeof modelData !== 'undefined' ? modelData : null)
    CapsuleContext { id: capsuleCtx; screen: clockWidget.screen }
    readonly property real _scale: capsuleCtx.scale
    readonly property var capsuleMetrics: capsuleCtx.metrics
    property int horizontalPadding: Math.max(4, Math.round(Theme.panelRowSpacingSmall * _scale * 0.9))
    property int verticalPadding: Math.max(2, Math.round(Theme.uiSpacingXSmall * _scale))
    backgroundKey: "clock"
    paddingScale: capsuleMetrics.padding > 0
        ? horizontalPadding / capsuleMetrics.padding
        : 1
    verticalPaddingScale: capsuleMetrics.padding > 0
        ? verticalPadding / capsuleMetrics.padding
        : 1
    iconVisible: false
    labelText: Time.time
    labelColor: Theme.timeTextColor
    fontPixelSize: Math.round(Theme.fontSizeSmall * Theme.timeFontScale * _scale)
    labelFontFamily: Theme.fontFamily
    labelFontWeight: Theme.timeFontWeight

    interactive: true
    onClicked: calendar.visible = !calendar.visible

    Calendar {
        id: calendar
        screen: clockWidget.screen
        visible: false
    }
}
