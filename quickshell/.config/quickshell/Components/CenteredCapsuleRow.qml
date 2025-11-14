import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
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
    property int minContentWidth: 0
    property int maxContentWidth: 0
    property int contentWidth: 0
    property int labelMaxWidth: 0
    property int labelElideMode: Text.ElideRight

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
    property int iconVAdjust: 0
    property bool iconAutoTune: true
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

    readonly property int _iconSlotWidth: (root.iconVisible ? Math.max(0, baselineIcon.implicitWidth || 0) : 0)
    readonly property int _tailSlotWidth: Math.max(0, tailSlot.implicitWidth || 0)
    readonly property int _labelImplicitWidth: (root.labelVisible ? Math.max(0, label.implicitWidth || 0) : 0)
    readonly property int _spacingBeforeLabel: (root.iconVisible && root.labelVisible && _iconSlotWidth > 0 && _labelImplicitWidth > 0)
        ? iconSpacing
        : 0
    readonly property int _spacingBeforeTail: (((_iconSlotWidth > 0) || (_labelImplicitWidth > 0)) && _tailSlotWidth > 0)
        ? iconSpacing
        : 0
    readonly property int _naturalWidth: _iconSlotWidth + _tailSlotWidth + _labelImplicitWidth + _spacingBeforeLabel + _spacingBeforeTail
    readonly property int _contentWidth: (function() {
        var width = Math.max(minContentWidth, _naturalWidth);
        if (contentWidth > 0) width = contentWidth;
        if (maxContentWidth > 0) width = Math.min(width, maxContentWidth);
        return width;
    })()
    readonly property int _labelAvailableWidth: Math.max(0, _contentWidth - (_iconSlotWidth + _tailSlotWidth + _spacingBeforeLabel + _spacingBeforeTail))
    readonly property double _labelClampTarget: (function() {
        var clamp = (_labelAvailableWidth > 0) ? _labelAvailableWidth : Number.POSITIVE_INFINITY;
        if (root.labelMaxWidth > 0) clamp = Math.min(root.labelMaxWidth, clamp);
        return clamp;
    })()

    Item {
        id: lineBox
        width: _contentWidth
        height: rowLayout.implicitHeight
        implicitWidth: width
        implicitHeight: height
        clip: true
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        RowLayout {
            id: rowLayout
            anchors.fill: parent
            spacing: iconSpacing
            layoutDirection: Qt.LeftToRight

            LocalComponents.BaselineAlignedIcon {
                id: baselineIcon
                visible: root.iconVisible
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredWidth: root.iconVisible ? implicitWidth : 0
                Layout.minimumWidth: root.iconVisible ? implicitWidth : 0
                Layout.maximumWidth: root.iconVisible ? implicitWidth : 0
                Layout.preferredHeight: root.desiredInnerHeight
                implicitHeight: root.desiredInnerHeight
                labelRef: label
                mode: root.iconMode === "material" ? "material" : "text"
                alignMode: root.labelVisible ? "baseline" : "optical"
                alignTarget: root.labelVisible ? label : null
                text: root.iconGlyph
                fontFamily: root.iconFontFamily
                fontStyleName: root.iconStyleName
                color: root.iconColor
                icon: root.materialIconName
                rounded: root.materialIconRounded
                screen: root.screen
                autoTune: root.iconAutoTune
                baselineAdjust: root.iconVAdjust
                padding: root.iconPadding
            }

            Label {
                id: label
                visible: root.labelVisible
                Layout.fillWidth: false
                Layout.alignment: Qt.AlignVCenter
                Layout.minimumWidth: 0
                Layout.preferredWidth: _labelImplicitWidth
                Layout.maximumWidth: root.labelVisible ? _labelClampTarget : 0
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
                elide: root.labelElideMode
                clip: true
                maximumLineCount: 1
            }

            FontMetrics {
                id: labelMetrics
                font: label.font
            }

            Item {
                id: tailSlot
                Layout.preferredWidth: childrenRect.width
                Layout.preferredHeight: childrenRect.height
                Layout.alignment: Qt.AlignVCenter
                implicitWidth: childrenRect.width
                implicitHeight: childrenRect.height
            }
        }
    }
    default property alias tailContent: tailSlot.data

    implicitWidth: root.horizontalPadding * 2 + lineBox.width
    implicitHeight: root.forceHeightFromMetrics
        ? Math.max(root.capsuleMetrics.height, lineBox.implicitHeight + root.verticalPadding * 2)
        : lineBox.implicitHeight + root.verticalPadding * 2
}
