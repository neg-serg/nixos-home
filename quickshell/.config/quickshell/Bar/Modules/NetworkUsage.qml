import QtQuick
import qs.Settings
import qs.Components
import qs.Services as Services
import "../../Helpers/ConnectivityUi.js" as ConnUi

CenteredCapsuleRow {
    id: root
    property var screen:null
    property int labelPixelSize: Math.round(Theme.fontSizeSmall * capsuleScale)
    property color textColor:Theme.textPrimary
    property string deviceMatch: ""
    property string displayText: "0"
    property bool hasLink:Services.Connectivity.hasLink
    property bool hasInternet:Services.Connectivity.hasInternet
    backgroundKey: "network"
    desiredInnerHeight: capsuleInner
    fontPixelSize: root.labelPixelSize
    property int textPaddingPx:Theme.panelRowSpacingSmall
    readonly property int desiredHorizontalPadding: Math.max(4, Math.round(Theme.panelRowSpacingSmall * capsuleScale))
    paddingScale: paddingScaleFor(desiredHorizontalPadding)
    labelText: displayText
    labelColor: textColor
    iconVisible: false
    textPadding: root.textPaddingPx
    iconSpacing: 0

    Connections {
        target: Services.Connectivity
        function onRxKiBpsChanged() { root.displayText = ConnUi.formatThroughput(Services.Connectivity.rxKiBps, Services.Connectivity.txKiBps) }
        function onTxKiBpsChanged() { root.displayText = ConnUi.formatThroughput(Services.Connectivity.rxKiBps, Services.Connectivity.txKiBps) }
    }
    Component.onCompleted: { displayText = ConnUi.formatThroughput(Services.Connectivity.rxKiBps, Services.Connectivity.txKiBps) }

    // Text color stays constant; link state is expressed via the dedicated icon.
}
