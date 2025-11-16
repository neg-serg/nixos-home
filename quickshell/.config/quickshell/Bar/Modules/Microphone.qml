import QtQuick
import qs.Settings
import qs.Components
import "." as LocalMods

LocalMods.AudioEndpointTile {
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
    tooltipTitle: "Microphone"
    tooltipHint: "Left click to toggle mute.\nScroll up/down to change level."
}
