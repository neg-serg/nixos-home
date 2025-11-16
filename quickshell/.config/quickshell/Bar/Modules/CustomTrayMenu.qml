pragma ComponentBehavior: Bound
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Quickshell
import qs.Settings
import qs.Components
import "../../Components" as LocalComponents
import "../../Helpers/Utils.js" as Utils

    LocalComponents.MenuWindow {
        id: trayMenu
        implicitWidth: Theme.panelMenuWidth
        implicitHeight: Utils.clamp(listView.contentHeight + Theme.panelMenuHeightExtra, 40, listView.contentHeight + Theme.panelMenuHeightExtra)
        focusOnShow: true
        menuHandle: trayMenu.menu
        submenuHostComponent: submenuHostComp

        property QsMenuHandle menu

        // Submenu host component passed into delegates
        Component { id: submenuHostComp; SubmenuHost { submenuHostComponent: submenuHostComp } }

        // Recursively destroy all open submenus in delegate tree
        function destroySubmenusRecursively(item) {
            if (!item || !item.contentItem) return;
            var children = item.contentItem.children;
            for (var i = 0; i < children.length; ++i) {
                var child = children[i];
                if (child.subMenu) {
                    child.subMenu.hideMenu();
                    child.subMenu.destroy();
                    child.subMenu = null;
                }
                if (child.contentItem) {
                    destroySubmenusRecursively(child);
                }
            }
        }

        function hideMenu() {
            visible = false;
            destroySubmenusRecursively(listView);
        }

        Component.onDestruction: destroySubmenusRecursively(listView)
    }
