import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Qt5Compat.GraphicalEffects as GE
import qs.Bar.Modules
import qs.Components
import "Modules" as LocalMods
import qs.Services
import qs.Settings
import qs.Widgets.SidePanel
import "../Helpers/Color.js" as Color
import "../Helpers/WidgetBg.js" as WidgetBg

Scope {
    id: rootScope
    property var shell
    property alias visible: barRootItem.visible
    property real barHeight: 0 // Expose current bar height for other components (e.g. window mirroring)
    property bool diagnosticsEnabled: false

    component PanelSeparator : Rectangle {
        required property real scaleFactor
        required property int panelHeightPx
        property real alpha: 0.0
        width: Math.max(1, Math.round(scaleFactor * Math.max(1, Theme.uiBorderWidth) * 16))
        height: Math.max(2, Math.round(panelHeightPx * 0.68 * 16))
        radius: 0
        color: Color.withAlpha(Theme.textPrimary, alpha)
        opacity: 1.0
        Layout.alignment: Qt.AlignVCenter
    }

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
                    // Debug/testing: put bars on Overlay when wedge debug or shader-test enabled
                    WlrLayershell.layer: (((Quickshell.env("QS_WEDGE_DEBUG") || "") === "1")
                                          || ((Quickshell.env("QS_WEDGE_SHADER_TEST") || "") === "1"))
                        ? WlrLayer.Overlay : WlrLayer.Top
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
                    readonly property real _sideMarginBase: (
                        Settings.settings.panelSideMarginPx !== undefined
                        && Settings.settings.panelSideMarginPx !== null
                        && isFinite(Settings.settings.panelSideMarginPx)
                    ) ? Settings.settings.panelSideMarginPx : Theme.panelSideMargin
                    property int sideMargin: Math.round(_sideMarginBase * s)
                    property int widgetSpacing: Math.round(Theme.panelWidgetSpacing * s)
                    // Provide extra spacing between widgets now that decorative separators are gone
                    property int interWidgetSpacing: Math.max(widgetSpacing, Math.round(widgetSpacing * 1.35))
                    property int seamWidth: Math.max(8, Math.round(widgetSpacing * 0.85))
                    // Panel background transparency is configurable via Settings:
                    // - panelBgAlphaScale: 0..1 multiplier (preferred)
                    // - panelBgAlphaFactor: >0 divisor (fallback), e.g. 5 means 5x more transparent
                    property color barBgColor: Color.withAlpha(Theme.background, 0.0)
                    property real seamTaperTop: 0.25
                    property real seamTaperBottom: 0.9
                    property real seamOpacity: 0.55
                    readonly property real seamTiltSign: 1.0
                    readonly property real seamTaperTopClamped: Math.max(0.0, Math.min(1.0, seamTaperTop))
                    readonly property real seamTaperBottomClamped: Math.max(0.0, Math.min(1.0, seamTaperBottom))
                    readonly property real seamEdgeBaseTop: (seamTiltSign > 0)
                        ? (1.0 - seamTaperTopClamped)
                        : seamTaperTopClamped
                    readonly property real seamEdgeSlope: ((seamTiltSign > 0)
                        ? (1.0 - seamTaperBottomClamped)
                        : seamTaperBottomClamped) - seamEdgeBaseTop
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
                    property bool debugNetTriangle: rootScope.diagnosticsEnabled && Settings.settings.debugTriangleLeft

                    readonly property real contentWidth: Math.max(
                        leftWidgetsRow.width,
                        leftWidgetsRow.implicitWidth || leftWidgetsRow.width || 0
                    ) + leftPanel.interWidgetSpacing

                        Item {
                            id: leftPanelContent
                            anchors.fill: parent

                        // Full-surface debug tint to verify the window renders
                        Rectangle {
                            anchors.fill: parent
                            z: 2000000
                            color: "#80ffff00" // yellow, semi-transparent
                            // Only if explicitly requested
                            visible: (Quickshell.env("QS_WEDGE_TINT_TEST") || "") === "1"
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
                            // Keep visible; ShaderEffectSource will hide it from the scene
                            // only when the shader clip is active (via hideSource binding).
                        }
                        // Cut a triangular window from the right edge of leftBarFill
                        // so the underlying seam (in seamPanel) shows through exactly.
                        ShaderEffectSource {
                            id: leftBarFillSource
                            anchors.fill: leftBarFill
                            sourceItem: leftBarFill
                            // Hide the source item only when we are actually using
                            // the shader clip. Otherwise allow the base fill to draw.
                            hideSource: leftFaceClipLoader.active === true
                            live: true
                            recursive: true
                        }
                        // Legacy Canvas/OpacityMask fallback removed — shader path only
                        // Panel tint (left) drawn and masked within leftPanelContent so anchors are valid siblings
                        ShaderEffect {
                            id: leftPanelTintFX
                            anchors.fill: leftBarFill
                            // Keep the tint effect enabled when panelTintEnabled.
                            // ShaderEffectSource below hides it from the scene when the
                            // clipped-tint path is active.
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
                        ShaderEffectSource {
                            id: leftPanelTintSource
                            anchors.fill: leftBarFill
                            sourceItem: leftPanelTintFX
                            // Hide the tint effect when the clipped tint path is active.
                            hideSource: leftTintClipLoader.active === true
                            live: true
                            recursive: true
                        }
                        // Legacy tint mask fallback removed — shader path only
                        // Shader-based subtractive wedge for the tint overlay (enabled with the same flag)
                        Loader {
                            id: leftTintClipLoader
                            anchors.fill: leftBarFill
                            z: 2
                            active: leftPanel.panelTintEnabled && leftFaceClipLoader.active === true
                            sourceComponent: ShaderEffect {
                                fragmentShader: Qt.resolvedUrl("../shaders/wedge_clip.frag.qsb")
                                property var sourceSampler: leftPanelTintSource
                                property vector4d params0: Qt.vector4d(
                                    // QS_WEDGE_WIDTH_PCT override; otherwise use panel seamWidth capped to 35% of face.
                                    (function(){
                                        var ww = Number(Quickshell.env("QS_WEDGE_WIDTH_PCT") || "");
                                        if (isFinite(ww) && ww > 0) return Math.max(0.0, Math.min(1.0, ww/100.0));
                                        var faceW = Math.max(1, leftBarFill.width);
                                        var targetPx = Math.max(1, Math.round(leftPanel.seamWidth));
                                        var capPx = Math.round(faceW * 0.35);
                                        var wpx = Math.min(targetPx, capPx);
                                        return Math.max(0.02, Math.min(0.98, wpx / faceW));
                                    })(),
                                    Settings.settings.debugTriangleLeftSlopeUp ? 1 : 0,
                                    1,
                                    0
                                )
                                property vector4d params1: Qt.vector4d(
                                    Math.max(0.0, Math.min(0.05, (Math.max(1, Math.round(Theme.uiRadiusSmall * 0.5 * leftPanel.s)) / Math.max(1, leftBarFill.width)))) ,
                                    0,0,0
                                )
                                // In shader-test mode, force visible magenta overlay for tint path as well
                                property vector4d params2: Qt.vector4d(
                                    ((Quickshell.env("QS_WEDGE_SHADER_TEST") || "") === "1") ? 0.6 : 0.0,
                                    ((Quickshell.env("QS_WEDGE_SHADER_TEST") || "") === "1") ? 1.0 : 0.0,
                                    0,0)
                                blending: true
                                Component.onCompleted: {
                                    if (rootScope.diagnosticsEnabled && Settings.settings.debugLogs)
                                        console.log("[wedge:left:tint] shader ready", params0.x, params1.x)
                                }
                            }
                        }
                        // Subtractive wedge using a shader clip over the base face (lazy-loaded)
                        Loader {
                            id: leftFaceClipLoader
                            anchors.fill: leftBarFill
                            // Raise above base content; seam remains higher.
                            z: 50
                            // Force-activate in debug/test modes to guarantee visibility
                            active: ((Quickshell.env("QS_ENABLE_WEDGE_CLIP") || "") === "1")
                                    || ((Quickshell.env("QS_WEDGE_DEBUG") || "") === "1")
                                    || ((Quickshell.env("QS_WEDGE_SHADER_TEST") || "") === "1")
                                    || (Settings.settings.enableWedgeClipShader === true)
                            onActiveChanged: {
                                if (rootScope.diagnosticsEnabled && Settings.settings.debugLogs) {
                                    console.log("[bar:left] wedge shader active:", leftFaceClipLoader.active,
                                                "debug=", (Quickshell.env("QS_WEDGE_DEBUG")||""),
                                                "widthPct=", (Quickshell.env("QS_WEDGE_WIDTH_PCT")||""))
                                }
                            }
                            sourceComponent: ShaderEffect {
                                fragmentShader: Qt.resolvedUrl("../shaders/wedge_clip.frag.qsb")
                                // Clip the base face (pure fill color) to subtract the wedge
                                property var sourceSampler: leftBarFillSource
                                // params0: x=wNorm, y=slopeUp, z=side(+1 right edge), w=unused
                                property vector4d params0: Qt.vector4d(
                                    (function(){
                                        var ww = Number(Quickshell.env("QS_WEDGE_WIDTH_PCT") || "");
                                        if (isFinite(ww) && ww > 0) return Math.max(0.0, Math.min(1.0, ww/100.0));
                                        var faceW = Math.max(1, leftBarFill.width);
                                        var targetPx = Math.max(1, Math.round(leftPanel.seamWidth));
                                        var capPx = Math.round(faceW * 0.35);
                                        var wpx = Math.min(targetPx, capPx);
                                        return Math.max(0.02, Math.min(0.98, wpx / faceW));
                                    })(),
                                    Settings.settings.debugTriangleLeftSlopeUp ? 1 : 0,
                                    1,
                                    0
                                )
                                // params1: x=feather
                                property vector4d params1: Qt.vector4d(
                                    Math.max(0.0, Math.min(0.05, (Math.max(1, Math.round(Theme.uiRadiusSmall * 0.5 * leftPanel.s)) / Math.max(1, leftBarFill.width)))) ,
                                    0,0,0
                                )
                                // Enable magenta wedge overlay when QS_WEDGE_DEBUG=1
                                property vector4d params2: Qt.vector4d(
                                    ((Quickshell.env("QS_WEDGE_DEBUG") || "") === "1") ? 0.6 : 0.0,
                                    ((Quickshell.env("QS_WEDGE_SHADER_TEST") || "") === "1") ? 1.0 : 0.0,
                                    0, 0)
                                blending: true
                                Component.onCompleted: {
                                    if (rootScope.diagnosticsEnabled && Settings.settings.debugLogs)
                                        console.log("[wedge:left:base] shader ready", params0.x, params1.x)
                                }
                            }
                        }

                        // Extra on-screen debug overlay to be absolutely sure about geometry.
                        // Drawn only when QS_WEDGE_DEBUG=1
                        Canvas {
                            id: leftWedgeOverlayDebug
                            anchors.fill: leftBarFill
                            z: 999999
                            visible: rootScope.diagnosticsEnabled && ((Quickshell.env("QS_WEDGE_DEBUG") || "") === "1")
                            property bool _loggedOnce: false
                            onPaint: {
                                var ctx = getContext('2d');
                                ctx.reset();
                                ctx.clearRect(0, 0, width, height);
                                // Background highlight to prove this item renders
                                ctx.fillStyle = 'rgba(255,255,0,0.50)';
                                ctx.fillRect(0, 0, width, height);
                                var ww = Number(Quickshell.env("QS_WEDGE_WIDTH_PCT") || "");
                                var faceW = Math.max(1, leftBarFill.width);
                                var targetPx = Math.max(1, Math.round(leftPanel.seamWidth));
                                var capPx = Math.round(faceW * 0.35);
                                var autoPx = Math.min(targetPx, capPx);
                                var wnorm = (isFinite(ww) && ww > 0) ? Math.max(0.0, Math.min(1.0, ww/100.0)) : Math.max(0.02, Math.min(0.98, autoPx / faceW));
                                var wpx = Math.max(1, Math.round(wnorm * width));
                                ctx.fillStyle = 'rgba(255,0,255,0.45)';
                                ctx.beginPath();
                                if (Settings.settings.debugTriangleLeftSlopeUp) {
                                    // bottom-left → top-right, wedge at right edge
                                    ctx.moveTo(width - wpx, height);
                                    ctx.lineTo(width, 0);
                                    ctx.lineTo(width, height);
                                } else {
                                    // top-left → bottom-right, wedge at right edge
                                    ctx.moveTo(width - wpx, 0);
                                    ctx.lineTo(width, height);
                                    ctx.lineTo(width, 0);
                                }
                                ctx.closePath();
                                ctx.fill();
                                // Outline for visibility
                                ctx.strokeStyle = 'rgba(255,0,255,0.9)';
                                ctx.lineWidth = 2;
                                ctx.stroke();
                                if (rootScope.diagnosticsEnabled && Settings.settings.debugLogs && !leftWedgeOverlayDebug._loggedOnce) {
                                    leftWedgeOverlayDebug._loggedOnce = true;
                                    console.log("[wedge:left:overlay] size=", width, height,
                                                "leftBarFillW=", leftBarFill.width,
                                                "seamW=", seamPanel.seamWidthPx,
                                                "wnorm=", wnorm, "wpx=", wpx,
                                                "slopeUp=", Settings.settings.debugTriangleLeftSlopeUp);
                                }
                            }
                        }
                        Item {
                            id: leftSeamFill
                            width: Math.min(leftBarBackground.width, leftPanel.seamWidth)
                            height: leftBarBackground.height
                            anchors.bottom: leftBarBackground.bottom
                            anchors.right: leftBarBackground.right
                            z: 1000
                            // Draw local seam wedge only when the shader path is active,
                            // and hide it while QS_WEDGE_DEBUG is enabled so the shader's
                            // magenta overlay remains visible for validation.
                            visible: leftFaceClipLoader.active === true && ((Quickshell.env("QS_WEDGE_DEBUG") || "") !== "1")
                            ShaderEffect {
                                id: leftSeamFX
                                anchors.fill: parent
                                fragmentShader: Qt.resolvedUrl("../shaders/seam.frag.qsb")
                                property color baseColor: leftPanel.seamFillColor
                                // params0: edgeBase, edgeSlope, tilt, opacity
                                property vector4d params0: Qt.vector4d(leftPanel.seamEdgeBaseTop, leftPanel.seamEdgeSlope, leftPanel.seamTiltSign, leftPanel.seamOpacity)
                                blending: true
                            }
                        }

                        // Mask the left seam fill so its visible area becomes a triangle
                        // matching the wedge; this prevents rectangular seam blocks.
                        ShaderEffectSource {
                            id: leftSeamSource
                            anchors.fill: leftSeamFill
                            sourceItem: leftSeamFX
                            hideSource: true
                            live: true
                            recursive: true
                        }
                        Canvas {
                            id: leftSeamMask
                            anchors.fill: leftSeamFill
                            visible: false
                            onPaint: {
                                var ctx = getContext('2d');
                                ctx.reset();
                                ctx.clearRect(0, 0, width, height);
                                ctx.fillStyle = '#ffffffff';
                                ctx.fillRect(0, 0, width, height);
                                // Cut triangle adjacent to the seam boundary (x = 0 in this local space)
                                ctx.fillStyle = '#000000ff';
                                ctx.beginPath();
                                if (Settings.settings.debugTriangleLeftSlopeUp) {
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
                        GE.OpacityMask {
                            anchors.fill: leftSeamFill
                            source: leftSeamSource
                            maskSource: leftSeamMask
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
                            spacing: leftPanel.interWidgetSpacing
                            ClockWidget { Layout.alignment: Qt.AlignVCenter }
                            PanelSeparator {
                                scaleFactor: leftPanel.s
                                panelHeightPx: leftPanel.barHeightPx
                            }
                            WsIndicator { id: wsindicator; Layout.alignment: Qt.AlignVCenter }
                            PanelSeparator {
                                scaleFactor: leftPanel.s
                                panelHeightPx: leftPanel.barHeightPx
                            }
                            KeyboardLayoutHypr { id: kbIndicator; Layout.alignment: Qt.AlignVCenter }
                            PanelSeparator {
                                scaleFactor: leftPanel.s
                                panelHeightPx: leftPanel.barHeightPx
                                visible: netCluster.visible
                            }
                                Row {
                                    id: netCluster
                                    Layout.alignment: Qt.AlignVCenter
                                    spacing: Math.round(Theme.panelNetClusterSpacing * leftPanel.s)
                                    LocalMods.VpnAmneziaIndicator {
                                        id: amneziaVpn
                                        showLabel: false
                                        iconRounded: true
                                    }
                                    LocalMods.NetworkLinkIndicator {
                                        id: netLinkIndicator
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
                            PanelSeparator {
                                scaleFactor: leftPanel.s
                                panelHeightPx: leftPanel.barHeightPx
                                visible: Settings.settings.showWeatherInBar === true
                            }
                            LocalMods.WeatherButton { visible: Settings.settings.showWeatherInBar === true; Layout.alignment: Qt.AlignVCenter }
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

                    // Alternative approach: render a local copy of the seam (fill + tint)
                    // and clip it to a triangular wedge so it looks like a direct
                    // continuation of the center seam, without sampling from layershell.
                    Item {
                        id: leftSeamWedge
                        // Disabled to rely on subtractive masking of the main fill
                        visible: false
                        opacity: 1.0
                        z: 9000000
                        width: Math.max(1, leftPanel.seamWidth)
                        height: leftPanel.barHeightPx
                        anchors.top: parent.top
                        anchors.left: leftPanelContent.left
                        anchors.leftMargin: Math.round(netTriangleAnchor.seamStartLocal + leftPanel.seamWidth)
                        anchors.topMargin: 0
                        

                        // Hidden visuals that replicate the seam look (base fill + tint)
                        Item {
                            id: leftWedgeVisuals
                            anchors.fill: parent
                            // Keep visible so ShaderEffectSource can capture it; we hide via hideSource below
                            visible: true
                            ShaderEffect {
                                anchors.fill: parent
                                fragmentShader: Qt.resolvedUrl("../shaders/seam_fill.frag.qsb")
                                property color baseColor: seamPanel.seamBaseColor
                                property vector4d params0: Qt.vector4d(
                                    seamPanel.seamBaseOpacityTop,
                                    seamPanel.seamBaseOpacityBottom - seamPanel.seamBaseOpacityTop,
                                    0,
                                    0
                                )
                            }
                            ShaderEffect {
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
                            }
                        }

                        // Route visuals through a ShaderEffectSource so OpacityMask always has a renderable source
                        ShaderEffectSource {
                            id: leftWedgeSource
                            anchors.fill: parent
                            sourceItem: leftWedgeVisuals
                            hideSource: true
                            live: true
                            recursive: true
                        }

                        // Debug bright fill to localize the wedge on screen (disabled)
                        Rectangle {
                            id: leftWedgeDebugFill
                            anchors.fill: parent
                            color: "#00ff00"
                            opacity: 0.8
                            visible: false
                            z: 5
                        }

                        // Explicit triangle to verify geometry (drawn above mask result)
                        Canvas {
                            id: leftWedgeDebugTriangle
                            anchors.fill: parent
                            visible: false
                            z: 6
                            onPaint: {
                                var ctx = getContext('2d');
                                ctx.reset();
                                ctx.clearRect(0, 0, width, height);
                                ctx.fillStyle = '#00ff00';
                                ctx.beginPath();
                                if (Settings.settings.debugTriangleLeftSlopeUp) {
                                    ctx.moveTo(0, height);
                                    ctx.lineTo(width, 0);
                                    ctx.lineTo(width, height);
                                } else {
                                    ctx.moveTo(0, 0);
                                    ctx.lineTo(width, height);
                                    ctx.lineTo(width, 0);
                                }
                                ctx.closePath();
                                ctx.fill();
                            }
                        }

                        // Triangular mask: white = keep wedge, black = discard
                        Canvas {
                            id: leftWedgeMask
                            anchors.fill: parent
                            visible: false
                            onPaint: {
                                var ctx = getContext('2d');
                                ctx.reset();
                                // Start fully transparent (mask alpha = 0 everywhere)
                                ctx.clearRect(0, 0, width, height);
                                // Keep only the triangular wedge: draw opaque white (mask alpha = 1)
                                ctx.fillStyle = '#ffffffff';
                                ctx.beginPath();
                                if (Settings.settings.debugTriangleLeftSlopeUp) {
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
                        GE.OpacityMask {
                            anchors.fill: parent
                            // Use the actual seam visuals for the wedge instead of the debug fill
                            source: leftWedgeSource
                            maskSource: leftWedgeMask
                        }
                    }

                    // (old Canvas triangle overlay removed to avoid blue tint overlay)
                }

                PanelWindow {
                    id: rightPanel
                    screen: modelData
                    color: "transparent"
                    property bool panelHovering: false
                    WlrLayershell.namespace: "quickshell-bar-right"
                    // Debug/testing: put bars on Overlay when wedge debug or shader-test enabled
                    WlrLayershell.layer: (((Quickshell.env("QS_WEDGE_DEBUG") || "") === "1")
                                          || ((Quickshell.env("QS_WEDGE_SHADER_TEST") || "") === "1"))
                        ? WlrLayer.Overlay : WlrLayer.Top
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
                    readonly property real _sideMarginBase: (
                        Settings.settings.panelSideMarginPx !== undefined
                        && Settings.settings.panelSideMarginPx !== null
                        && isFinite(Settings.settings.panelSideMarginPx)
                    ) ? Settings.settings.panelSideMarginPx : Theme.panelSideMargin
                    property int sideMargin: Math.round(_sideMarginBase * s)
                    property int widgetSpacing: Math.round(Theme.panelWidgetSpacing * s)
                    property int interWidgetSpacing: Math.max(widgetSpacing, Math.round(widgetSpacing * 1.35))
                    property int seamWidth: Math.max(8, Math.round(widgetSpacing * 0.85))
                    // Panel background transparency is configurable via Settings:
                    // - panelBgAlphaScale: 0..1 multiplier (preferred)
                    // - panelBgAlphaFactor: >0 divisor (fallback), e.g. 5 means 5x more transparent
                    property color barBgColor: Color.withAlpha(Theme.background, 0.0)
                    property real seamTaperTop: 0.25
                    property real seamTaperBottom: 0.9
                    property real seamOpacity: 0.55
                    readonly property real seamTiltSign: -1.0
                    readonly property real seamTaperTopClamped: Math.max(0.0, Math.min(1.0, seamTaperTop))
                    readonly property real seamTaperBottomClamped: Math.max(0.0, Math.min(1.0, seamTaperBottom))
                    readonly property real seamEdgeBaseTop: (seamTiltSign > 0)
                        ? (1.0 - seamTaperTopClamped)
                        : seamTaperTopClamped
                    readonly property real seamEdgeSlope: ((seamTiltSign > 0)
                        ? (1.0 - seamTaperBottomClamped)
                        : seamTaperBottomClamped) - seamEdgeBaseTop
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
                    ) + rightPanel.interWidgetSpacing

                        Item {
                            id: rightPanelContent
                            anchors.fill: parent

                        // Full-surface debug tint to verify the window renders
                        Rectangle {
                            anchors.fill: parent
                            z: 2000000
                            color: "#8000ffff" // cyan, semi-transparent
                            // Only if explicitly requested
                            visible: (Quickshell.env("QS_WEDGE_TINT_TEST") || "") === "1"
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
                            // Keep visible; ShaderEffectSource will hide it from the scene
                            // only when the shader clip is active (via hideSource binding).
                        }
                        // Cut a triangular window from the left edge of rightBarFill
                        // so the underlying seam (in seamPanel) shows through exactly.
                        ShaderEffectSource {
                            id: rightBarFillSource
                            anchors.fill: rightBarFill
                            sourceItem: rightBarFill
                            // Hide the source item only when we are actually using the shader
                            // clip. Otherwise allow the base fill to draw.
                            hideSource: rightFaceClipLoader.active === true
                            live: true
                            recursive: true
                        }
                        // Legacy Canvas/OpacityMask fallback removed — shader path only
                        // Panel tint (right) drawn and masked within rightPanelContent so anchors are valid siblings
                        ShaderEffect {
                            id: rightPanelTintFX
                            anchors.fill: rightBarFill
                            // Keep the tint effect enabled when panelTintEnabled. The
                            // ShaderEffectSource below hides it when the clipped-tint path
                            // is active.
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
                        ShaderEffectSource {
                            id: rightPanelTintSource
                            anchors.fill: rightBarFill
                            sourceItem: rightPanelTintFX
                            // Hide the tint effect when the clipped tint path is active.
                            hideSource: rightTintClipLoader.active === true
                            live: true
                            recursive: true
                        }
                        // Legacy tint mask fallback removed — shader path only
                        // Shader-based subtractive wedge for the tint overlay (enabled with the same flag)
                        Loader {
                            id: rightTintClipLoader
                            anchors.fill: rightBarFill
                            z: 2
                            active: rightPanel.panelTintEnabled && rightFaceClipLoader.active === true
                            sourceComponent: ShaderEffect {
                                fragmentShader: Qt.resolvedUrl("../shaders/wedge_clip.frag.qsb")
                                property var sourceSampler: rightPanelTintSource
                                property vector4d params0: Qt.vector4d(
                                    (function(){
                                        var ww = Number(Quickshell.env("QS_WEDGE_WIDTH_PCT") || "");
                                        if (isFinite(ww) && ww > 0) return Math.max(0.0, Math.min(1.0, ww/100.0));
                                        var faceW = Math.max(1, rightBarFill.width);
                                        var targetPx = Math.max(1, Math.round(rightPanel.seamWidth));
                                        var capPx = Math.round(faceW * 0.35);
                                        var wpx = Math.min(targetPx, capPx);
                                        return Math.max(0.02, Math.min(0.98, wpx / faceW));
                                    })(),
                                    Settings.settings.debugTriangleRightSlopeUp ? 1 : 0,
                                    -1,
                                    0
                                )
                                property vector4d params1: Qt.vector4d(
                                    Math.max(0.0, Math.min(0.05, (Math.max(1, Math.round(Theme.uiRadiusSmall * 0.5 * rightPanel.s)) / Math.max(1, rightBarFill.width)))) ,
                                    0,0,0
                                )
                                // In shader-test mode, force visible magenta overlay for tint path as well
                                property vector4d params2: Qt.vector4d(
                                    ((Quickshell.env("QS_WEDGE_SHADER_TEST") || "") === "1") ? 0.6 : 0.0,
                                    ((Quickshell.env("QS_WEDGE_SHADER_TEST") || "") === "1") ? 1.0 : 0.0,
                                    0,0)
                                blending: true
                                Component.onCompleted: {
                                    if (rootScope.diagnosticsEnabled && Settings.settings.debugLogs)
                                        console.log("[wedge:right:tint] shader ready", params0.x, params1.x)
                                }
                            }
                        }
                        // Subtractive wedge using a shader clip over the base face (lazy-loaded)
                        Loader {
                            id: rightFaceClipLoader
                            anchors.fill: rightBarFill
                            z: 50
                            active: ((Quickshell.env("QS_ENABLE_WEDGE_CLIP") || "") === "1")
                                    || ((Quickshell.env("QS_WEDGE_DEBUG") || "") === "1")
                                    || ((Quickshell.env("QS_WEDGE_SHADER_TEST") || "") === "1")
                                    || (Settings.settings.enableWedgeClipShader === true)
                            onActiveChanged: {
                                if (rootScope.diagnosticsEnabled && Settings.settings.debugLogs) {
                                    console.log("[bar:right] wedge shader active:", rightFaceClipLoader.active,
                                                "debug=", (Quickshell.env("QS_WEDGE_DEBUG")||""),
                                                "widthPct=", (Quickshell.env("QS_WEDGE_WIDTH_PCT")||""))
                                }
                            }
                            sourceComponent: ShaderEffect {
                                fragmentShader: Qt.resolvedUrl("../shaders/wedge_clip.frag.qsb")
                                // Clip the base face (pure fill color) to subtract the wedge
                                property var sourceSampler: rightBarFillSource
                                // params0: x=wNorm, y=slopeUp, z=side(-1 left edge), w=unused
                                property vector4d params0: Qt.vector4d(
                                    (function(){
                                        var ww = Number(Quickshell.env("QS_WEDGE_WIDTH_PCT") || "");
                                        if (isFinite(ww) && ww > 0) return Math.max(0.0, Math.min(1.0, ww/100.0));
                                        var faceW = Math.max(1, rightBarFill.width);
                                        var targetPx = Math.max(1, Math.round(rightPanel.seamWidth));
                                        var capPx = Math.round(faceW * 0.35);
                                        var wpx = Math.min(targetPx, capPx);
                                        return Math.max(0.02, Math.min(0.98, wpx / faceW));
                                    })(),
                                    Settings.settings.debugTriangleRightSlopeUp ? 1 : 0,
                                    -1,
                                    0
                                )
                                // params1: x=feather
                                property vector4d params1: Qt.vector4d(
                                    Math.max(0.0, Math.min(0.05, (Math.max(1, Math.round(Theme.uiRadiusSmall * 0.5 * rightPanel.s)) / Math.max(1, rightBarFill.width)))) ,
                                    0,0,0
                                )
                                // Enable magenta wedge overlay when QS_WEDGE_DEBUG=1
                                property vector4d params2: Qt.vector4d(
                                    ((Quickshell.env("QS_WEDGE_DEBUG") || "") === "1") ? 0.6 : 0.0,
                                    ((Quickshell.env("QS_WEDGE_SHADER_TEST") || "") === "1") ? 1.0 : 0.0,
                                    0, 0)
                                blending: true
                                Component.onCompleted: {
                                    if (rootScope.diagnosticsEnabled && Settings.settings.debugLogs)
                                        console.log("[wedge:right:base] shader ready", params0.x, params1.x)
                                }
                            }
                        }

                        // Extra on-screen debug overlay to be absolutely sure about geometry.
                        Canvas {
                            id: rightWedgeOverlayDebug
                            anchors.fill: rightBarFill
                            z: 999999
                            visible: rootScope.diagnosticsEnabled && ((Quickshell.env("QS_WEDGE_DEBUG") || "") === "1")
                            property bool _loggedOnce: false
                            onPaint: {
                                var ctx = getContext('2d');
                                ctx.reset();
                                ctx.clearRect(0, 0, width, height);
                                // Background highlight to prove this item renders
                                ctx.fillStyle = 'rgba(0,255,255,0.50)';
                                ctx.fillRect(0, 0, width, height);
                                var ww = Number(Quickshell.env("QS_WEDGE_WIDTH_PCT") || "");
                                var faceW = Math.max(1, rightBarFill.width);
                                var targetPx = Math.max(1, Math.round(rightPanel.seamWidth));
                                var capPx = Math.round(faceW * 0.35);
                                var autoPx = Math.min(targetPx, capPx);
                                var wnorm = (isFinite(ww) && ww > 0) ? Math.max(0.0, Math.min(1.0, ww/100.0)) : Math.max(0.02, Math.min(0.98, autoPx / faceW));
                                var wpx = Math.max(1, Math.round(wnorm * width));
                                ctx.fillStyle = 'rgba(255,0,255,0.45)';
                                ctx.beginPath();
                                if (Settings.settings.debugTriangleRightSlopeUp) {
                                    // bottom-left → top-right, wedge at left edge
                                    ctx.moveTo(0, height);
                                    ctx.lineTo(wpx, 0);
                                    ctx.lineTo(0, 0);
                                } else {
                                    // top-left → bottom-right, wedge at left edge
                                    ctx.moveTo(0, 0);
                                    ctx.lineTo(wpx, height);
                                    ctx.lineTo(0, height);
                                }
                                ctx.closePath();
                                ctx.fill();
                                // Outline for visibility
                                ctx.strokeStyle = 'rgba(255,0,255,0.9)';
                                ctx.lineWidth = 2;
                                ctx.stroke();
                                if (rootScope.diagnosticsEnabled && Settings.settings.debugLogs && !rightWedgeOverlayDebug._loggedOnce) {
                                    rightWedgeOverlayDebug._loggedOnce = true;
                                    console.log("[wedge:right:overlay] size=", width, height,
                                                "rightBarFillW=", rightBarFill.width,
                                                "seamW=", seamPanel.seamWidthPx,
                                                "wnorm=", wnorm, "wpx=", wpx,
                                                "slopeUp=", Settings.settings.debugTriangleRightSlopeUp);
                                }
                            }
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

                        // Symmetric seam wedge for the right side (disabled)
                        Item {
                            id: rightSeamWedge
                            // Disabled to rely on subtractive masking of the main fill
                            visible: false
                            opacity: 1.0
                            z: 9000000
                            width: Math.max(1, rightPanel.seamWidth)
                            height: rightPanel.barHeightPx
                            anchors.top: parent.top
                            anchors.left: rightPanelContent.left
                            anchors.leftMargin: Math.round(rightNetTriangleAnchor.seamStartLocal - rightPanel.seamWidth)
                            anchors.topMargin: 0
                            

                            Item {
                                id: rightWedgeVisuals
                                anchors.fill: parent
                                // Keep visible so ShaderEffectSource can capture it; we hide via hideSource below
                                visible: true
                                ShaderEffect {
                                    anchors.fill: parent
                                    fragmentShader: Qt.resolvedUrl("../shaders/seam_fill.frag.qsb")
                                property color baseColor: seamPanel.seamBaseColor
                                property vector4d params0: Qt.vector4d(
                                    seamPanel.seamBaseOpacityTop,
                                    seamPanel.seamBaseOpacityBottom - seamPanel.seamBaseOpacityTop,
                                    0,
                                    0
                                )
                                }
                                ShaderEffect {
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
                                }
                            }

                            // Route visuals through a ShaderEffectSource so OpacityMask always has a renderable source
                            ShaderEffectSource {
                                id: rightWedgeSource
                                anchors.fill: parent
                                sourceItem: rightWedgeVisuals
                                hideSource: true
                                live: true
                                recursive: true
                            }

                            // Debug bright fill to localize the wedge on screen (disabled)
                            Rectangle {
                                id: rightWedgeDebugFill
                                anchors.fill: parent
                                color: "#00ff00"
                                opacity: 0.8
                                visible: false
                                z: 5
                            }

                            // Explicit triangle for right side
                            Canvas {
                                id: rightWedgeDebugTriangle
                                anchors.fill: parent
                                visible: false
                                z: 6
                                onPaint: {
                                    var ctx = getContext('2d');
                                    ctx.reset();
                                    ctx.clearRect(0, 0, width, height);
                                    ctx.fillStyle = '#00ff00';
                                    ctx.beginPath();
                                    if (Settings.settings.debugTriangleRightSlopeUp) {
                                        ctx.moveTo(0, height);
                                        ctx.lineTo(width, 0);
                                        ctx.lineTo(0, 0);
                                    } else {
                                        ctx.moveTo(0, 0);
                                        ctx.lineTo(width, height);
                                        ctx.lineTo(0, height);
                                    }
                                    ctx.closePath();
                                    ctx.fill();
                                }
                            }

                            Canvas {
                                id: rightWedgeMask
                                anchors.fill: parent
                                visible: false
                                onPaint: {
                                    var ctx = getContext('2d');
                                    ctx.reset();
                                    // Start fully transparent (mask alpha = 0 everywhere)
                                    ctx.clearRect(0, 0, width, height);
                                    // Keep only the triangular wedge: draw opaque white (mask alpha = 1)
                                    ctx.fillStyle = '#ffffffff';
                                    ctx.beginPath();
                                    if (Settings.settings.debugTriangleRightSlopeUp) {
                                        // bottom-left → top-right (vertical edge at x=0)
                                        ctx.moveTo(0, height);
                                        ctx.lineTo(width, 0);
                                        ctx.lineTo(0, 0);
                                    } else {
                                        // top-left → bottom-right (vertical edge at x=0)
                                        ctx.moveTo(0, 0);
                                        ctx.lineTo(width, height);
                                        ctx.lineTo(0, height);
                                    }
                                    ctx.closePath();
                                    ctx.fill();
                                }
                            }
                            GE.OpacityMask {
                                anchors.fill: parent
                                // Use the actual seam visuals for the wedge instead of the debug fill
                                source: rightWedgeSource
                                maskSource: rightWedgeMask
                            }
                        }
                        // (old right Canvas triangle overlay removed)
                        Item {
                            id: rightSeamFill
                            width: Math.min(rightBarBackground.width, rightPanel.seamWidth)
                            height: rightBarBackground.height
                            anchors.bottom: rightBarBackground.bottom
                            anchors.left: rightBarBackground.left
                            z: 1000
                            // Draw local seam wedge only when the shader path is active,
                            // and hide it while QS_WEDGE_DEBUG is enabled so the shader's
                            // magenta overlay remains visible for validation.
                            visible: rightFaceClipLoader.active === true && ((Quickshell.env("QS_WEDGE_DEBUG") || "") !== "1")
                            ShaderEffect {
                                id: rightSeamFX
                                anchors.fill: parent
                                fragmentShader: Qt.resolvedUrl("../shaders/seam.frag.qsb")
                                property color baseColor: rightPanel.seamFillColor
                                // params0: edgeBase, edgeSlope, tilt, opacity
                                property vector4d params0: Qt.vector4d(rightPanel.seamEdgeBaseTop, rightPanel.seamEdgeSlope, rightPanel.seamTiltSign, rightPanel.seamOpacity)
                                blending: true
                            }
                        }

                        // Mask the right seam fill similarly to form a triangular visible area.
                        ShaderEffectSource {
                            id: rightSeamSource
                            anchors.fill: rightSeamFill
                            sourceItem: rightSeamFX
                            hideSource: true
                            live: true
                            recursive: true
                        }
                        Canvas {
                            id: rightSeamMask
                            anchors.fill: rightSeamFill
                            visible: false
                            onPaint: {
                                var ctx = getContext('2d');
                                ctx.reset();
                                ctx.clearRect(0, 0, width, height);
                                ctx.fillStyle = '#ffffffff';
                                ctx.fillRect(0, 0, width, height);
                                // Cut triangle adjacent to the seam boundary (x = width in this local space)
                                ctx.fillStyle = '#000000ff';
                                ctx.beginPath();
                                if (Settings.settings.debugTriangleRightSlopeUp) {
                                    // bottom-left → top-right (vertical seam edge at the right)
                                    ctx.moveTo(width, height);
                                    ctx.lineTo(0, 0);
                                    ctx.lineTo(0, height);
                                } else {
                                    // top-left → bottom-right
                                    ctx.moveTo(width, 0);
                                    ctx.lineTo(0, height);
                                    ctx.lineTo(0, 0);
                                }
                                ctx.closePath();
                                ctx.fill();
                            }
                        }
                        GE.OpacityMask {
                            anchors.fill: rightSeamFill
                            source: rightSeamSource
                            maskSource: rightSeamMask
                        }

                        RowLayout {
                            id: rightWidgetsRow
                            anchors.verticalCenter: rightBarBackground.verticalCenter
                            anchors.right: rightBarBackground.right
                            anchors.rightMargin: rightPanel.sideMargin
                            spacing: 0
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
                            Item {
                                id: systemTrayWrapper
                                Layout.alignment: Qt.AlignVCenter
                                readonly property int padding: Math.max(2, Math.round(rightPanel.widgetSpacing * 0.45))
                                readonly property color capsuleColor: WidgetBg.color(Settings.settings, "systemTray", "rgba(10, 12, 20, 0.2)")
                                readonly property real hoverMixAmount: 0.18
                                readonly property color capsuleHoverColor: Color.mix(
                                                                           capsuleColor,
                                                                           Qt.rgba(1, 1, 1, 1),
                                                                           hoverMixAmount)
                                readonly property real trayContentHeight: (
                                    systemTrayModule.capsuleHeight !== undefined
                                        ? systemTrayModule.capsuleHeight
                                        : (systemTrayModule.implicitHeight || systemTrayModule.height || 0)
                                )
                                readonly property bool hovered: trayHover.hovered
                                                                 || systemTrayModule.panelHover
                                                                 || systemTrayModule.hotHover
                                                                 || systemTrayModule.expanded
                                implicitWidth: systemTrayBackground.width
                                implicitHeight: systemTrayBackground.height
                                HoverHandler { id: trayHover }

                                Rectangle {
                                    id: systemTrayBackground
                                    radius: Theme.cornerRadiusSmall
                                    color: systemTrayWrapper.hovered ? systemTrayWrapper.capsuleHoverColor
                                                                     : systemTrayWrapper.capsuleColor
                                    width: Math.max(1, systemTrayModule.implicitWidth) + systemTrayWrapper.padding * 2
                                    height: Math.max(1, systemTrayWrapper.trayContentHeight) + systemTrayWrapper.padding * 2
                                    border.width: Theme.uiBorderWidth
                                    border.color: Color.withAlpha(Theme.textPrimary, 0.08)
                                    antialiasing: true
                                }

                                SystemTray {
                                    id: systemTrayModule
                                    shell: rootScope.shell
                                    screen: modelData
                                    trayMenu: externalTrayMenu
                                    anchors.centerIn: systemTrayBackground
                                    inlineBgColor: systemTrayWrapper.capsuleColor
                                    inlineBorderColor: systemTrayWrapper.hovered
                                        ? Color.withAlpha(Theme.textPrimary, 0.12)
                                        : Color.withAlpha(Theme.textPrimary, 0.08)
                                }
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
                    property bool debugForceVisible: rootScope.diagnosticsEnabled
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
                    property real seamEffectOpacity: seamPanel.debugForceVisible ? 1.0 : 0.85
                    property color seamFillColor: Color.mix(Theme.surfaceVariant, Theme.background, 0.35)
                    property bool seamTintEnabled: true
                    // Use theme accent for seam tint to avoid hardcoded red
                    property color seamTintColor: Theme.accentPrimary
                    property real seamTintOpacity: seamPanel.debugForceVisible ? 1.0 : 0.9
                    property color seamBaseColor: Theme.background
                    property real seamBaseOpacityTop: seamPanel.debugForceVisible ? 1.0 : 0.5
                    property real seamBaseOpacityBottom: seamPanel.debugForceVisible ? 1.0 : 0.65
                    function seamClamp01(v) { return Math.max(0.0, Math.min(1.0, v)); }
                    function seamEdgeBaseForTilt(tiltSign, frac) {
                        var f = seamClamp01(frac);
                        return (tiltSign > 0) ? (1.0 - f) : f;
                    }
                    function seamEdgeParamsFor(tiltSign) {
                        var topEdge = seamEdgeBaseForTilt(tiltSign, seamTaperTop);
                        var bottomEdge = seamEdgeBaseForTilt(tiltSign, seamTaperBottom);
                        return ({ base: topEdge, slope: (bottomEdge - topEdge) });
                    }
                    readonly property var seamEdgeLeft: seamEdgeParamsFor(-1)
                    readonly property var seamEdgeRight: seamEdgeParamsFor(1)
                    property real seamTintTopInsetPx: Math.round(Theme.panelWidgetSpacing * 0.55 * s)
                    property real seamTintBottomInsetPx: Math.round(Theme.panelWidgetSpacing * 0.2 * s)
                    property real seamTintFeatherPx: Math.max(1, Math.round(Theme.uiRadiusSmall * 0.35 * s))
                    readonly property real monitorWidth: seamPanel.screen ? seamPanel.screen.width : seamPanel.width
                    // Debug: enable to overlay bounding boxes and logs
                    property bool debugSeam: rootScope.diagnosticsEnabled
                    // Debug: when true, the accent debug overlay fills the entire panel width
                    property bool debugFillFullWidth: rootScope.diagnosticsEnabled && Settings.settings.debugSeamFullWidth
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
                        Math.max(Math.round(Theme.panelWidgetSpacing * seamPanel.s * 2.4), rawGapWidth)
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

                        // Hidden visuals (used as source for mask)
                        Item {
                            id: seamVisuals
                            anchors.fill: parent
                            visible: false
                            ShaderEffect {
                                z: 0
                                anchors.fill: parent
                                fragmentShader: Qt.resolvedUrl("../shaders/seam_fill.frag.qsb")
                                property color baseColor: seamPanel.seamBaseColor
                                property vector4d params0: Qt.vector4d(
                                    seamPanel.seamBaseOpacityTop,
                                    seamPanel.seamBaseOpacityBottom - seamPanel.seamBaseOpacityTop,
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
                            Component.onCompleted: if (rootScope.diagnosticsEnabled && Settings.settings.debugLogs) console.log("[seam-panel]", "shader ready", seamPanel.seamWidthPx, seamPanel.seamTintColor)
                            }
                            Row {
                                z: 10
                                anchors.fill: parent
                            ShaderEffect {
                                width: parent.width / 2
                                height: parent.height
                                fragmentShader: Qt.resolvedUrl("../shaders/seam.frag.qsb")
                                property color baseColor: seamPanel.seamFillColor
                                property vector4d params0: Qt.vector4d(seamPanel.seamEdgeLeft.base, seamPanel.seamEdgeLeft.slope, -1, seamPanel.seamEffectOpacity)
                                blending: true
                            }
                            ShaderEffect {
                                width: parent.width / 2
                                height: parent.height
                                fragmentShader: Qt.resolvedUrl("../shaders/seam.frag.qsb")
                                property color baseColor: seamPanel.seamFillColor
                                property vector4d params0: Qt.vector4d(seamPanel.seamEdgeRight.base, seamPanel.seamEdgeRight.slope, 1, seamPanel.seamEffectOpacity)
                                blending: true
                            }
                            }
                        }

                        // (removed) Previously we punched holes in the seam visuals.
                        // The new approach is to mask panel fills instead, so the seam
                        // remains intact and shows through the wedges.
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
