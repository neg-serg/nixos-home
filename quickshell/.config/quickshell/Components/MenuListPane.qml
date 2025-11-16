import QtQuick
import QtQuick.Controls
import QtQml.Models
import Quickshell
import qs.Components
import qs.Settings

Item {
    id: root
    required property var opener
    required property Component submenuHostComponent
    required property PopupWindow menuWindow

    anchors.fill: parent

    function unwrapMenuValues() {
        try {
            const ch = root.opener && root.opener.children ? root.opener.children : null;
            if (!ch) return [];
            const v = ch.values;
            if (typeof v === 'function') return [...v.call(ch)];
            if (v && v.length !== undefined) return v;
            if (ch && ch.length !== undefined) return ch;
            return [];
        } catch (_) { return []; }
    }

    property var menuValues: unwrapMenuValues()

    Connections {
        target: root.menuWindow
        ignoreUnknownSignals: true
        function onMenuChanged() { menuValues = unwrapMenuValues() }
    }

    ListView {
        id: listView
        anchors.fill: parent
        anchors.margins: Theme.panelMenuPadding
        spacing: Theme.panelMenuItemSpacing
        interactive: false
        enabled: root.menuWindow.visible
        clip: true

        model: ScriptModel {
            id: scriptModel
            values: root.menuValues
        }

        delegate: Item {
            required property var modelData
            width: listView.width
            height: entryItem.height
            DelegateEntry {
                id: entryItem
                entryData: parent.modelData
                listViewRef: listView
                submenuHostComponent: root.submenuHostComponent
                menuWindow: root.menuWindow
            }
        }
    }
}
