import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.Bar.Modules
import qs.Components
import "Modules" as LocalMods
import qs.Services
import qs.Settings
import qs.Widgets.SidePanel
import "../Helpers/Color.js" as Color

Scope {
    id: rootScope
    property var shell
    property alias visible: barRootItem.visible
    property real barHeight: 0 // Expose current bar height for other components (e.g. window mirroring)

    Item {
        id: barRootItem
        anchors.fill: parent

        Variants {
            model: Quickshell.screens

            Item {
                property var modelData // 'modelData' comes from Variants
                readonly property bool monitorEnabled: (Settings.settings.barMonitors.includes(modelData.name)
                                                        || (Settings.settings.barMonitors.length === 0))

                PanelWindow {
                    id: reservePanel
                    screen: modelData
                    color: "transparent"
                    WlrLayershell.layer: WlrLayer.Bottom
                    WlrLayershell.namespace: "quickshell-bar-reserve"
                    anchors.bottom: true
                    anchors.left: true
                    anchors.right: true
                    visible: monitorEnabled
                    implicitHeight: reserveBackground.height
                    exclusionMode: ExclusionMode.Normal
                    exclusiveZone: barHeightPx
                    property real s: Theme.scale(reservePanel.screen)
                    property int barHeightPx: Math.round(Theme.panelHeight * s)

                    Rectangle {
                        id: reserveBackground
                        width: parent.width
                        height: reservePanel.barHeightPx
                        color: "transparent"
                    }
                }

                PanelWindow {
                    id: leftPanel
                    screen: modelData
                    color: "transparent"
                    property bool panelHovering: false
                    WlrLayershell.namespace: "quickshell-bar-left"
                    anchors.bottom: true
                    anchors.left: true
                    anchors.right: false
                    implicitWidth: leftPanel.screen ? Math.round(leftPanel.screen.width / 2) : 960
                    visible: monitorEnabled
                    implicitHeight: leftBarBackground.height
                    exclusionMode: ExclusionMode.Ignore
                    exclusiveZone: 0
                    property real s: Theme.scale(leftPanel.screen)
                    property int barHeightPx: Math.round(Theme.panelHeight * s)
                    property int sideMargin: Math.round(Theme.panelSideMargin * s)
                    property int widgetSpacing: Math.round(Theme.panelWidgetSpacing * s)
                    property int seamWidth: Math.max(8, Math.round(Theme.uiDiagonalSeparatorImplicitWidth * s))
                    property color barBgColor: Theme.background
                    property real seamTaperTop: 0.25
                    property real seamTaperBottom: 0.9
                    property real seamOpacity: Math.min(1.0, Math.max(0.35, Theme.uiSeparatorOpacity * 3))
                    property color seamFillColor: Color.withAlpha(
                        Color.mix(Theme.surfaceVariant, Theme.background, 0.45),
                        seamOpacity
                    )
                    readonly property real seamSlackWidth: Math.max(0, leftBarBackground.width - leftBarFill.width)

                    readonly property real contentWidth: Math.max(
                        leftWidgetsRow.width,
                        leftWidgetsRow.implicitWidth || leftWidgetsRow.width || 0
                    ) + leftPanel.widgetSpacing

                    component DiagSep: ThemedSeparator {
                        kind: "diagonal"
                        Layout.preferredHeight: leftBarBackground.height
                        height: Layout.preferredHeight
                    }

                    Rectangle {
                        id: leftBarBackground
                        width: Math.max(1, leftPanel.width)
                        height: leftPanel.barHeightPx
                        color: "transparent"
                        anchors.top: parent.top
                        anchors.left: parent.left
                    }
                    Rectangle {
                        id: leftBarFill
                        width: Math.min(leftBarBackground.width, Math.round(leftPanel.sideMargin + leftPanel.contentWidth))
                        height: leftBarBackground.height
                        color: leftPanel.barBgColor
                        anchors.top: leftBarBackground.top
                        anchors.left: leftBarBackground.left
                    }
                    Item {
                        id: leftSeamFill
                        width: Math.min(leftBarBackground.width, leftPanel.seamWidth)
                        height: leftBarBackground.height
                        anchors.bottom: leftBarBackground.bottom
                        anchors.right: leftBarBackground.right
                        z: 1000
                        ShaderEffect {
                            anchors.fill: parent
                            fragmentShader: Qt.resolvedUrl("../shaders/seam.frag.qsb")
                            property color baseColor: leftPanel.seamFillColor
                            // params0: tilt, taperTop, taperBottom, opacity
                            property vector4d params0: Qt.vector4d(1, leftPanel.seamTaperTop, leftPanel.seamTaperBottom, leftPanel.seamOpacity)
                            blending: true
                        }
                    }

                    Component.onCompleted: rootScope.barHeight = leftBarBackground.height
                    Connections {
                        target: leftBarBackground
                        function onHeightChanged() { rootScope.barHeight = leftBarBackground.height }
                    }

                    RowLayout {
                        id: leftWidgetsRow
                        anchors.verticalCenter: leftBarBackground.verticalCenter
                        anchors.left: leftBarBackground.left
                        anchors.leftMargin: leftPanel.sideMargin
                        spacing: leftPanel.widgetSpacing
                        ClockWidget { Layout.alignment: Qt.AlignVCenter }
                        DiagSep { stripeEnabled: false; Layout.alignment: Qt.AlignVCenter }
                        WsIndicator { id: wsindicator; Layout.alignment: Qt.AlignVCenter }
                        DiagSep { Layout.alignment: Qt.AlignVCenter }
                        KeyboardLayoutHypr { id: kbIndicator; Layout.alignment: Qt.AlignVCenter }
                        DiagSep { Layout.alignment: Qt.AlignVCenter }
                        Row {
                            id: netCluster
                            Layout.alignment: Qt.AlignVCenter
                            spacing: Math.round(Theme.panelNetClusterSpacing * leftPanel.s)
                            LocalMods.VpnAmneziaIndicator {
                                id: amneziaVpn
                                showLabel: false
                                iconRounded: true
                            }
                            NetworkUsage { id: net }
                        }
                        DiagSep {
                            Layout.alignment: Qt.AlignVCenter
                            Layout.preferredHeight: leftBarBackground.height
                            height: Layout.preferredHeight
                            stripeEnabled: false
                            visible: netCluster.visible
                        }
                        DiagSep { visible: Settings.settings.showWeatherInBar === true; Layout.alignment: Qt.AlignVCenter }
                        LocalMods.WeatherButton { visible: Settings.settings.showWeatherInBar === true; Layout.alignment: Qt.AlignVCenter }
                        DiagSep { stripeEnabled: false; visible: Settings.settings.showWeatherInBar === true; Layout.alignment: Qt.AlignVCenter }
                    }
                }

                PanelWindow {
                    id: rightPanel
                    screen: modelData
                    color: "transparent"
                    property bool panelHovering: false
                    WlrLayershell.namespace: "quickshell-bar-right"
                    anchors.bottom: true
                    anchors.right: true
                    anchors.left: false
                    implicitWidth: rightPanel.screen ? Math.round(rightPanel.screen.width / 2) : 960
                    visible: monitorEnabled
                    implicitHeight: rightBarBackground.height
                    exclusionMode: ExclusionMode.Ignore
                    exclusiveZone: 0
                    property real s: Theme.scale(rightPanel.screen)
                    property int barHeightPx: Math.round(Theme.panelHeight * s)
                    property int sideMargin: Math.round(Theme.panelSideMargin * s)
                    property int widgetSpacing: Math.round(Theme.panelWidgetSpacing * s)
                    property int seamWidth: Math.max(8, Math.round(Theme.uiDiagonalSeparatorImplicitWidth * s))
                    property color barBgColor: Theme.background
                    property real seamTaperTop: 0.25
                    property real seamTaperBottom: 0.9
                    property real seamOpacity: Math.min(1.0, Math.max(0.35, Theme.uiSeparatorOpacity * 3))
                    property color seamFillColor: Color.withAlpha(
                        Color.mix(Theme.surfaceVariant, Theme.background, 0.45),
                        seamOpacity
                    )
                    readonly property real seamSlackWidth: Math.max(0, rightBarBackground.width - rightBarFill.width)

                    readonly property real contentWidth: Math.max(
                        rightWidgetsRow.width,
                        rightWidgetsRow.implicitWidth || rightWidgetsRow.width || 0
                    ) + rightPanel.widgetSpacing

                    component RightDiagSep: ThemedSeparator {
                        kind: "diagonal"
                        Layout.preferredHeight: rightBarBackground.height
                        height: Layout.preferredHeight
                    }

                    Rectangle {
                        id: rightBarBackground
                        width: Math.max(1, rightPanel.width)
                        height: rightPanel.barHeightPx
                        color: "transparent"
                        anchors.top: parent.top
                        anchors.right: parent.right
                    }
                    Rectangle {
                        id: rightBarFill
                        width: Math.min(rightBarBackground.width, Math.round(rightPanel.sideMargin + rightPanel.contentWidth))
                        height: rightBarBackground.height
                        color: rightPanel.barBgColor
                        anchors.top: rightBarBackground.top
                        anchors.right: rightBarBackground.right
                    }
                    Item {
                        id: rightSeamFill
                        width: Math.min(rightBarBackground.width, rightPanel.seamWidth)
                        height: rightBarBackground.height
                        anchors.bottom: rightBarBackground.bottom
                        anchors.left: rightBarBackground.left
                        z: 1000
                        ShaderEffect {
                            anchors.fill: parent
                            fragmentShader: Qt.resolvedUrl("../shaders/seam.frag.qsb")
                            property color baseColor: rightPanel.seamFillColor
                            property vector4d params0: Qt.vector4d(-1, rightPanel.seamTaperTop, rightPanel.seamTaperBottom, rightPanel.seamOpacity)
                            blending: true
                        }
                    }

                    RowLayout {
                        id: rightWidgetsRow
                        anchors.verticalCenter: rightBarBackground.verticalCenter
                        anchors.right: rightBarBackground.right
                        anchors.rightMargin: rightPanel.sideMargin
                        spacing: rightPanel.widgetSpacing
                        RightDiagSep {
                            Layout.alignment: Qt.AlignVCenter
                            visible: mediaModule.visible
                        }
                        Media {
                            id: mediaModule
                            Layout.alignment: Qt.AlignVCenter
                            Layout.fillWidth: true
                            sidePanelPopup: sidebarPopup
                        }
                        LocalMods.MpdFlags {
                            id: mpdFlagsBar
                            Layout.alignment: Qt.AlignVCenter
                            property bool _mediaVisible: (
                                Settings.settings.showMediaInBar
                                && MusicManager.currentPlayer
                                && !MusicManager.isStopped
                                && (MusicManager.isPlaying || MusicManager.isPaused || (MusicManager.trackTitle && MusicManager.trackTitle.length > 0))
                            )
                            enabled: _mediaVisible && MusicManager.isCurrentMpdPlayer()
                            iconPx: Math.round(Theme.fontSizeSmall * Theme.scale(rightPanel.screen) * Theme.mpdFlagsIconScale)
                            iconColor: Theme.textPrimary
                        }
                        
                        SystemTray {
                            id: systemTrayModule
                            shell: rootScope.shell
                            screen: modelData
                            Layout.alignment: Qt.AlignVCenter
                            trayMenu: externalTrayMenu
                        }
                        CustomTrayMenu { id: externalTrayMenu }
                        Microphone {
                            id: widgetsMicrophone
                            Layout.alignment: Qt.AlignVCenter
                        }
                        Volume {
                            id: widgetsVolume
                            Layout.alignment: Qt.AlignVCenter
                        }

                    }

                    MusicPopup {
                        id: sidebarPopup
                        anchorWindow: rightPanel
                        panelEdge: "bottom"
                    }

                    property string _lastAlbum: ""
                    function maybeShowOnAlbumChange() {
                        try {
                            if (!rightPanel.visible) return;
                            if (MusicManager.isStopped) return;
                            const album = String(MusicManager.trackAlbum || "");
                            if (!album || album.length === 0) return;
                            if (album !== rightPanel._lastAlbum) {
                                if (MusicManager.trackTitle || MusicManager.trackArtist) sidebarPopup.showAt();
                                rightPanel._lastAlbum = album;
                            }
                        } catch (e) { /* ignore */ }
                    }
                    
                    Connections {
                        target: MusicManager
                        function onTrackAlbumChanged()  { rightPanel.maybeShowOnAlbumChange(); }
                    }

                    MouseArea {
                        id: trayHotZone
                        anchors.right: rightBarBackground.right
                        anchors.bottom: rightBarBackground.bottom
                        width: Math.round(Theme.panelHotzoneWidth * rightPanel.s)
                        height: Math.round(Theme.panelHotzoneHeight * rightPanel.s)
                        anchors.rightMargin: Math.round(width * Theme.panelHotzoneRightShift)
                        anchors.bottomMargin: Theme.uiMarginNone
                        hoverEnabled: true
                        acceptedButtons: Qt.NoButton
                        z: 10001
                        onEntered: {
                            systemTrayModule.hotHover = true
                            systemTrayModule.expanded = true
                        }
                        onExited: {
                            systemTrayModule.hotHover = false
                        }
                        cursorShape: Qt.ArrowCursor
                    }

                    MouseArea {
                        id: barHoverTracker
                        anchors.fill: rightBarBackground
                        hoverEnabled: true
                        acceptedButtons: Qt.NoButton
                        propagateComposedEvents: true
                        z: 10000
                        onEntered: { systemTrayModule.panelHover = true; rightPanel.panelHovering = true }
                        onExited: {
                            systemTrayModule.panelHover = false
                            rightPanel.panelHovering = false
                            const menuOpen = systemTrayModule.trayMenu && systemTrayModule.trayMenu.visible
                            if (!systemTrayModule.hotHover && !systemTrayModule.holdOpen && !systemTrayModule.shortHoldActive && !menuOpen) {
                                systemTrayModule.expanded = false
                            }
                        }
                        visible: true
                        Rectangle { visible: false }
                    }

                }

                PanelWindow {
                    id: seamPanel
                    screen: modelData
                    color: "transparent"
                    anchors.bottom: true
                    anchors.left: true
                    anchors.right: true
                    visible: monitorEnabled && seamPanel.rawGapWidth > 0
                    exclusionMode: ExclusionMode.Ignore
                    exclusiveZone: 0
                    WlrLayershell.namespace: "quickshell-bar-seam"
                    WlrLayershell.layer: WlrLayer.Top
                    property real s: Theme.scale(seamPanel.screen)
                    property int seamHeightPx: Math.round(Theme.panelHeight * s)
                    property real seamTaperTop: 0.12
                    property real seamTaperBottom: 0.65
                    property real seamEffectOpacity: Math.min(1.0, Math.max(0.45, Theme.uiSeparatorOpacity * 7.5))
                    property color seamFillColor: Color.mix(Theme.surfaceVariant, Theme.background, 0.35)

                    readonly property real _leftFillWidth: leftBarFill ? leftBarFill.width : seamPanel.width / 2
                    readonly property real _rightFillWidth: rightBarFill ? rightBarFill.width : seamPanel.width / 2
                    readonly property real gapStart: Math.max(0, Math.min(seamPanel.width, _leftFillWidth))
                    readonly property real gapEnd: Math.max(gapStart, seamPanel.width - Math.min(seamPanel.width, _rightFillWidth))
                    readonly property real rawGapWidth: Math.max(0, gapEnd - gapStart)
                    readonly property real seamWidthPx: Math.min(
                        seamPanel.width,
                        Math.max(Math.round(Theme.uiDiagonalSeparatorImplicitWidth * seamPanel.s * 3), rawGapWidth)
                    )
                    readonly property real seamLeftMargin: Math.max(
                        0,
                        Math.min(
                            seamPanel.width - seamPanel.seamWidthPx,
                            gapStart - Math.max(0, (seamPanel.seamWidthPx - rawGapWidth) / 2)
                        )
                    )

                    Item {
                        width: seamPanel.seamWidthPx
                        height: seamPanel.seamHeightPx
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.leftMargin: seamPanel.seamLeftMargin
                        Row {
                            anchors.fill: parent
                            ShaderEffect {
                                width: parent.width / 2
                                height: parent.height
                                fragmentShader: Qt.resolvedUrl("../shaders/seam.frag.qsb")
                                property color baseColor: seamPanel.seamFillColor
                                property vector4d params0: Qt.vector4d(-1, seamPanel.seamTaperTop, seamPanel.seamTaperBottom, seamPanel.seamEffectOpacity)
                                blending: true
                            }
                            ShaderEffect {
                                width: parent.width / 2
                                height: parent.height
                                fragmentShader: Qt.resolvedUrl("../shaders/seam.frag.qsb")
                                property color baseColor: seamPanel.seamFillColor
                                property vector4d params0: Qt.vector4d(1, seamPanel.seamTaperTop, seamPanel.seamTaperBottom, seamPanel.seamEffectOpacity)
                                blending: true
                            }
                        }
                    }
                }

            }
        }
    }
}
