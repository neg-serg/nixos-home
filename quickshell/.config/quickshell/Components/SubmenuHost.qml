import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 1.15
import Quickshell
import qs.Components
import qs.Settings
import "../Helpers/Utils.js" as Utils
import "." as LocalComponents

LocalComponents.MenuWindow {
    id: subMenu
    required property var menu
    required property Component submenuHostComponent

    menuHandle: menu
    submenuHostComponent: subMenu.submenuHostComponent
    implicitWidth: Theme.panelSubmenuWidth
    implicitHeight: Utils.clamp(listView.contentHeight + Theme.panelMenuHeightExtra, 40, listView.contentHeight + Theme.panelMenuHeightExtra)
}
