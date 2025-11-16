import QtQuick
import qs.Components

AudioEndpointCapsule {
    id: root

    property string tooltipTitle: ""
    property string tooltipHint: ""
    property bool enableAdvancedToggle: false
    property Item advancedSelector: defaultSelector

    readonly property string _tooltipText: (
        (tooltipTitle && tooltipTitle.length ? tooltipTitle + ": " : "") +
        (root.level !== undefined && root.level !== null ? root.level : 0) + "%" +
        (tooltipHint && tooltipHint.length ? "\n" + tooltipHint : "")
    )

    Item {
        id: defaultSelector
        visible: false
        function show() { visible = true }
        function dismiss() { visible = false }
    }

    PanelTooltip {
        id: tooltip
        text: root._tooltipText
        targetItem: root.pill
        visibleWhen: root.containsMouse && !(root.enableAdvancedToggle && root.advancedSelector && root.advancedSelector.visible)
    }

    onClicked: {
        if (!root.enableAdvancedToggle) return;
        if (!root.advancedSelector) return;
        root.advancedSelector.visible = !root.advancedSelector.visible;
    }
}
