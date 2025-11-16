import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 1.15
import Quickshell
import qs.Components
import qs.Settings

PopupWindow {
    id: menuWindow
    required property var menuHandle
    required property Component submenuHostComponent
    property alias listView: listView
    property alias openerItem: opener
    property var anchorItem: null
    property real anchorX: 0
    property real anchorY: 0
    property real anchorYOffsetFactor: Theme.panelMenuAnchorYOffset
    property bool focusOnShow: false
    property real menuPadding: Theme.panelMenuPadding
    property real menuItemSpacing: Theme.panelMenuItemSpacing

    color: "transparent"

    anchor.item: anchorItem ? anchorItem : null
    anchor.rect.x: anchorX
    anchor.rect.y: anchorY - Math.round(anchorYOffsetFactor * Theme.scale(Screen))

    function showAt(item, x, y) {
        if (!item)
            return;
        anchorItem = item;
        anchorX = x;
        anchorY = y;
        visible = true;
        if (focusOnShow)
            forceActiveFocus();
        Qt.callLater(() => menuWindow.anchor.updateAnchor());
    }

    function hideMenu() { visible = false }
    function containsMouse() { return menuWindow.containsMouse }

    Item { anchors.fill: parent; Keys.onEscapePressed: menuWindow.hideMenu() }

    QsMenuOpener { id: opener; menu: menuWindow.menuHandle }

    Rectangle {
        anchors.fill: parent
        color: Theme.background
        border.color: Theme.borderSubtle
        border.width: Theme.uiBorderWidth
        radius: Theme.panelMenuRadius
        z: 0
    }

    ListView {
        id: listView
        anchors.fill: parent
        anchors.margins: menuWindow.menuPadding
        spacing: menuWindow.menuItemSpacing
        interactive: false
        enabled: menuWindow.visible
        clip: true
        readonly property color _hoverColor: Theme.surfaceHover

        model: ScriptModel {
            id: menuModel
            values: menuWindow.__menuValues()
        }

        delegate: Item {
            required property var modelData
            width: listView.width
            height: entryItem.height
            DelegateEntry {
                id: entryItem
                entryData: parent.modelData
                listViewRef: listView
                submenuHostComponent: menuWindow.submenuHostComponent
                menuWindow: menuWindow
            }
        }
    }

    function __menuValues() {
        try {
            const ch = opener && opener.children ? opener.children : null;
            if (!ch) return [];
            const v = ch.values;
            if (typeof v === 'function') return [...v.call(ch)];
            if (v && v.length !== undefined) return v;
            if (ch && ch.length !== undefined) return ch;
            return [];
        } catch (_) { return []; }
    }
}
