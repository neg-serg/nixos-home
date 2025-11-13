import QtQuick
import QtQuick.Controls
import qs.Settings
import "../../Helpers/Utils.js" as Utils
import qs.Components
import qs.Services as Services
import "../../Helpers/WidgetBg.js" as WidgetBg
import "../../Helpers/Color.js" as Color

Rectangle {
    id: root
    property var screen:null
    property int desiredHeight:Math.round(Theme.panelHeight * Theme.scale(Screen))
    // Use standard small font size to match other bar text
    property int fontPixelSize:Math.round(Theme.fontSizeSmall * Theme.scale(Screen))
    property color textColor:Theme.textPrimary
    property color bgColor:WidgetBg.color(Settings.settings, "network", "rgba(10, 12, 20, 0.2)")
    property int iconSpacing:Theme.panelRowSpacingSmall
    property string deviceMatch: ""
    property string displayText: "0"
    property bool useTheme:true
    property bool hasLink:Services.Connectivity.hasLink
    property bool hasInternet:Services.Connectivity.hasInternet

    property real iconScale:Theme.networkIconScale
    property color iconColor:useTheme ? Theme.textSecondary : Theme.textSecondary
    property int iconVAdjust:Theme.networkIconVAdjust   // vertical nudge (px)
    property string iconText: ""
    property string iconFontFamily: "Font Awesome 6 Free"
    property string iconStyleName: "Solid"

    property int textPadding:Theme.panelRowSpacingSmall
    readonly property real _scale: Theme.scale(Screen)
    property int horizontalPadding: Math.max(4, Math.round(Theme.panelRowSpacingSmall * _scale))
    property int verticalPadding: Math.max(2, Math.round(Theme.uiSpacingXSmall * _scale))

    implicitHeight: Math.max(desiredHeight, inlineView.implicitHeight + 2 * verticalPadding)
    implicitWidth: inlineView.implicitWidth + 2 * horizontalPadding
    width: implicitWidth
    height: implicitHeight
    color: bgColor
    radius: Theme.cornerRadiusSmall
    border.width: Theme.uiBorderWidth
    border.color: Color.withAlpha(Theme.textPrimary, 0.08)
    antialiasing: true

    readonly property int computedFontPx: fontPixelSize > 0
        ? fontPixelSize
        : Utils.computedInlineFontPx(desiredHeight, textPadding, Theme.panelComputedFontScale)

    SmallInlineStat {
        id: inlineView
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: horizontalPadding
        desiredHeight: root.desiredHeight
        fontPixelSize: root.fontPixelSize
        textPadding: root.textPadding
        iconSpacing: root.iconSpacing
        iconMode: "glyph"
        iconGlyph: iconText
        iconFontFamily: iconFontFamily
        iconStyleName: iconStyleName
        iconScale: root.iconScale
        iconVAdjust: root.iconVAdjust
        iconColor: currentIconColor()
        labelIsRichText: false
        labelText: displayText
        labelColor: textColor
        labelFontFamily: Theme.fontFamily
    }

    function fmtKiBps(kib) { return kib.toFixed(1) }
    function formatRxTx(rx, tx) {
        try {
            if (!isFinite(rx)) rx = 0; if (!isFinite(tx)) tx = 0;
            if (rx === 0 && tx === 0) return "0";
            return `${fmtKiBps(rx)}/${fmtKiBps(tx)}K`;
        } catch (e) { return "0"; }
    }
    Connections {
        target: Services.Connectivity
        function onRxKiBpsChanged() { root.displayText = formatRxTx(Services.Connectivity.rxKiBps, Services.Connectivity.txKiBps) }
        function onTxKiBpsChanged() { root.displayText = formatRxTx(Services.Connectivity.rxKiBps, Services.Connectivity.txKiBps) }
    }
    Component.onCompleted: { displayText = formatRxTx(Services.Connectivity.rxKiBps, Services.Connectivity.txKiBps) }

    function currentIconColor() {
        if (!root.hasLink) return (Settings.settings.networkNoLinkColor || Theme.error)
        if (!root.hasInternet) return (Settings.settings.networkNoInternetColor || Theme.warning)
        return root.iconColor
    }
}
