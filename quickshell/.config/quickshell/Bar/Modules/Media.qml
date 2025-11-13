import QtQuick
import "../../Helpers/Utils.js" as Utils
import QtQuick.Controls
import QtQuick.Layouts
// Quickshell.Widgets not needed
import QtQuick.Effects
import "../../Helpers/Format.js" as Format
import "../../Helpers/RichText.js" as Rich
import "../../Helpers/Time.js" as Time
import "../../Helpers/Color.js" as Color
import qs.Settings
import qs.Services
import qs.Components
import "../../Helpers/WidgetBg.js" as WidgetBg
import "../../Helpers/CapsuleMetrics.js" as Capsule

Item {
    id: mediaControl
    property var sidePanelPopup: null
    readonly property real _scale: Theme.scale(Screen)
    readonly property var capsuleMetrics: Capsule.metrics(Theme, _scale)
    property int surfacePadding: capsuleMetrics.padding
    property int baseHeight: capsuleMetrics.height
    readonly property int capsuleInnerSize: capsuleMetrics.inner
    implicitWidth: mediaRow.implicitWidth + surfacePadding * 2
    height: baseHeight
    implicitHeight: height
    visible: Settings.settings.showMediaInBar
             && MusicManager.currentPlayer
             && !MusicManager.isStopped
             && (MusicManager.isPlaying
                 || MusicManager.isPaused
                 || (MusicManager.trackTitle && MusicManager.trackTitle.length > 0))

    property int musicTextPx: Math.round(Theme.fontSizeSmall * _scale)
    // Accent derived from current cover art (dominant color)
    property color mediaAccent: Theme.accentPrimary
    property string mediaAccentCss: Format.colorCss(mediaAccent, 1)
    // Cache of computed accents keyed by cover URL to avoid flicker on track changes
    property var _accentCache: ({})
    // Use the same accent for minus and brackets (simplified)
    // Version bump to force RichText recompute on accent changes
    property int accentVersion: 0
    // Accent readiness: hold accent color until palette is ready
    property bool accentReady: false
    onMediaAccentChanged: { accentVersion++; }
    Component.onCompleted: { colorSampler.requestPaint(); accentRetry.restart() }
    onVisibleChanged: { if (visible) { colorSampler.requestPaint(); accentRetry.restart() } }
    // When cover/album changes, reuse cached accent (if any) to avoid UI flicker while sampling
    Connections {
        target: MusicManager
        function onCoverUrlChanged() {
            try {
                const url = MusicManager.coverUrl || "";
                if (mediaControl._accentCache && mediaControl._accentCache[url]) {
                    mediaControl.mediaAccent = mediaControl._accentCache[url];
                    mediaControl.accentReady = true;
                } // else keep previous accent/color and readiness until sampler updates
            } catch (e) { /* ignore */ }
            colorSampler.requestPaint();
            accentRetry.restart();
        }
        function onTrackAlbumChanged() {
            try {
                const url = MusicManager.coverUrl || "";
                if (mediaControl._accentCache && mediaControl._accentCache[url]) {
                    mediaControl.mediaAccent = mediaControl._accentCache[url];
                    mediaControl.accentReady = true;
                } // else keep previous accent/color and readiness until sampler updates
            } catch (e) { /* ignore */ }
            colorSampler.requestPaint();
            accentRetry.restart();
        }
    }
    // Retry sampler a few times while UI/cover settles
    property int _accentRetryCount: 0
    // Active visualizer profile (if any). Settings are schema-validated, so no clamps here.
    property var _vizProfile: (Settings.settings.visualizerProfiles
                               && Settings.settings.visualizerProfiles[Settings.settings.activeVisualizerProfile])
                              ? Settings.settings.visualizerProfiles[Settings.settings.activeVisualizerProfile]
                              : null
    Timer { id: accentRetry; interval: Theme.mediaAccentRetryMs; repeat: false; onTriggered: { colorSampler.requestPaint(); if (!mediaControl.accentReady && mediaControl._accentRetryCount < Theme.mediaAccentRetryMax) { mediaControl._accentRetryCount++; start() } else { mediaControl._accentRetryCount = 0 } } }
    property color backgroundColor: WidgetBg.color(Settings.settings, "media", "rgba(10, 12, 20, 0.2)")
    readonly property real hoverMixAmount: 0.18
    readonly property color hoverColor: Color.mix(backgroundColor, Qt.rgba(1, 1, 1, 1), hoverMixAmount)
    HoverHandler { id: hoverTracker }

    Rectangle {
        anchors.fill: parent
        radius: Theme.cornerRadiusSmall
        color: hoverTracker.hovered ? hoverColor : backgroundColor
        antialiasing: true
        border.width: Theme.uiBorderWidth
        border.color: Color.withAlpha(Theme.textPrimary, 0.08)
    }

    RowLayout {
        id: mediaRow
        anchors.fill: parent
        anchors.margins: surfacePadding
        spacing: Math.max(4, Math.round(Theme.panelWidgetSpacing * _scale * 0.6))

        // Legacy inline dividers removed due to rendering issues

        Item {
            id: albumArtContainer
            width: capsuleInnerSize
            height: capsuleInnerSize
            Layout.alignment: Qt.AlignVCenter

            Rectangle {
                id: albumArtwork
                width: capsuleInnerSize
                height: capsuleInnerSize
                anchors.centerIn: parent
                color: Theme.surface
                border.color: "transparent"
                border.width: Theme.uiBorderNone
                clip: true
                antialiasing: true
                layer.enabled: true
                layer.smooth: true
                layer.samples: 4

                HiDpiImage {
                    id: cover
                    anchors.fill: parent
                    source: (MusicManager.coverUrl || "")
                    fillMode: Image.PreserveAspectCrop
                    visible: status === Image.Ready
                    onStatusChanged: { if (status === Image.Ready) { colorSampler.requestPaint(); mediaControl._accentRetryCount = 0; accentRetry.restart() } }
                    onSourceChanged: { colorSampler.requestPaint(); mediaControl._accentRetryCount = 0; accentRetry.restart() }
                }

                // Offscreen canvas to sample dominant color from cover art
                Canvas {
                    id: colorSampler
                    width: Theme.mediaAccentSamplerPx; height: Theme.mediaAccentSamplerPx; visible: false
                    onPaint: {
                        try {
                            var ctx = getContext('2d');
                            ctx.clearRect(0, 0, width, height);
                            var url = MusicManager.coverUrl || "";
                            if (!cover.visible) {
                                // If cover isn't ready yet, prefer cached accent (if available) and keep UI steady
                                if (mediaControl._accentCache && mediaControl._accentCache[url]) {
                                    mediaControl.mediaAccent = mediaControl._accentCache[url];
                                    mediaControl.accentReady = true;
                                }
                                return;
                            }
                            ctx.drawImage(cover, 0, 0, width, height);
                            var img = ctx.getImageData(0, 0, width, height);
                            var data = img.data; var len = data.length;
                            var rs=0, gs=0, bs=0, n=0;
                            for (var i=0; i<len; i+=4) {
                                var a = data[i+3]; if (a < 128) continue;
                                var r = data[i], g = data[i+1], b = data[i+2];
                                var maxv = Math.max(r,g,b), minv = Math.min(r,g,b);
                                var sat = maxv - minv; if (sat < 10) continue;
                                var lum = (r+g+b)/3; if (lum < 20 || lum > 235) continue;
                                rs += r; gs += g; bs += b; ++n;
                            }
                            if (n === 0) {
                                rs=0; gs=0; bs=0; n=0;
                                for (var j=0; j<len; j+=4) {
                                    var a2 = data[j+3]; if (a2 < 128) continue;
                                    var r2 = data[j], g2 = data[j+1], b2 = data[j+2];
                                    var max2 = Math.max(r2,g2,b2), min2 = Math.min(r2,g2,b2);
                                    var sat2 = max2 - min2; if (sat2 < 8) continue;
                                    var lum2 = (r2+g2+b2)/3; if (lum2 < 20 || lum2 > 240) continue;
                                    rs += r2; gs += g2; bs += b2; ++n;
                                }
                            }
                            if (n > 0) {
                                var rr = Math.min(255, Math.round(rs/n));
                                var gg = Math.min(255, Math.round(gs/n));
                                var bb = Math.min(255, Math.round(bs/n));
                                var col = Qt.rgba(rr/255.0, gg/255.0, bb/255.0, 1);
                                mediaControl.mediaAccent = col;
                                mediaControl.accentReady = true;
                                // Update cache for this cover
                                if (mediaControl._accentCache) mediaControl._accentCache[url] = col;
                            } else {
                                // Sampling failed; try cached accent for this cover before falling back
                                if (mediaControl._accentCache && mediaControl._accentCache[url]) {
                                    mediaControl.mediaAccent = mediaControl._accentCache[url];
                                    mediaControl.accentReady = true;
                                } else {
                                    mediaControl.mediaAccent = Theme.accentPrimary;
                                    mediaControl.accentReady = false;
                                }
                            }
                        } catch (e) { /* ignore */ }
                    }
                }

                MaterialIcon {
                    id: fallbackIcon
                    anchors.centerIn: parent
                    icon: "music_note"
                    size: Math.max(12, Math.round(capsuleInnerSize * 0.6))
                    color: Color.withAlpha(Theme.textPrimary, Theme.mediaAlbumArtFallbackOpacity)
                    visible: !cover.visible
                }

                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    color: Theme.overlayWeak
                    visible: playButton.containsMouse
                    z: 2
                   MaterialIcon {
                       anchors.centerIn: parent
                       icon: MusicManager.isPlaying ? "pause" : "play_arrow"
                        size: Math.max(12, Math.round(capsuleInnerSize * 0.6))
                       color: Theme.onAccent
                   }
                }

                MouseArea {
                    id: playButton
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    enabled: MusicManager.canPlay || MusicManager.canPause
                    onClicked: MusicManager.playPause()
                }
            }
        }

        
        Item {
            id: trackContainer
            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true
            // Fill row height immediately to avoid post-start drift when text metrics settle
            Layout.fillHeight: true
            // Keep implicit sizes tied to content for layout, but do not bind height to text
            implicitWidth: trackText.implicitWidth
            implicitHeight: mediaControl.height

            

            MouseArea {
                id: trackSidePanelClick
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton
                property real _lastMoveTs: 0
                property bool _armed: false
                onEntered: {
                    _lastMoveTs = Date.now();
                    _armed = true;
                    hoverOpenTimer.restart();
                }
                onExited: {
                    _armed = false;
                    if (hoverOpenTimer.running) hoverOpenTimer.stop();
                }
                onPositionChanged: {
                    _lastMoveTs = Date.now();
                    if (!hoverOpenTimer.running) hoverOpenTimer.restart();
                }
                Timer {
                    id: hoverOpenTimer
                    interval: Theme.mediaHoverOpenDelayMs
                    repeat: false
                    onTriggered: {
                        try {
                            if (!trackSidePanelClick._armed) return;
                            const stillMs = Date.now() - trackSidePanelClick._lastMoveTs;
                            if (stillMs < Theme.mediaHoverStillThresholdMs) { restart(); return; }
                            if (mediaControl.sidePanelPopup && trackText.text && trackText.text.length > 0) {
                                mediaControl.sidePanelPopup.showAt();
                            }
                        } catch (e) { /* ignore */ }
                    }
                }
                onClicked: {
                    try {
                        if (mediaControl.sidePanelPopup) {
                            if (mediaControl.sidePanelPopup.visible) mediaControl.sidePanelPopup.hidePopup();
                            else mediaControl.sidePanelPopup.showAt();
                        }
                    } catch (e) { /* ignore */ }
                }
                cursorShape: Qt.PointingHandCursor
            }

            Text {
                id: titleMeasure
                visible: false
                text: (MusicManager.trackArtist || MusicManager.trackTitle)
                      ? [MusicManager.trackArtist, MusicManager.trackTitle]
                            .filter(function(x){ return !!x; })
                            .join(" — ")
                      : ""
                font.family: Theme.fontFamily
                font.weight: Font.Medium
                font.pixelSize: Theme.fontSizeSmall * Theme.scale(Screen)
            }

            LinearSpectrum {
                id: linearSpectrum
                visible: Settings.settings.showMediaVisualizer === true && MusicManager.isPlaying && (trackText.text && trackText.text.length > 0)
                anchors.left: parent.left
                anchors.top: textFrame.bottom
                anchors.topMargin: -Math.round(trackText.font.pixelSize * (
                    ((_vizProfile && _vizProfile.spectrumOverlapFactor !== undefined)
                        ? _vizProfile.spectrumOverlapFactor
                        : Settings.settings.spectrumOverlapFactor)
                    + ((_vizProfile && _vizProfile.spectrumVerticalRaise !== undefined)
                        ? _vizProfile.spectrumVerticalRaise
                        : Settings.settings.spectrumVerticalRaise)
                ))
                height: Math.round(trackText.font.pixelSize * (
                    (_vizProfile && _vizProfile.spectrumHeightFactor !== undefined)
                        ? _vizProfile.spectrumHeightFactor
                        : Settings.settings.spectrumHeightFactor))
                // Limit spectrum width to the measured title text width
                width: Math.ceil(titleMeasure.width)
                values: MusicManager.cavaValues
                amplitudeScale: 1.0
                barGap: (((_vizProfile && _vizProfile.spectrumBarGap !== undefined)
                           ? _vizProfile.spectrumBarGap
                           : Settings.settings.spectrumBarGap)) * Theme.scale(Screen)
                minBarWidth: 2 * Theme.scale(Screen)
                mirror: ((_vizProfile && _vizProfile.spectrumMirror !== undefined) ? _vizProfile.spectrumMirror : Settings.settings.spectrumMirror)
                drawTop: ((_vizProfile && _vizProfile.showSpectrumTopHalf !== undefined) ? _vizProfile.showSpectrumTopHalf : Settings.settings.showSpectrumTopHalf)
                drawBottom: true
                fillOpacity: ((_vizProfile && _vizProfile.spectrumFillOpacity !== undefined)
                                  ? _vizProfile.spectrumFillOpacity
                                  : (Settings.settings.spectrumFillOpacity !== undefined
                                      ? Settings.settings.spectrumFillOpacity
                                      : Theme.spectrumFillOpacity))
                peakOpacity: Theme.spectrumPeakOpacity
                useGradient: (Settings.settings.visualizerProfiles && Settings.settings.visualizerProfiles[Settings.settings.activeVisualizerProfile] && Settings.settings.visualizerProfiles[Settings.settings.activeVisualizerProfile].spectrumUseGradient !== undefined) ? Settings.settings.visualizerProfiles[Settings.settings.activeVisualizerProfile].spectrumUseGradient : Settings.settings.spectrumUseGradient
                barColor: mediaControl.accentReady ? mediaControl.mediaAccent : Theme.borderSubtle
                z: -1
            }

            // Clip text to avoid overlap with flags; frame reserves space up to mpdSlot
            Item {
                id: textFrame
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.rightMargin: Theme.uiMarginNone
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                clip: true

                

                Text {
                    id: trackText
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    textFormat: Text.RichText
                    renderType: Text.NativeRendering
                    wrapMode: Text.NoWrap
                    // Brackets reuse the same accent as the time markers
                    property string timeColor: (function(){
                        var c = MusicManager.isPlaying ? Theme.textPrimary : Theme.textSecondary;
                        var a = MusicManager.isPlaying ? Theme.mediaTimeAlphaPlaying : Theme.mediaTimeAlphaPaused;
                        return Format.colorCss(c, a);
                    })()
                    property string titlePart: (MusicManager.trackArtist || MusicManager.trackTitle)
                        ? [MusicManager.trackArtist, MusicManager.trackTitle].filter(function(x){return !!x;}).join(" ")
                        : ""
                    // Bind against accent so changes retrigger (same color for minus and brackets)
                    property string _accentCss: (mediaControl.mediaAccentCss ? mediaControl.mediaAccentCss : Format.colorCss(Theme.accentPrimary, 1))
                    property bool _accentReady: mediaControl.accentReady
                    property int _accentVer: mediaControl.accentVersion
                    text: (function(){
                        if (!trackText.titlePart) return "";
                        let _v = trackText._accentVer; // force re-eval when accent changes
                        let t = Rich.esc(trackText.titlePart);
                        const cur = Format.fmtTime(MusicManager.currentPosition || 0);
                        const tot = Format.fmtTime(Time.mprisToMs(MusicManager.trackLength || 0));
                        const bp = Rich.bracketPair(Settings.settings.timeBracketStyle || "square");
                        const ofLabel = qsTr("of");
                        const timeSummary = cur && tot ? (cur + " " + ofLabel + " " + tot) : (cur || tot);
                        if (trackText._accentReady) {
                            return t
                                   + " &#8201;" + Rich.bracketSpan(trackText._accentCss, bp.l)
                                   + Rich.timeSpan(trackText.timeColor, timeSummary)
                                   + Rich.bracketSpan(trackText._accentCss, bp.r);
                        } else {
                            return t
                                   + " &#8201;" + Rich.esc(bp.l)
                                   + Rich.timeSpan(trackText.timeColor, timeSummary)
                                   + Rich.esc(bp.r);
                        }
                    })()
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.weight: Font.Medium
                    font.pixelSize: mediaControl.musicTextPx
                    maximumLineCount: 1
                    z: 2
                }
            }

        }
    }

    

    
}
