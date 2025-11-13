import QtQuick
import qs.Settings
import qs.Components

CenteredCapsuleRow {
    id: clockWidget
    property var screen: (typeof modelData !== 'undefined' ? modelData : null)
    property int horizontalPadding: Math.max(4, Math.round(Theme.panelRowSpacingSmall * capsuleScale * 0.9))
    property int verticalPadding: Math.max(2, Math.round(Theme.uiSpacingXSmall * capsuleScale))
    backgroundKey: "clock"
    paddingScale: paddingScaleFor(horizontalPadding)
    verticalPaddingScale: paddingScaleFor(verticalPadding)
    iconVisible: false
    labelText: Time.time
    labelColor: Theme.timeTextColor
    fontPixelSize: Math.round(Theme.fontSizeSmall * Theme.timeFontScale * capsuleScale)
    labelFontFamily: Theme.fontFamily
    labelFontWeight: Theme.timeFontWeight

    interactive: true
    onClicked: calendar.toggle()

    Calendar {
        id: calendar
        screen: clockWidget.screen
    }
}
