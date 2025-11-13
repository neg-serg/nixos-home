
import QtQuick
import qs.Components
import Quickshell.Wayland
import qs.Settings
import qs.Widgets.SidePanel
import qs.Services as Services

Item {
    id: root
    property bool expanded: false
    CapsuleContext { id: capsuleCtx }
    readonly property real _scale: capsuleCtx.scale
    readonly property var capsuleMetrics: capsuleCtx.metrics
    property int padding: capsuleMetrics.padding
    readonly property int iconBox: capsuleMetrics.inner
    readonly property alias capsule: capsule

    width: capsuleMetrics.height
    height: capsuleMetrics.height
    implicitWidth: width
    implicitHeight: height

    WidgetCapsule {
        id: capsule
        anchors.fill: parent
        backgroundKey: "weather"
        paddingScale: capsuleMetrics.padding > 0 ? padding / capsuleMetrics.padding : 1
        verticalPaddingScale: paddingScale
        centerContent: true
        cursorShape: Qt.PointingHandCursor
        contentYOffset: 0
    }

    IconButton {
        id: weatherBtn
        anchors.centerIn: capsule
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
            radius: Math.round(Theme.panelOverlayRadius * _scale)
            color: Theme.overlayWeak
            border.color: Theme.borderSubtle
            border.width: Theme.uiBorderWidth
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.topMargin: Math.round(Theme.sidePanelSpacingMedium * _scale)
            anchors.leftMargin: Math.round(Theme.panelSideMargin * _scale)

            Weather {
                id: weather
                width: Math.round(Theme.sidePanelWeatherWidth * _scale)
                height: Math.round(Theme.sidePanelWeatherHeight * _scale)
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
