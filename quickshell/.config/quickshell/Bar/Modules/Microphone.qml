import QtQuick
import QtQuick.Layouts
import qs.Settings
import qs.Components
import qs.Bar.Modules
import qs.Services as Services
import "../../Helpers/Utils.js" as Utils

AudioLevelCapsule {
    id: micDisplay
    settingsKey: "microphone"
    iconOff: "mic_off"
    iconLow: "mic_none"
    iconHigh: "mic"

    StyledTooltip {
        id: micTooltip
        text: "Microphone: " + micDisplay.level + "%\nLeft click to toggle mute.\nScroll up/down to change level."
        positionAbove: false
        tooltipVisible: micDisplay.containsMouse
        targetItem: micDisplay.pill
        delay: Theme.tooltipDelayMs
    }

    onWheelStep: direction => {
        let step = Services.Audio.step || 5;
        Services.Audio.changeMicVolume(direction > 0 ? step : -step);
    }

    onClicked: Services.Audio.toggleMicMute()

    Connections {
        target: Services.Audio
        function onMicVolumeChanged() {
            if (Services.Audio.micVolume === undefined) return;
            micDisplay.updateFrom(Utils.clamp(Services.Audio.micVolume, 0, 100), Services.Audio.micMuted);
        }
        function onMicMutedChanged() {
            micDisplay.updateFrom(micDisplay.level, Services.Audio.micMuted);
        }
    }

    Component.onCompleted: {
        if (Services.Audio && Services.Audio.micVolume !== undefined) {
            micDisplay.updateFrom(Utils.clamp(Services.Audio.micVolume, 0, 100), Services.Audio.micMuted || false);
        }
    }
}
