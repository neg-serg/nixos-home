import QtQuick
import qs.Settings
import qs.Components

AudioEndpointCapsule {
    id: volumeDisplay
    settingsKey: "volume"
    iconOff: "volume_off"
    iconLow: "volume_down"
    iconHigh: "volume_up"
    labelSuffix: "%"
    levelProperty: "volume"
    mutedProperty: "muted"
    changeMethod: "changeVolume"
    toggleOnClick: false

    // Stub ioSelector to avoid reference errors if advanced UI isn't present
    Item {
        id: ioSelector
        visible: false
        function show() { visible = true }
        function dismiss() { visible = false }
    }

    StyledTooltip {
        id: volumeTooltip
        text: "Volume: " + volumeDisplay.level + "%\nLeft click for advanced settings.\nScroll up/down to change volume."
        positionAbove: false
        tooltipVisible: !ioSelector.visible && volumeDisplay.containsMouse
        targetItem: volumeDisplay.pill
        delay: Theme.tooltipDelayMs
    }

    onClicked: {
        if (ioSelector.visible) {
            ioSelector.dismiss();
        } else {
            ioSelector.show();
        }
    }

}
