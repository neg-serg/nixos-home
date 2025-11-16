import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root
    default property alias contentComponent: contentLoader.sourceComponent
    property alias contentItem: contentLoader.item

    Loader {
        id: contentLoader
        anchors.fill: parent
    }
}
