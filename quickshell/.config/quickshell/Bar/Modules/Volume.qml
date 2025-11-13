import QtQuick
import QtQuick.Layouts
import qs.Settings
import qs.Components
import qs.Bar.Modules
import qs.Services as Services
import "../../Helpers/Utils.js" as Utils

AudioLevelCapsule {
    id: volumeDisplay
    settingsKey: "volume"
    iconOff: "volume_off"
    iconLow: "volume_down"
    iconHigh: "volume_up"
    labelSuffix: "%"

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

    onWheelStep: direction => {
        let step = Services.Audio.step || 5;
        Services.Audio.changeVolume(direction > 0 ? step : -step);
    }

    onClicked: {
        if (ioSelector.visible) {
            ioSelector.dismiss();
        } else {
            ioSelector.show();
        }
    }

    Connections {
        target: Services.Audio
        function onVolumeChanged() {
            if (Services.Audio.volume === undefined) return;
            volumeDisplay.updateFrom(Utils.clamp(Services.Audio.volume, 0, 100), Services.Audio.muted);
        }
        function onMutedChanged() {
            volumeDisplay.updateFrom(volumeDisplay.level, Services.Audio.muted);
        }
    }

    Component.onCompleted: {
        if (Services.Audio && Services.Audio.volume !== undefined) {
            volumeDisplay.updateFrom(Utils.clamp(Services.Audio.volume, 0, 100), Services.Audio.muted || false);
        }
    }
}
