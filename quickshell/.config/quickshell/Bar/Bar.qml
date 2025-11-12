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
                    property bool panelTintEnabled: true
                    property color panelTintColor: Color.withAlpha("#ff2a36", 0.75)
                    property real panelTintStrength: 1.0
                    property real panelTintFeatherTop: 0.08
                    property real panelTintFeatherBottom: 0.35
                    // Debug: draw a right triangle above the network indicator cluster
                    // Now controlled by Settings
                    property bool debugNetTriangle: Settings.settings.debugTriangleLeft

                    readonly property real contentWidth: Math.max(
                        leftWidgetsRow.width,
                        leftWidgetsRow.implicitWidth || leftWidgetsRow.width || 0
                    ) + leftPanel.widgetSpacing

                    component DiagSep: ThemedSeparator {
                        kind: "diagonal"
                        Layout.preferredHeight: leftBarBackground.height
                        height: Layout.preferredHeight
                    }

                    Item {
                        id: leftPanelContent
                        anchors.fill: parent

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
                            // Logical anchor position for the custom triangle placed "after network"
                            // This doesn't consume layout width (preferredWidth=0), it's used only to compute x
                            Item {
                                id: netTriangleSlot
                                Layout.alignment: Qt.AlignVCenter
                                Layout.preferredWidth: 0
                                visible: netCluster.visible
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

                        // Legacy debug triangle inside content (disabled)
                        Canvas {
                            id: netTriangle
                            visible: false && leftPanel.debugNetTriangle && netCluster.visible
                            antialiasing: true
                            z: 100000
                            property int sz: Math.max(8, Math.round(Theme.uiRadiusSmall * 1.5 * leftPanel.s))
                            width: sz
                            height: sz
                            // Important: anchor to the top edge so the triangle stays within the panel surface
                            // (when anchored to bottom of top edge it could land outside of the surface and be clipped).
                            anchors.top: leftBarBackground.top
                            anchors.topMargin: Math.round(1 * leftPanel.s)
                            // Center horizontally over netCluster
                            x: Math.round(netCluster.mapToItem(leftPanelContent, netCluster.width / 2, 0).x - width / 2)
                            onVisibleChanged: requestPaint()
                            onXChanged: requestPaint()
                            onWidthChanged: requestPaint()
                            onHeightChanged: requestPaint()
                            onPaint: { /* disabled */ }
                        }
                    }

                    ShaderEffectSource {
                        id: leftPanelSource
                        anchors.fill: parent
                        sourceItem: leftPanelContent
                        hideSource: false
                        live: true
                        recursive: true
                    }

                    ShaderEffect {
                        anchors.fill: parent
                        visible: leftPanel.panelTintEnabled
                        fragmentShader: Qt.resolvedUrl("../shaders/panel_tint_mix.frag.qsb")
                        property var sourceSampler: leftPanelSource
                        property color tintColor: leftPanel.panelTintColor
                        property vector4d params0: Qt.vector4d(
                            leftPanel.panelTintStrength,
                            leftPanel.panelTintFeatherTop,
                            leftPanel.panelTintFeatherBottom,
                            0
                        )
                        blending: true
                    }

                    Item {
                        id: netTriangleAnchor
                        width: 0
                        height: 0
                        anchors.top: parent.top
                        // Compute seam start in local coords: end of left fill minus seam width
                        readonly property int _seamWidth: Math.max(1, leftPanel.seamWidth)
                        readonly property real _fillWidth: leftBarFill ? leftBarFill.width : leftPanelContent.width
                        readonly property real seamStartLocal: Math.max(
                            0,
                            Math.min(leftPanelContent.width - _seamWidth, _fillWidth - _seamWidth)
                        )
                    }

                    // Right-angled (rectangular) triangle overlay, above all panel content and outside tint capture
                    Canvas {
                        id: netTriangleOverlay
                        visible: leftPanel.debugNetTriangle && netCluster.visible
                        antialiasing: true
                        z: 10000000
                        width: Math.max(1, leftPanel.seamWidth)
                        height: leftPanel.barHeightPx
                        anchors.top: parent.top
                        anchors.left: leftPanelContent.left
                        anchors.leftMargin: Math.round(netTriangleAnchor.seamStartLocal)
                        anchors.topMargin: 0
                        // Use theme accent color from Theme; keep fully opaque
                        // If transparency is needed, prefer Canvas.opacity rather than embedding alpha in the color.
                        property color triangleColor: Theme.accentPrimary
                        // Orientation control: slopeUp = bottom-left → top-right; otherwise top-left → bottom-right
                        property bool slopeUp: Settings.settings.debugTriangleLeftSlopeUp
                        // Make triangle translucent in sync with seam
                        opacity: leftPanel.seamOpacity
                        opacity: 1.0
                        onVisibleChanged: requestPaint()
                        onXChanged: requestPaint()
                        onWidthChanged: requestPaint()
                        onHeightChanged: requestPaint()
                        onPaint: {
                            var ctx = getContext('2d');
                            ctx.reset();
                            ctx.clearRect(0, 0, width, height);
                            ctx.fillStyle = triangleColor;
                            // Vertical edge on the right at seam boundary
                            ctx.beginPath();
                            if (slopeUp) {
                                // bottom-left → top-right
                                ctx.moveTo(0, height);
                                ctx.lineTo(width, 0);
                                ctx.lineTo(width, height);
                            } else {
                                // top-left → bottom-right
                                ctx.moveTo(0, 0);
                                ctx.lineTo(width, height);
                                ctx.lineTo(width, 0);
                            }
                            ctx.closePath();
                            ctx.fill();
                        }
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
                    property bool panelTintEnabled: true
                    property color panelTintColor: Color.withAlpha("#ff2a36", 0.75)
                    property real panelTintStrength: 1.0
                    property real panelTintFeatherTop: 0.08
                    property real panelTintFeatherBottom: 0.35

                    readonly property real contentWidth: Math.max(
                        rightWidgetsRow.width,
                        rightWidgetsRow.implicitWidth || rightWidgetsRow.width || 0
                    ) + rightPanel.widgetSpacing

                    component RightDiagSep: ThemedSeparator {
                        kind: "diagonal"
                        Layout.preferredHeight: rightBarBackground.height
                        height: Layout.preferredHeight
                    }

                    Item {
                        id: rightPanelContent
                        anchors.fill: parent

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
                        // Mirrored debug triangle on the right side: aligns to the left edge
                        // of the right panel's seam (i.e., the left edge of rightBarFill).
                        Item {
                            id: rightNetTriangleAnchor
                            width: 0
                            height: 0
                            anchors.top: parent.top
                            readonly property int _seamWidth: Math.max(1, rightPanel.seamWidth)
                            readonly property real _fillWidth: rightBarFill ? rightBarFill.width : rightPanelContent.width
                            // Seam start measured from the left of rightPanelContent
                            readonly property real seamStartLocal: Math.max(
                                0,
                                Math.min(rightPanelContent.width - _seamWidth, rightPanelContent.width - _fillWidth)
                            )
                        }
                        Canvas {
                            id: rightNetTriangleOverlay
                            // Separate control for the right triangle
                            visible: Settings.settings.debugTriangleRight && rightBarFill.visible
                            antialiasing: true
                            z: 10000000
                            width: Math.max(1, rightPanel.seamWidth)
                            height: rightPanel.barHeightPx
                            anchors.top: parent.top
                            anchors.left: rightPanelContent.left
                            anchors.leftMargin: Math.round(rightNetTriangleAnchor.seamStartLocal)
                            anchors.topMargin: 0
                            // Theme accent color
                            property color triangleColor: Theme.accentPrimary
                            // Make triangle translucent in sync with seam
                            opacity: rightPanel.seamOpacity
                            // Orientation control for right side
                            property bool slopeUp: Settings.settings.debugTriangleRightSlopeUp
                            opacity: 1.0
                            onVisibleChanged: requestPaint()
                            onXChanged: requestPaint()
                            onWidthChanged: requestPaint()
                            onHeightChanged: requestPaint()
                            onPaint: {
                                var ctx = getContext('2d');
                                ctx.reset();
                                ctx.clearRect(0, 0, width, height);
                                ctx.fillStyle = triangleColor;
                                ctx.beginPath();
                                if (slopeUp) {
                                    // bottom-left → top-right (current default)
                                    ctx.moveTo(0, height);    // seam boundary
                                    ctx.lineTo(width, 0);
                                    ctx.lineTo(0, 0);
                                } else {
                                    // top-left → bottom-right
                                    ctx.moveTo(0, 0);         // seam boundary
                                    ctx.lineTo(width, height);
                                    ctx.lineTo(0, height);
                                }
                                ctx.closePath();
                                ctx.fill();
                            }
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
                    }

                    ShaderEffectSource {
                        id: rightPanelSource
                        anchors.fill: parent
                        sourceItem: rightPanelContent
                        hideSource: false
                        live: true
                        recursive: true
                    }

                    ShaderEffect {
                        anchors.fill: parent
                        visible: rightPanel.panelTintEnabled
                        fragmentShader: Qt.resolvedUrl("../shaders/panel_tint_mix.frag.qsb")
                        property var sourceSampler: rightPanelSource
                        property color tintColor: rightPanel.panelTintColor
                        property vector4d params0: Qt.vector4d(
                            rightPanel.panelTintStrength,
                            rightPanel.panelTintFeatherTop,
                            rightPanel.panelTintFeatherBottom,
                            0
                        )
                        blending: true
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
                        anchors.right: rightPanelContent.right
                        anchors.bottom: rightPanelContent.bottom
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
                        anchors.fill: rightPanelContent
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
                    // Ensure the seam window has a real height; without this the window
                    // collapses to 0px and shaders never render (stays invisible).
                    implicitHeight: seamPanel.seamHeightPx
                    // Readiness filter: when enabled, only show seam once geometry stabilizes.
                    // Prevents early full-width flash while rows are still measuring.
                    property bool useReadinessFilter: true
                    // Debug switch: force seam visible regardless of readiness to verify rendering/ordering
                    property bool debugForceVisible: true
                    visible: monitorEnabled && (
                        seamPanel.debugForceVisible || (
                            !seamPanel.useReadinessFilter
                            ? (seamPanel.rawGapWidth > 0)
                            : (seamPanel.geometryReady)
                        )
                    )
                    exclusionMode: ExclusionMode.Ignore
                    exclusiveZone: 0
                    WlrLayershell.namespace: "quickshell-bar-seam"
                    // Place seam below panel elements so debug fill shows through the center gap only
                    WlrLayershell.layer: WlrLayer.Bottom
                    property real s: Theme.scale(seamPanel.screen)
                    property int seamHeightPx: Math.round(Theme.panelHeight * s)
                    property real seamTaperTop: 0.12
                    property real seamTaperBottom: 0.65
                    property real seamEffectOpacity: seamPanel.debugForceVisible
                        ? 1.0 : Math.min(1.0, Math.max(0.45, Theme.uiSeparatorOpacity * 7.5))
                    property color seamFillColor: Color.mix(Theme.surfaceVariant, Theme.background, 0.35)
                    property bool seamTintEnabled: true
                    property color seamTintColor: "#ff3a44"
                    property real seamTintOpacity: seamPanel.debugForceVisible ? 1.0 : 0.9
                    property color seamBaseColor: Theme.background
                    property real seamBaseOpacityTop: seamPanel.debugForceVisible ? 1.0 : 0.5
                    property real seamBaseOpacityBottom: seamPanel.debugForceVisible ? 1.0 : 0.65
                    property real seamTintTopInsetPx: Math.round(Theme.panelWidgetSpacing * 0.55 * s)
                    property real seamTintBottomInsetPx: Math.round(Theme.panelWidgetSpacing * 0.2 * s)
                    property real seamTintFeatherPx: Math.max(1, Math.round(Theme.uiRadiusSmall * 0.35 * s))
                    readonly property real monitorWidth: seamPanel.screen ? seamPanel.screen.width : seamPanel.width
                    // Debug: enable to overlay bounding boxes and logs
                    property bool debugSeam: true
                    // Debug: when true, the accent debug overlay fills the entire panel width
                    property bool debugFillFullWidth: Settings.settings.debugSeamFullWidth
                    // Consider geometry "ready" only when left/right fills are measured and gap is sane
                    readonly property bool leftReady: _leftFillWidth > Math.max(8, leftPanel.sideMargin + leftPanel.widgetSpacing)
                    readonly property bool rightReady: _rightFillWidth > Math.max(8, rightPanel.sideMargin + rightPanel.widgetSpacing)
                    readonly property bool gapSane: rawGapWidth < (monitorWidth * 0.98)
                    readonly property bool geometryReady: leftReady && rightReady && gapSane

                    readonly property real _leftFillWidth: leftBarFill ? leftBarFill.width : seamPanel.monitorWidth / 2
                    readonly property real _rightFillWidth: rightBarFill ? rightBarFill.width : seamPanel.monitorWidth / 2
                    readonly property real _leftVisibleEdge: Math.max(
                        0,
                        Math.min(seamPanel.monitorWidth, _leftFillWidth - Math.max(0, leftPanel.seamWidth || 0))
                    )
                    readonly property real _rightFillVisibleWidth: Math.max(0, _rightFillWidth - Math.max(0, rightPanel.seamWidth || 0))
                    readonly property real _rightVisibleEdge: Math.max(
                        _leftVisibleEdge,
                        seamPanel.monitorWidth - Math.min(seamPanel.monitorWidth, _rightFillVisibleWidth)
                    )
                    readonly property real gapStart: _leftVisibleEdge
                    readonly property real gapEnd: _rightVisibleEdge
                    readonly property real rawGapWidth: Math.max(0, gapEnd - gapStart)
                    readonly property real seamWidthPx: Math.min(
                        seamPanel.monitorWidth,
                        Math.max(Math.round(Theme.uiDiagonalSeparatorImplicitWidth * seamPanel.s * 3), rawGapWidth)
                    )
                    readonly property real seamLeftMargin: Math.max(
                        0,
                        Math.min(
                            seamPanel.monitorWidth - seamPanel.seamWidthPx,
                            gapStart - Math.max(0, (seamPanel.seamWidthPx - rawGapWidth) / 2)
                        )
                    )
                    readonly property real seamTintLeftTop: seamPanel._normalizedInset(seamPanel.seamTintTopInsetPx)
                    readonly property real seamTintLeftBottom: seamPanel._normalizedInset(seamPanel.seamTintBottomInsetPx)
                    readonly property real seamTintRightTop: 1 - seamPanel.seamTintLeftTop
                    readonly property real seamTintRightBottom: 1 - seamPanel.seamTintLeftBottom
                    readonly property real seamTintFeatherLeft: seamPanel._normalizedFeather(seamPanel.seamTintFeatherPx)
                    readonly property real seamTintFeatherRight: seamPanel.seamTintFeatherLeft

                    function _normalizedInset(px) {
                        const width = Math.max(1, seamPanel.seamWidthPx);
                        return Math.min(0.49, Math.max(0, px / width));
                    }

                    function _normalizedFeather(px) {
                        const width = Math.max(1, seamPanel.seamWidthPx);
                        return Math.min(0.25, Math.max(0.005, px / width));
                    }

                    Item {
                        // Render shader content only after geometry stabilizes
                        visible: seamPanel.geometryReady
                        width: seamPanel.seamWidthPx + 2
                        height: seamPanel.seamHeightPx
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.leftMargin: Math.max(0, seamPanel.seamLeftMargin - 1)
                        ShaderEffect {
                            z: 0
                            anchors.fill: parent
                            fragmentShader: Qt.resolvedUrl("../shaders/seam_fill.frag.qsb")
                            property color baseColor: seamPanel.seamBaseColor
                            property vector4d params0: Qt.vector4d(
                                seamPanel.seamBaseOpacityTop,
                                seamPanel.seamBaseOpacityBottom,
                                0,
                                0
                            )
                        }
                        ShaderEffect {
                            z: 50
                            visible: seamPanel.seamTintEnabled
                            anchors.fill: parent
                            fragmentShader: Qt.resolvedUrl("../shaders/seam_tint.frag.qsb")
                            property color tintColor: seamPanel.seamTintColor
                            property vector4d params0: Qt.vector4d(
                                seamPanel.seamTintLeftTop,
                                seamPanel.seamTintLeftBottom,
                                seamPanel.seamTintRightTop,
                                seamPanel.seamTintRightBottom
                            )
                            property vector4d params1: Qt.vector4d(
                                seamPanel.seamTintFeatherLeft,
                                seamPanel.seamTintFeatherRight,
                                seamPanel.seamTintOpacity,
                                0
                            )
                            property color baseColor: seamPanel.seamBaseColor
                            blending: true
                        Component.onCompleted: if (Settings.settings.debugLogs) console.log("[seam-panel]", "shader ready", seamPanel.seamWidthPx, seamPanel.seamTintColor)
                        }
                        Row {
                            z: 10
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

                    // Debug overlay: visualize computed regions with solid boxes always visible
                    Item {
                        visible: seamPanel.debugSeam && (!seamPanel.useReadinessFilter || seamPanel.geometryReady)
                        anchors.fill: parent
                        z: 200000

                        // (cyan frame removed)

                        // Raw gap region [gapStart .. gapEnd]
                        Rectangle {
                            x: seamPanel.debugFillFullWidth ? 0 : seamPanel.gapStart
                            width: seamPanel.debugFillFullWidth ? parent.width : Math.max(1, seamPanel.rawGapWidth)
                            height: seamPanel.seamHeightPx
                            anchors.bottom: parent.bottom
                            // Use theme accent for the raw gap overlay instead of hardcoded green
                            color: Color.withAlpha(Theme.accentPrimary, 0.20)
                        }

                        // (red seam box removed)

                        // Readable text with key numbers
                        Rectangle {
                            anchors.left: parent.left
                            anchors.bottom: parent.bottom
                            color: "#a0000000"
                            radius: 4
                            border.color: "#80ffffff"
                            border.width: 1
                            width: debugText.implicitWidth + 12
                            height: debugText.implicitHeight + 8
                            Text {
                                id: debugText
                                anchors.margins: 4
                                anchors.fill: parent
                                color: "#ffff66"
                                font.pixelSize: 12
                                text: "gap=" + Math.round(seamPanel.rawGapWidth)
                                      + " leftFill=" + Math.round(seamPanel._leftFillWidth)
                                      + " rightFill=" + Math.round(seamPanel._rightFillWidth)
                                      + " seamLeft=" + Math.round(seamPanel.seamLeftMargin)
                                      + " seamW=" + Math.round(seamPanel.seamWidthPx)
                                      + " monW=" + Math.round(seamPanel.monitorWidth)
                            }
                        }
                    }

                    // (debug logging removed)
                }

            }
        }
    }
}
