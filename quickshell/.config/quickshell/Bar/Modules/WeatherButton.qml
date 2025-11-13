
import QtQuick
import qs.Components
import Quickshell.Wayland
import qs.Settings
import qs.Widgets.SidePanel
import qs.Services as Services

OverlayToggleCapsule {
    id: root
    readonly property real capsuleScale: capsule.capsuleScale
    readonly property int iconBox: capsule.capsuleInner
    capsule.backgroundKey: "weather"
    capsule.centerContent: true
    capsule.cursorShape: Qt.PointingHandCursor
    capsuleVisible: true
    autoToggleOnTap: false
    overlayNamespace: "sideleft-weather"
    onOpened: { try { Services.Weather.start(); } catch (e) {} }
    onDismissed: { try { Services.Weather.stop(); } catch (e) {} }

    IconButton {
        id: weatherBtn
        anchors.centerIn: parent
        size: iconBox
        icon: "partly_cloudy_day"
        cornerRadius: Theme.cornerRadiusSmall
        accentColor: Theme.accentPrimary
        iconNormalColor: Theme.textPrimary
        iconHoverColor: Theme.onAccent
        onClicked: root.toggle("weather")
        hoverEnabled: true
        onEntered: {
            try { weather.startWeatherFetch(); } catch (e) {}
        }
    }

    overlayChildren: [
        Rectangle {
            id: popup
            radius: Math.round(Theme.panelOverlayRadius * capsuleScale)
            color: Theme.overlayWeak
            border.color: Theme.borderSubtle
            border.width: Theme.uiBorderWidth
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.topMargin: Math.round(Theme.sidePanelSpacingMedium * capsuleScale)
            anchors.leftMargin: Math.round(Theme.panelSideMargin * capsuleScale)

            Weather {
                id: weather
                width: Math.round(Theme.sidePanelWeatherWidth * capsuleScale)
                height: Math.round(Theme.sidePanelWeatherHeight * capsuleScale)
            }
        }
    ]

    StyledTooltip {
        id: weatherTip
        targetItem: weatherBtn
        positionAbove: false
        delay: Theme.tooltipDelayMs
        tooltipVisible: weatherBtn.hovering
        text: root.tooltipText()
    }

    function tooltipText() {
        try {
            const city = Settings.settings.weatherCity || "";
            const data = Services.Weather.weatherData;
            if (data && data.current_weather && typeof data.current_weather.temperature === 'number') {
                const c = Math.round(data.current_weather.temperature);
                const useF = Settings.settings.useFahrenheit || false;
                const t = useF ? Math.round(c * 9/5 + 32) + "°F" : c + "°C";
                return (city ? (city + ": ") : "") + t;
            }
            return city ? ("Погода: " + city) : "Погода";
        } catch (e) {
            return "Погода";
        }
    }

    Connections { target: Services.Weather; function onWeatherDataChanged() { weatherTip.text = root.tooltipText(); } }
}
