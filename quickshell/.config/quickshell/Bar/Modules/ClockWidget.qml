import QtQuick
import qs.Settings
import qs.Components
import "../../Helpers/WidgetBg.js" as WidgetBg
import "../../Helpers/Color.js" as Color

Rectangle {
    id: clockWidget
    property var screen: (typeof modelData !== 'undefined' ? modelData : null)
    readonly property real _scale: Theme.scale(screen)
    property int horizontalPadding: Math.max(4, Math.round(Theme.panelRowSpacingSmall * _scale * 0.9))
    property int verticalPadding: Math.max(2, Math.round(Theme.uiSpacingXSmall * _scale))
    width: textItem.paintedWidth + 2 * horizontalPadding
    height: textItem.paintedHeight + 2 * verticalPadding
    implicitWidth: width
    implicitHeight: height
    color: WidgetBg.color(Settings.settings, "clock", "rgba(10, 12, 20, 0.2)")
    radius: Math.round(Theme.cornerRadiusSmall * _scale)
    border.width: Theme.uiBorderWidth
    border.color: Color.withAlpha(Theme.textPrimary, 0.08)
    antialiasing: true

    Text {
        id: textItem
        text: Time.time
        font.family: Theme.fontFamily
        font.weight: Theme.timeFontWeight
        font.pixelSize: Math.round(Theme.fontSizeSmall * Theme.timeFontScale * Theme.scale(screen))
        color: Theme.timeTextColor
        anchors.centerIn: parent
    }

    MouseArea {
        id: clockMouseArea
        anchors.fill: parent
        hoverEnabled: false
        cursorShape: Qt.PointingHandCursor
        onClicked: function() {
            calendar.visible = !calendar.visible
        }
    }

    Calendar {
        id: calendar
        screen: clockWidget.screen
        visible: false
    }
    
}
