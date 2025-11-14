import QtQuick
import qs.Settings
import qs.Components

AudioEndpointCapsule {
    id: micDisplay
    settingsKey: "microphone"
    iconOff: "mic_off"
    iconLow: "mic_none"
    iconHigh: "mic"
    levelProperty: "micVolume"
    mutedProperty: "micMuted"
    changeMethod: "changeMicVolume"
    toggleMethod: "toggleMicMute"
    toggleOnClick: true

    PanelTooltip {
        id: micTooltip
        text: "Microphone: " + micDisplay.level + "%\nLeft click to toggle mute.\nScroll up/down to change level."
        targetItem: micDisplay.pill
        visibleWhen: micDisplay.containsMouse
    }
}
