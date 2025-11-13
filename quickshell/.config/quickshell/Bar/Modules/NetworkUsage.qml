import QtQuick
import qs.Settings
import "../../Helpers/Utils.js" as Utils
import qs.Components
import qs.Services as Services
import "../../Helpers/CapsuleMetrics.js" as Capsule

WidgetCapsule {
    id: root
    property var screen:null
    readonly property real _scale: Theme.scale(Screen)
    readonly property var capsuleMetrics: Capsule.metrics(Theme, _scale)
    property int fontPixelSize:Math.round(Theme.fontSizeSmall * _scale)
    readonly property int capsulePadding: capsuleMetrics.padding
    property int desiredHeight: capsuleMetrics.inner
    property color textColor:Theme.textPrimary
    property string deviceMatch: ""
    property string displayText: "0"
    property bool hasLink:Services.Connectivity.hasLink
    property bool hasInternet:Services.Connectivity.hasInternet
    backgroundKey: "network"
    property int textPadding:Theme.panelRowSpacingSmall
    readonly property int desiredHorizontalPadding: Math.max(4, Math.round(Theme.panelRowSpacingSmall * _scale))
    paddingScale: capsuleMetrics.padding > 0
        ? desiredHorizontalPadding / capsuleMetrics.padding
        : 1

    readonly property int computedFontPx: fontPixelSize > 0
        ? fontPixelSize
        : Utils.computedInlineFontPx(desiredHeight, textPadding, Theme.panelComputedFontScale)

    SmallInlineStat {
        id: inlineView
        desiredHeight: Math.max(1, capsuleMetrics.inner)
        fontPixelSize: root.fontPixelSize
        textPadding: root.textPadding
        iconSpacing: 0
        labelIsRichText: false
        labelText: displayText
        labelColor: textColor
        labelFontFamily: Theme.fontFamily
        centerContent: true
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

    // Text color stays constant; link state is expressed via the dedicated icon.
}
