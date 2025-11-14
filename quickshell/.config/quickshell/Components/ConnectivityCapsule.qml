import QtQuick
import qs.Components
import qs.Settings

/*!
 * ConnectivityCapsule standardizes padding, font sizing, and capsule metrics for
 * network-related widgets that build on CenteredCapsuleRow.
 */
CenteredCapsuleRow {
    id: root

    property int labelPixelSize: Math.round(Theme.fontSizeSmall * capsuleScale)
    property int iconSpacingPx: Theme.panelRowSpacingSmall
    property int textPaddingPx: Theme.panelRowSpacingSmall
    property color textColor: Theme.textPrimary
    property int capsuleWidthPx: Theme.panelWidgetMinWidth

    desiredInnerHeight: capsuleInner
    textPadding: textPaddingPx
    iconSpacing: iconSpacingPx
    fontPixelSize: labelPixelSize
    labelColor: textColor
    labelFontFamily: Theme.fontFamily
    minContentWidth: capsuleWidthPx
    contentWidth: capsuleWidthPx
    labelMaxWidth: capsuleWidthPx - iconSpacingPx
}
