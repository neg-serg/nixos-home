import QtQuick
import QtQuick.Layouts
import qs.Settings
import qs.Components
import qs.Bar.Modules
import qs.Services as Services
import "../../Helpers/Utils.js" as Utils
import "../../Helpers/WidgetBg.js" as WidgetBg
import "../../Helpers/Color.js" as Color

Item {
    id: micDisplay
    property int volume: 0
    property bool firstChange: true
    property string lastVolIconCategory: 'up'
    visible: false
    property color pillBgColor: WidgetBg.color(Settings.settings, "microphone", Theme.panelPillBackground)
    readonly property real _scale: Theme.scale(Screen)
    property int horizontalPadding: Math.max(4, Math.round(Theme.panelRowSpacingSmall * _scale * 0.8))
    property int verticalPadding: Math.max(2, Math.round(Theme.uiSpacingXSmall * _scale))

    // Reuse volume gradient for microphone level visualization
    property color volLowColor: Theme.panelVolumeLowColor
    property color volHighColor: Theme.panelVolumeHighColor

    readonly property int contentWidth: pillIndicator.width
    readonly property int contentHeight: pillIndicator.height
    width: visible ? (contentWidth + horizontalPadding * 2) : 0
    height: visible ? (contentHeight + verticalPadding * 2) : 0
    implicitWidth: width
    implicitHeight: height
    Layout.preferredWidth: implicitWidth
    Layout.preferredHeight: implicitHeight
    Layout.minimumWidth: implicitWidth
    Layout.minimumHeight: implicitHeight
    Layout.maximumWidth: implicitWidth
    Layout.maximumHeight: implicitHeight

    Rectangle {
        anchors.fill: parent
        radius: Theme.cornerRadiusSmall
        color: pillBgColor
        border.width: Theme.uiBorderWidth
        border.color: Color.withAlpha(Theme.textPrimary, 0.08)
        visible: micDisplay.visible
        antialiasing: true
    }

    Timer {
        id: fullHideTimer
        interval: Theme.panelVolumeFullHideMs
        repeat: false
        onTriggered: {
            if (micDisplay.volume === 100) {
                micDisplay.visible = false;
            }
        }
    }

    function getVolumeColor() {
        var t = Utils.clamp(volume / 100.0, 0, 1);
        return Qt.rgba(
            volLowColor.r + (volHighColor.r - volLowColor.r) * t,
            volLowColor.g + (volHighColor.g - volLowColor.g) * t,
            volLowColor.b + (volHighColor.b - volLowColor.b) * t,
            1
        );
    }

    function getIconColor() { return getVolumeColor(); }

    function resolveIconCategory(vol, muted) {
        if (muted) return 'off';
        if (vol <= Theme.volumeIconOffThreshold) return 'off';
        if (vol < Theme.volumeIconDownThreshold) return 'down';
        if (vol >= Theme.volumeIconUpThreshold) return 'up';
        return lastVolIconCategory === 'down' ? 'down' : 'up';
    }

    function iconNameForCategory(cat) {
        switch (cat) {
        case 'off': return 'mic_off';
        case 'down': return 'mic_none';
        case 'up': default: return 'mic';
        }
    }

    PillIndicator {
        id: pillIndicator
        icon: iconNameForCategory(resolveIconCategory(volume, Services.Audio.micMuted))
        text: volume + "%"

        anchors.centerIn: parent
        pillColor: pillBgColor
        iconCircleColor: getVolumeColor()
        iconTextColor: Theme.background
        textColor: Theme.textPrimary
        collapsedIconColor: getIconColor()
        autoHide: true

        autoHidePauseMs: Theme.volumePillAutoHidePauseMs
        showDelayMs: Theme.volumePillShowDelayMs

        StyledTooltip {
            id: micTooltip
            text: "Microphone: " + volume + "%\nLeft click to toggle mute.\nScroll up/down to change level."
            positionAbove: false
            tooltipVisible: micDisplay.containsMouse
            targetItem: pillIndicator
            delay: Theme.tooltipDelayMs
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                Services.Audio.toggleMicMute()
            }
        }
    }

    Connections {
        target: Services.Audio
        function onMicVolumeChanged() {
            const clampedVolume = Utils.clamp(Services.Audio.micVolume, 0, 100);
            if (clampedVolume === volume) return;

            volume = clampedVolume;

            pillIndicator.text = volume + "%";
            const cat = resolveIconCategory(volume, Services.Audio.micMuted);
            if (cat !== 'off') lastVolIconCategory = cat;
            pillIndicator.icon = iconNameForCategory(cat);

            const atHundred = (volume === 100);

            if (firstChange) {
                firstChange = false;
                if (!atHundred) {
                    if (!micDisplay.visible) micDisplay.visible = true;
                    pillIndicator.show();
                }
            } else {
                if (!micDisplay.visible) micDisplay.visible = true;
                pillIndicator.show();
            }

            if (atHundred) {
                fullHideTimer.restart();
            } else if (fullHideTimer.running) {
                fullHideTimer.stop();
            }
        }

        function onMicMutedChanged() {
            const cat = resolveIconCategory(volume, Services.Audio.micMuted);
            if (cat !== 'off') lastVolIconCategory = cat;
            pillIndicator.icon = iconNameForCategory(cat);
        }
    }

    Component.onCompleted: {
        if (Services.Audio && Services.Audio.micVolume !== undefined) {
            volume = Utils.clamp(Services.Audio.micVolume, 0, 100);
            const cat = resolveIconCategory(volume, Services.Audio.micMuted || false);
            if (cat !== 'off') lastVolIconCategory = cat;
            pillIndicator.icon = iconNameForCategory(cat);
            if (volume === 100) fullHideTimer.restart();
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        propagateComposedEvents: true
        onEntered: {
            micDisplay.containsMouse = true
            pillIndicator.autoHide = false;
            pillIndicator.showDelayed()
        }
        onExited: {
            micDisplay.containsMouse = false
            pillIndicator.autoHide = true;
            pillIndicator.hide()
        }
        cursorShape: Qt.PointingHandCursor
        onWheel: (wheel) => {
            let step = Services.Audio.step || 5;
            if (wheel.angleDelta.y > 0) {
                Services.Audio.changeMicVolume(step);
            } else if (wheel.angleDelta.y < 0) {
                Services.Audio.changeMicVolume(-step);
            }
        }
    }
    property bool containsMouse: false
}
