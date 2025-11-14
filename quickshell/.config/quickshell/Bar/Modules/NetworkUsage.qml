import QtQuick
import qs.Settings
import qs.Components
ConnectivityCapsule {
    id: root
    property var screen:null
    property color textColor:Theme.textPrimary
    property string deviceMatch: ""
    readonly property bool hasLink: ConnectivityState.hasLink
    readonly property bool hasInternet: ConnectivityState.hasInternet
    backgroundKey: "network"
    labelText: ConnectivityState.throughputText
    labelColor: textColor
    iconVisible: false
    iconSpacing: 0
}
