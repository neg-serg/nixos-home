import QtQuick
import QtQuick.Controls
import qs.Components
import qs.Settings
import "../Helpers/Utils.js" as Utils

Item {
    id: root
    property int desiredHeight: 28
    property int fontPixelSize: 0
    property int textPadding: Theme.panelRowSpacingSmall
    property int iconSpacing: Theme.panelRowSpacingSmall
    property string iconMode: "glyph" // "glyph" | "material"
    property string iconGlyph: ""
    property string iconFontFamily: ""
    property string iconStyleName: ""
    property string materialIconName: ""
    property bool materialIconRounded: false
    property int iconVAdjust: 0
    property bool iconAutoTune: true
    property color iconColor: Theme.textSecondary
    property bool centerContent: false
    property bool labelVisible: true
    property string labelText: ""
    property color labelColor: Theme.textPrimary
    property string labelFontFamily: Theme.fontFamily
    property bool labelIsRichText: false
    property var screen: null
    property color bgColor: "transparent"
    property int centerOffset: 0

    readonly property int computedFontPx: fontPixelSize > 0
        ? fontPixelSize
        : Utils.computedInlineFontPx(desiredHeight, textPadding, Theme.panelComputedFontScale)

    implicitHeight: desiredHeight
    implicitWidth: lineBox.implicitWidth
    width: lineBox.implicitWidth
    height: desiredHeight

    Rectangle { anchors.fill: parent; color: bgColor; visible: bgColor !== "transparent" }

    Row {
        id: lineBox
        spacing: iconSpacing
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: root.centerOffset
        anchors.horizontalCenter: root.centerContent ? parent.horizontalCenter : undefined
        anchors.left: root.centerContent ? undefined : parent.left

        BaselineAlignedIcon {
            id: baselineIcon
            implicitHeight: root.desiredHeight
            labelRef: label
            mode: root.iconMode === "material" ? "material" : "text"
            text: root.iconGlyph
            fontFamily: root.iconFontFamily
            fontStyleName: root.iconStyleName
            color: root.iconColor
            icon: root.materialIconName
            rounded: root.materialIconRounded
            screen: root.screen
            autoTune: root.iconAutoTune
            baselineAdjust: root.iconVAdjust
        }

        Label {
            id: label
            visible: root.labelVisible
            textFormat: root.labelIsRichText ? Text.RichText : Text.PlainText
            text: root.labelText
            color: root.labelColor
            font.family: root.labelFontFamily
            font.pixelSize: root.computedFontPx
            padding: 0
            leftPadding: textPadding
            rightPadding: textPadding
            verticalAlignment: Text.AlignVCenter
        }
    }
}
