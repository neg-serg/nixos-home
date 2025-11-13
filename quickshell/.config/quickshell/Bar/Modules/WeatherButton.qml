
import QtQuick
import qs.Components
import Quickshell.Wayland
import qs.Settings
import qs.Widgets.SidePanel
import qs.Services as Services
import "../../Helpers/WidgetBg.js" as WidgetBg
import "../../Helpers/Color.js" as Color
import "../../Helpers/CapsuleMetrics.js" as Capsule

Item {
    id: root
    property bool expanded: false
    property color backgroundColor: WidgetBg.color(Settings.settings, "weather", "rgba(10, 12, 20, 0.2)")
    readonly property real hoverMixAmount: 0.18
    readonly property color hoverColor: Color.mix(backgroundColor, Qt.rgba(1, 1, 1, 1), hoverMixAmount)
    readonly property real _scale: Theme.scale(Screen)
    readonly property var capsuleMetrics: Capsule.metrics(Theme, _scale)
    property int padding: capsuleMetrics.padding
    readonly property int iconBox: capsuleMetrics.inner
    readonly property bool hovered: hoverTracker.hovered || weatherBtn.hovering

    height: capsuleMetrics.height
    width: capsuleMetrics.height
    implicitHeight: height
    implicitWidth: width
    HoverHandler { id: hoverTracker }

    Rectangle {
        anchors.fill: parent
        radius: Theme.cornerRadiusSmall
        color: hovered ? hoverColor : backgroundColor
        border.width: Theme.uiBorderWidth
        border.color: Color.withAlpha(Theme.textPrimary, 0.08)
    }

    IconButton {
        id: weatherBtn
        anchors.centerIn: parent
        size: iconBox
        icon: "partly_cloudy_day"
        cornerRadius: Theme.cornerRadiusSmall
        accentColor: Theme.accentPrimary
        iconNormalColor: Theme.textPrimary
        iconHoverColor: Theme.onAccent
        onClicked: root.toggle()
        hoverEnabled: true
        onEntered: {
            try { weather.startWeatherFetch(); } catch (e) {}
        }
    }

    function toggle() {
        expanded = !expanded;
        if (expanded) {
            weatherOverlay.show();
        } else {
            weatherOverlay.dismiss();
        }
    }

    PanelWithOverlay {
        id: weatherOverlay
        visible: false
        WlrLayershell.namespace: "sideleft-weather"
        onVisibleChanged: { if (visible) { try { Services.Weather.start() } catch (e) {} } else { try { Services.Weather.stop() } catch (e) {} } }
        Rectangle {
            id: popup
            radius: Math.round(Theme.panelOverlayRadius * Theme.scale(Screen))
            color: Theme.overlayWeak
            border.color: Theme.borderSubtle
            border.width: Theme.uiBorderWidth
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.topMargin: Math.round(Theme.sidePanelSpacingMedium * Theme.scale(Screen))
            anchors.leftMargin: Math.round(Theme.panelSideMargin * Theme.scale(Screen))

            Weather {
                id: weather
                width: Math.round(Theme.sidePanelWeatherWidth * Theme.scale(Screen))
                height: Math.round(Theme.sidePanelWeatherHeight * Theme.scale(Screen))
            }
        }
        MouseArea {
            anchors.fill: parent
            z: -1
            onClicked: { root.expanded = false; weatherOverlay.dismiss(); }
        }
    }

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
