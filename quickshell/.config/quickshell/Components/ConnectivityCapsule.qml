import QtQuick
import qs.Components

/*!
 * ConnectivityCapsule standardizes padding, font sizing, and capsule metrics for
 * network-related widgets that build on CenteredCapsuleRow.
 */
CenteredCapsuleRow {
    id: root

    property int labelPixelSize: Math.round(Theme.fontSizeSmall * capsuleScale)
    property int horizontalPadding: Math.max(4, Math.round(Theme.panelRowSpacingSmall * capsuleScale))
    property int iconSpacingPx: Theme.panelRowSpacingSmall
    property int textPaddingPx: Theme.panelRowSpacingSmall
    property color textColor: Theme.textPrimary

    paddingScale: paddingScaleFor(horizontalPadding)
    desiredInnerHeight: capsuleInner
    textPadding: textPaddingPx
    iconSpacing: iconSpacingPx
    fontPixelSize: labelPixelSize
    labelColor: textColor
    labelFontFamily: Theme.fontFamily
}
