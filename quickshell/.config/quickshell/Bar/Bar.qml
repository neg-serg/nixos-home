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
                    implicitHeight: reservePanel.barHeightPx
                    exclusionMode: ExclusionMode.Normal
                    exclusiveZone: barHeightPx
                    property real s: Theme.scale(reservePanel.screen)
                    property int barHeightPx: Math.round(Theme.panelHeight * s)
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
                    property int sepOvershoot: Theme.panelSepOvershoot
                    property color barBgColor: Theme.background

                    component DiagSep: ThemedSeparator {
                        kind: "diagonal"
                        Layout.preferredHeight: leftBarBackground.height + leftPanel.sepOvershoot
                        height: Layout.preferredHeight
                    }

                    Rectangle {
                        id: leftBarBackground
                        width: Math.max(1, Math.round(leftPanel.sideMargin + (leftWidgetsRow.implicitWidth || 0)))
                        height: leftPanel.barHeightPx
                        color: leftPanel.barBgColor
                        anchors.top: parent.top
                        anchors.left: parent.left
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
                            Layout.preferredHeight: leftBarBackground.height + leftPanel.sepOvershoot
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
                    property int sepOvershoot: Theme.panelSepOvershoot
                    property color barBgColor: Theme.background

                    component RightDiagSep: ThemedSeparator {
                        kind: "diagonal"
                        Layout.preferredHeight: rightBarBackground.height + rightPanel.sepOvershoot
                        height: Layout.preferredHeight
                    }

                    Rectangle {
                        id: rightBarBackground
                        width: Math.max(1, Math.round(rightPanel.sideMargin + (rightWidgetsRow.implicitWidth || 0)))
                        height: rightPanel.barHeightPx
                        color: rightPanel.barBgColor
                        anchors.top: parent.top
                        anchors.right: parent.right
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
            }
        }
    }
}
