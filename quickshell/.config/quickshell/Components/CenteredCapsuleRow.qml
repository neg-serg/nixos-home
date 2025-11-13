import QtQuick
import QtQuick.Controls
import "." as LocalComponents
import qs.Settings
import "../Helpers/Utils.js" as Utils

LocalComponents.CapsuleButton {
    id: root

    // Layout + sizing
    property int desiredInnerHeight: capsuleMetrics.inner
    property int fontPixelSize: 0
    property int textPadding: Theme.panelRowSpacingSmall
    property int iconSpacing: Theme.panelRowSpacingSmall
    property real centerOffset: 0
    property bool centerRow: true
    property bool labelVisible: true
    property bool iconVisible: true
    property int iconPadding: 0

    // Label configuration
    property string labelText: ""
    property color labelColor: Theme.textPrimary
    property string labelFontFamily: Theme.fontFamily
    property int labelFontWeight: Font.Medium
    property bool labelIsRichText: false
    property int labelBaselineAdjust: 0

    // Icon configuration
    property string iconMode: "material" // "material", "glyph"
    property string iconGlyph: ""
    property string iconFontFamily: ""
    property string iconStyleName: ""
    property string materialIconName: ""
    property bool materialIconRounded: false
    property real iconScale: 1.0
    property int iconVAdjust: 0
    property bool iconAutoTune: false
    property color iconColor: Theme.textSecondary

    // Accessors
    readonly property alias row: lineBox
    readonly property alias iconItem: baselineIcon
    readonly property alias labelItem: label

    readonly property int computedFontPx: fontPixelSize > 0
        ? fontPixelSize
        : Utils.computedInlineFontPx(desiredInnerHeight, textPadding, Theme.panelComputedFontScale)

    centerContent: centerRow
    contentYOffset: centerOffset
    interactive: false

    Row {
        id: lineBox
        spacing: iconSpacing
        anchors.horizontalCenter: undefined
        anchors.left: parent.left
        anchors.top: parent.top

        LocalComponents.BaselineAlignedIcon {
            id: baselineIcon
            visible: root.iconVisible
            width: root.iconVisible ? implicitWidth : 0
            height: root.iconVisible ? implicitHeight : 0
            implicitHeight: root.desiredInnerHeight
            labelRef: label
            mode: root.iconMode === "material" ? "material" : "text"
            text: root.iconGlyph
            fontFamily: root.iconFontFamily
            fontStyleName: root.iconStyleName
            color: root.iconColor
            icon: root.materialIconName
            rounded: root.materialIconRounded
            screen: root.screen
            scale: root.iconScale
            autoTune: root.iconAutoTune
            baselineAdjust: root.iconVAdjust
            padding: root.iconPadding
        }

        Label {
            id: label
            visible: root.labelVisible
            width: visible ? implicitWidth : 0
            height: visible ? implicitHeight : 0
            textFormat: root.labelIsRichText ? Text.RichText : Text.PlainText
            text: root.labelText
            color: root.labelColor
            font.family: root.labelFontFamily
            font.weight: root.labelFontWeight
            font.pixelSize: root.computedFontPx
            padding: 0
            leftPadding: root.textPadding
            rightPadding: root.textPadding
            verticalAlignment: Text.AlignVCenter
            baselineOffset: labelMetrics.ascent + root.labelBaselineAdjust
        }

        FontMetrics {
            id: labelMetrics
            font: label.font
        }

        Item {
            id: tailSlot
            width: childrenRect.width
            height: childrenRect.height
            implicitWidth: childrenRect.width
            implicitHeight: childrenRect.height
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    default property alias tailContent: tailSlot.data

    implicitWidth: root.horizontalPadding * 2 + lineBox.implicitWidth
    implicitHeight: root.forceHeightFromMetrics
        ? Math.max(root.capsuleMetrics.height, lineBox.implicitHeight + root.verticalPadding * 2)
        : lineBox.implicitHeight + root.verticalPadding * 2
}
