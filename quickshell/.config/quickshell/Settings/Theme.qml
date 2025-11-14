// Theme.qml
pragma Singleton
import QtQuick
import "../Helpers/Utils.js" as Utils
import "../Helpers/Color.js" as Color
import Quickshell
import Quickshell.Io
import qs.Settings

Singleton {
    id: root
    // Set true after Theme.json is loaded/applied at least once
    property bool _themeLoaded: false
    // Per-monitor UI scaling (defaults to 1.0)
    function scale(currentScreen) {
        try {
            const overrides = Settings.settings.monitorScaleOverrides || {};
            if (currentScreen && currentScreen.name && overrides[currentScreen.name] !== undefined) {
                return overrides[currentScreen.name];
            }
        } catch (e) { /* ignore */ }
        return 1.0;
    }

    function applyOpacity(color, opacity) {
        try {
            const c = String(color);
            const op = String(opacity);

            // Validate opacity as 2-digit hex
            if (!/^[0-9a-fA-F]{2}$/.test(op)) {
                return c; // fallback: leave as-is
            }

            // Accept only #RRGGBB or #AARRGGBB; otherwise fallback
            if (/^#[0-9a-fA-F]{6}$/.test(c)) {
                // Insert alpha prefix to make #AARRGGBB
                return "#" + op + c.slice(1);
            }
            if (/^#[0-9a-fA-F]{8}$/.test(c)) {
                // Replace existing leading alpha (assumes #AARRGGBB)
                return "#" + op + c.slice(3);
            }

            // Fallback: return original color unchanged
            return c;
        } catch (e) {
            return color; // conservative fallback
        }
    }

    // Convenience: choose readable text color for a background
    // textOn(bg[, preferLight, preferDark, threshold])
    function textOn(bg, preferLight, preferDark, threshold) {
        try {
            var light = (preferLight !== undefined) ? preferLight : textPrimary;
            var dark  = (preferDark  !== undefined) ? preferDark  : textSecondary;
            var th = (threshold !== undefined && threshold !== null && isFinite(threshold))
                ? Number(threshold) : contrastThreshold;
            return Color.contrastOn(bg, light, dark, th);
        } catch (e) { return textPrimary; }
    }
    
    // FileView to load theme data from JSON file
    FileView {
        id: themeFile
        path: Settings.themeFile
        watchChanges: true
        onFileChanged: reload()
        // After adapter updates (file written/loaded), write and check deprecated tokens
        onAdapterUpdated: {
            writeAdapter();
            try { root._checkDeprecatedTokens(); } catch (e) {}
            root._themeLoaded = true
        }
        onLoadFailed: function(error) {
            if (error.toString().includes("No such file") || error === 2) {
                writeAdapter() // File doesn't exist, create it with default values
            }
        }
        JsonAdapter {
            id: themeData
            // Defaults aligned with Theme.json; file values override these
            // Declare nested group roots so nested tokens in Theme.json are readable
            property var colors: ({})
            property var panel: ({})
            property var shape: ({})
            property var tooltip: ({})
            property var weather: ({})
            property var sidePanel: ({})
            property var ui: ({})
            property var ws: ({})
            property var timers: ({})
            property var network: ({})
            property var media: ({})
            property var spectrum: ({})
            property var time: ({})
            property var calendar: ({})
            property var vpn: ({})
            property var volume: ({})
            property var keyboard: ({})
        }
        
    }

    // Final removal date for flat (legacy) tokens compatibility
    readonly property string flatCompatRemovalDate: "2025-11-01"

    // --- Nested reader helpers (support hierarchical Theme.json with backward-compat) ---
    // Internal cache of tokens we've already warned about (strict mode)
    property var _strictWarned: ({})

    function _getNested(path) {
        try {
            var obj = themeData; var parts = String(path).split('.');
            for (var i=0;i<parts.length;i++) {
                if (!obj) return undefined;
                var k = parts[i];
                obj = obj[k];
            }
            return obj;
        } catch (e) { return undefined }
    }
    function val(path, fallback) {
        var v = _getNested(path);
        if (v !== undefined && v !== null) return v;
        // Strict mode: warn once per missing token, but be quiet for known legacy-compatible paths
        try {
            if (Settings.settings && Settings.settings.strictThemeTokens) {
                var key = String(path);
                // During startup before Theme.json is loaded, do not warn yet
                if (!root._themeLoaded) return fallback;
                // Optional override keys: do not warn when absent
                if (!/^colors\.overrides\./.test(key)) {
                    // Legacy flat-compat mapping: if a corresponding flat key exists, suppress warning
                    var compat = ({
                        'colors.background': 'background',
                        'colors.surface': 'surface',
                        'colors.surfaceVariant': 'surfaceVariant',
                        'colors.text.primary': 'textPrimary',
                        'colors.text.secondary': 'textSecondary',
                        'colors.text.disabled': 'textDisabled',
                        'colors.accent.primary': 'accentPrimary',
                        'colors.status.error': 'error',
                        'colors.status.warning': 'warning',
                        'colors.highlight': 'highlight',
                        'colors.onAccent': 'onAccent',
                        'colors.outline': 'outline',
                        'colors.shadow': 'shadow',
                        'panel.height': 'panelHeight',
                        'panel.sideMargin': 'panelSideMargin',
                        'panel.widgetSpacing': 'panelWidgetSpacing',
                        'panel.icons.iconSize': 'panelIconSize',
                        'panel.icons.iconSizeSmall': 'panelIconSizeSmall',
                        'panel.hotzone.width': 'panelHotzoneWidth',
                        'panel.hotzone.height': 'panelHotzoneHeight',
                        'panel.hotzone.rightShift': 'panelHotzoneRightShift',
                        'panel.moduleHeight': 'panelModuleHeight',
                        'panel.menuYOffset': 'panelMenuYOffset',
                        'shape.cornerRadius': 'cornerRadius',
                        'shape.cornerRadiusSmall': 'cornerRadiusSmall',
                        'shape.cornerRadiusLarge': 'cornerRadiusLarge',
                        'tooltip.delayMs': 'tooltipDelayMs',
                        'tooltip.minSize': 'tooltipMinSize',
                        'tooltip.margin': 'tooltipMargin',
                        'tooltip.padding': 'tooltipPadding',
                        'tooltip.borderWidth': 'tooltipBorderWidth',
                        'tooltip.radius': 'tooltipRadius',
                        'tooltip.fontPx': 'tooltipFontPx',
                        'panel.pill.height': 'panelPillHeight',
                        'panel.pill.iconSize': 'panelPillIconSize',
                        'panel.pill.paddingH': 'panelPillPaddingH',
                        'panel.pill.showDelayMs': 'panelPillShowDelayMs',
                        'panel.pill.autoHidePauseMs': 'panelPillAutoHidePauseMs',
                        'panel.pill.background': 'panelPillBackground',
                        'panel.animations.stdMs': 'panelAnimStdMs',
                        'panel.animations.fastMs': 'panelAnimFastMs',
                        'panel.tray.longHoldMs': 'panelTrayLongHoldMs',
                        'panel.tray.shortHoldMs': 'panelTrayShortHoldMs',
                        'panel.tray.guardMs': 'panelTrayGuardMs',
                        'panel.tray.overlayDismissDelayMs': 'panelTrayOverlayDismissDelayMs',
                        'panel.rowSpacing': 'panelRowSpacing',
                        'panel.rowSpacingSmall': 'panelRowSpacingSmall',
                        'panel.volume.fullHideMs': 'panelVolumeFullHideMs',
                        'panel.volume.lowColor': 'panelVolumeLowColor',
                        'panel.volume.highColor': 'panelVolumeHighColor',
                        'timers.timeTickMs': 'timeTickMs',
                        'timers.wsRefreshDebounceMs': 'wsRefreshDebounceMs',
                        'network.vpnPollMs': 'vpnPollMs',
                        'network.restartBackoffMs': 'networkRestartBackoffMs',
                        'network.linkPollMs': 'networkLinkPollMs',
                        'media.hover.openDelayMs': 'mediaHoverOpenDelayMs',
                        'media.hover.stillThresholdMs': 'mediaHoverStillThresholdMs',
                        'spectrum.peakDecayIntervalMs': 'spectrumPeakDecayIntervalMs',
                        'spectrum.barAnimMs': 'spectrumBarAnimMs',
                        'calendar.rowSpacing': 'calendarRowSpacing',
                        'calendar.cellSpacing': 'calendarCellSpacing',
                        'calendar.sideMargin': 'calendarSideMargin',
                        'panel.hover.fadeMs': 'panelHoverFadeMs',
                        'panel.menu.width': 'panelMenuWidth',
                        'panel.menu.submenuWidth': 'panelSubmenuWidth',
                        'panel.menu.padding': 'panelMenuPadding',
                        'panel.menu.itemSpacing': 'panelMenuItemSpacing',
                        'panel.menu.itemHeight': 'panelMenuItemHeight',
                        'panel.menu.radius': 'panelMenuRadius',
                        'panel.menu.heightExtra': 'panelMenuHeightExtra',
                        'panel.menu.anchorYOffset': 'panelMenuAnchorYOffset',
                        'panel.menu.submenuGap': 'panelSubmenuGap',
                        'panel.menu.chevronSize': 'panelMenuChevronSize',
                        'panel.menu.iconSize': 'panelMenuIconSize'
                    })[key];
                    var hasCompat = compat && (themeData[compat] !== undefined);
                    if (!hasCompat) {
                        if (!root._strictWarned[key]) {
                            console.warn('[ThemeStrict] Missing token', key, '→ using fallback', fallback);
                            root._strictWarned[key] = true;
                        }
                    }
                }
            }
        } catch (e) { /* ignore */ }
        return fallback;
    }

    // --- Deprecated/unused token warnings ---
    function _checkDeprecatedTokens() {
        try {
            if (!(Settings.settings && Settings.settings.strictThemeTokens)) return;
            var deprecated = [
                { path: 'rippleEffect', note: 'Use ui.ripple.opacity' },
                { path: 'accentDisabled', note: 'Use colors.text.disabled / Theme.textDisabled' },
                { path: 'panelHoverOpacity', note: 'Use surfaceHover/surfaceActive for states' },
                { path: 'overlay', note: 'Use colors.overrides.overlayWeak/overlayStrong or derived tokens' },
                { path: 'baseOverlay', note: 'Use colors.overrides.overlayWeak/overlayStrong' }
            ];
            for (var i=0;i<deprecated.length;i++) {
                var d = deprecated[i];
                var v = _getNested(d.path);
                if (v !== undefined && v !== null) {
                    var key = 'dep::' + d.path;
                    if (!root._strictWarned[key]) {
                        console.warn('[ThemeStrict] Deprecated token', d.path, 'present; ' + d.note);
                        root._strictWarned[key] = true;
                    }
                }
            }

            // Flat tokens presence warning (aggregate once)
            var groupRoots = ['colors','panel','shape','tooltip','weather','sidePanel','ui','ws','timers','network','media','spectrum','time','calendar','vpn','volume','keyboard'];
            var ignoreKeys = { objectName: true };
            var flats = [];
            try {
                for (var k in themeData) {
                    if (ignoreKeys[k]) continue;
                    if (groupRoots.indexOf(k) !== -1) continue;
                    var v = themeData[k];
                    var t = typeof v;
                    if (t === 'function' || t === 'undefined') continue;
                    if (t === 'object') continue; // nested groups (already covered)
                    flats.push(k);
                }
            } catch(e) { /* ignore */ }
            if (flats.length > 0) {
                var warnKey = 'flat::detected';
                if (!root._strictWarned[warnKey]) {
                    console.warn('[ThemeStrict] Flat tokens detected in Theme.json:', flats.slice(0,6).join(', '), '…');
                    console.warn('[ThemeStrict] Flat tokens are deprecated and will be removed after', flatCompatRemovalDate, '— migrate to hierarchical tokens. See Docs/ThemeTokens.md#migration-flat-→-nested');
                    root._strictWarned[warnKey] = true;
                }
            }
        } catch (e) { /* ignore */ }
    }

    // Initial deprecated check
    Component.onCompleted: {
        try { root._checkDeprecatedTokens(); } catch (e) {}
    }

        // Map string or numeric to a QML Easing.Type
        function easingType(nameOrCode, fallbackName) {
            try {
                var map = {
                    Linear: Easing.Linear,
                    InQuad: Easing.InQuad,
                    OutQuad: Easing.OutQuad,
                    InOutQuad: Easing.InOutQuad,
                    InCubic: Easing.InCubic,
                    OutCubic: Easing.OutCubic,
                    InOutCubic: Easing.InOutCubic,
                    InSine: Easing.InSine,
                    OutSine: Easing.OutSine,
                    InOutSine: Easing.InOutSine,
                    InBack: Easing.InBack,
                    OutBack: Easing.OutBack,
                    InOutBack: Easing.InOutBack
                };
                if (typeof nameOrCode === 'number') return nameOrCode;
                var s = String(nameOrCode || '');
                if (map[s] !== undefined) return map[s];
                var fb = String(fallbackName || 'OutCubic');
                return map[fb] !== undefined ? map[fb] : Easing.OutCubic;
            } catch (e) {
                return Easing.OutCubic;
            }
        }
    
    // Backgrounds
    property color background: val('colors.background', "#ef000000")
    // Surfaces & Elevation
    property color surface: val('colors.surface', "#181C25")
    property color surfaceVariant: val('colors.surfaceVariant', "#242A35")
    // Text Colors
    property color textPrimary: val('colors.text.primary', "#CBD6E5")
    property color textSecondary: val('colors.text.secondary', "#AEB9C8")
    property color textDisabled: val('colors.text.disabled', "#6B718A")
    // Accent Colors
    property color accentPrimary: val('colors.accent.primary', "#006FCC")
    // Error/Warning
    property color error: val('colors.status.error', "#FF6B81")
    property color warning: val('colors.status.warning', "#FFBB66")
    // Highlights & Focus
    property color highlight: val('colors.highlight', "#94E1F9")
    
    // Additional Theme Properties
    property color onAccent: val('colors.onAccent', "#FFFFFF")
    property color outline: val('colors.outline', "#3B4C5C")
    // Shadows & Overlays
    property color shadow: applyOpacity(val('colors.shadow', "#000000"), "B3")
    
    property string fontFamily: "Iosevka" // Font Properties
    // Font size multiplier - adjust this in Settings.json to scale all fonts
    property real fontSizeMultiplier: Settings.settings.fontSizeMultiplier || 1.0
    // Global contrast threshold used by Color.contrastOn callers
    property real contrastThreshold: (Settings.settings && Settings.settings.contrastThreshold !== undefined)
        ? Settings.settings.contrastThreshold : 0.5
    // Base font sizes (multiplied by fontSizeMultiplier)
    property int fontSizeHeader: Math.round(32 * fontSizeMultiplier)     // Headers and titles
    property int fontSizeBody: Math.round(16 * fontSizeMultiplier)       // Body text and general content
    property int fontSizeSmall: Math.round(14 * fontSizeMultiplier)      // Small text like clock, labels
    property int fontSizeCaption: Math.round(12 * fontSizeMultiplier)    // Captions and fine print

    // Panel metrics (logical)
    property int panelHeight: val('panel.height', 28)
    property int panelSideMargin: val('panel.sideMargin', 18)
    property int panelWidgetSpacing: val('panel.widgetSpacing', 12)
    // Panel icon sizing
    property int panelIconSize: val('panel.icons.iconSize', 24)
    property int panelIconSizeSmall: val('panel.icons.iconSizeSmall', 16)
    // Panel hot-zone
    property int panelHotzoneWidth: val('panel.hotzone.width', 16)
    property int panelHotzoneHeight: val('panel.hotzone.height', 9)
    property real panelHotzoneRightShift: val('panel.hotzone.rightShift', 1.15)
    property int panelModuleHeight: val('panel.moduleHeight', 36)
    property int panelMenuYOffset: val('panel.menuYOffset', 20)
    // Corners
    property int cornerRadius: val('shape.cornerRadius', 8)
    property int cornerRadiusSmall: val('shape.cornerRadiusSmall', 4)
    // Tooltip
    property int tooltipDelayMs: val('tooltip.delayMs', 1500)
    property int tooltipMinSize: val('tooltip.minSize', 20)
    property int tooltipMargin: val('tooltip.margin', 12)
    property int tooltipPadding: val('tooltip.padding', 8)
    property int tooltipBorderWidth: val('tooltip.borderWidth', 1)
    property int tooltipRadius: val('tooltip.radius', 2)
    property int tooltipFontPx: val('tooltip.fontPx', 14)
    property real tooltipOpacity: val('tooltip.opacity', 0.98)
    property real tooltipSmallScaleRatio: val('tooltip.smallScaleRatio', 0.71)
    // Weather tokens
    // Header scale relative to Theme.fontSizeHeader
    property real weatherHeaderScale: val('weather.headerScale', 0.75)
    // Card background opacity atop accentDarkStrong
    property real weatherCardOpacity: val('weather.card.opacity', 0.85)
    // Optional horizontal center offset tweak
    property int weatherCenterOffset:val('weather.centerOffset', -2)
    // Pill indicator defaults
    property int panelPillHeight: val('panel.pill.height', 22)
    property int panelPillIconSize: val('panel.pill.iconSize', 22)
    property int panelPillPaddingH: val('panel.pill.paddingH', 14)
    property int panelPillShowDelayMs: val('panel.pill.showDelayMs', 500)
    property int panelPillAutoHidePauseMs: val('panel.pill.autoHidePauseMs', 2500)
    property color panelPillBackground: val('panel.pill.background', "#000000")
    // Animation timings
    property int panelAnimStdMs: val('panel.animations.stdMs', 250)
    property int panelAnimFastMs: val('panel.animations.fastMs', 200)
    // Tray behavior timings
    property int panelTrayLongHoldMs: val('panel.tray.longHoldMs', 2500)
    property int panelTrayShortHoldMs: val('panel.tray.shortHoldMs', 1500)
    property int panelTrayGuardMs: val('panel.tray.guardMs', 120)
    property int panelTrayOverlayDismissDelayMs: val('panel.tray.overlayDismissDelayMs', 5000)
    // Inline expanded tray background extra padding (unscaled px)
    property int panelTrayInlinePadding: val('panel.tray.inlinePadding', 6)
    // Generic row spacing
    property int panelRowSpacing: val('panel.rowSpacing', 8)
    property int panelRowSpacingSmall: val('panel.rowSpacingSmall', 4)
    // Scale factor for computedFontPx used by small icon/text modules (e.g., network, vpn)
    // Apply global fontSizeMultiplier so inline modules respect user font scaling
    property real panelComputedFontScale: Utils.clamp(val('panel.computedFontScale', 0.6) * fontSizeMultiplier, 0.1, 2.0)
    // Spacing between VPN + NetworkUsage in left cluster
    property int panelNetClusterSpacing: val('panel.netCluster.spacing', 6)
    // Volume behavior
    property int panelVolumeFullHideMs: val('panel.volume.fullHideMs', 800)
    property color panelVolumeLowColor: val('panel.volume.lowColor', "#D62E6E")
    property color panelVolumeHighColor: val('panel.volume.highColor', "#0E6B4D")
    // Volume icon thresholds
    property int volumeIconOffThreshold: val('volume.icon.offThreshold', 0)
    property int volumeIconDownThreshold: val('volume.icon.downThreshold', 30)
    property int volumeIconUpThreshold: val('volume.icon.upThreshold', 50)
    // Volume-specific pill override (falls back to panel.pill.autoHidePauseMs)
    property int volumePillAutoHidePauseMs: val('volume.pill.autoHidePauseMs', panelPillAutoHidePauseMs)
    // Volume-specific show delay override (falls back to panel.pill.showDelayMs)
    property int volumePillShowDelayMs: val('volume.pill.showDelayMs', panelPillShowDelayMs)
    // Core module timings
    property int timeTickMs: val('timers.timeTickMs', 1000)
    property int wsRefreshDebounceMs: val('timers.wsRefreshDebounceMs', 120)
    property int vpnPollMs: val('network.vpnPollMs', 2500)
    property int networkRestartBackoffMs: val('network.restartBackoffMs', 1500)
    property int networkLinkPollMs: val('network.linkPollMs', 4000)
    property int mediaHoverOpenDelayMs: val('media.hover.openDelayMs', 320)
    property int mediaHoverStillThresholdMs: val('media.hover.stillThresholdMs', 180)
    property int spectrumPeakDecayIntervalMs: val('spectrum.peakDecayIntervalMs', 50)
    property int spectrumBarAnimMs: val('spectrum.barAnimMs', 100)
    property int spectrumPeakThickness: val('spectrum.peakThickness', 2)
    property real spectrumBarGap: val('spectrum.barGap', 2)
    property real spectrumMinBarWidth: val('spectrum.minBarWidth', 2)
    property int musicPositionPollMs: val('timers.musicPositionPollMs', 1000)
    property int musicPlayersPollMs: val('timers.musicPlayersPollMs', 5000)
    property int musicMetaRecalcDebounceMs: val('timers.musicMetaRecalcDebounceMs', 80)
    // Calendar metrics
    property int calendarRowSpacing: val('calendar.rowSpacing', 2)
    property int calendarCellSpacing: val('calendar.cellSpacing', 2)
    property int calendarSideMargin: val('calendar.sideMargin', 2)
    // Side-panel popup timings/margins
    property int sidePanelPopupSlideMs:val('sidePanel.popup.slideMs', 220)
    property int sidePanelPopupAutoHideMs:val('sidePanel.popup.autoHideMs', 4000)
    property int sidePanelPopupOuterMargin:val('sidePanel.popup.outerMargin', 4)
    // Side-panel popup spacing (between inner items)
    property int sidePanelPopupSpacing:val('sidePanel.popup.spacing', 0)
    // Side-panel popup corner radius
    property int sidePanelPopupRadius: val('sidePanel.popup.radius', cornerRadius)

    // Media dominant-accent sampler/logic (extract hardcoded tuning)
    property int mediaAccentSamplerPx: val('media.accent.samplerPx', 48)
    property int mediaAccentRetryMs: val('media.accent.retryMs', 120)
    property int mediaAccentRetryMax: val('media.accent.retryMax', 5)
    // Strict pass thresholds
    property int mediaAccentSatMin: val('media.accent.satMin', 10)
    property int mediaAccentLumMin: val('media.accent.lumMin', 20)
    property int mediaAccentLumMax: val('media.accent.lumMax', 235)
    // Relaxed pass thresholds
    property int mediaAccentSatRelax: val('media.accent.relaxed.satMin', 8)
    property int mediaAccentLumRelaxMin: val('media.accent.relaxed.lumMin', 20)
    property int mediaAccentLumRelaxMax: val('media.accent.relaxed.lumMax', 240)
    // Side-panel button hover rectangle visibility guard
    property real sidePanelButtonActiveVisibleMin: val('sidePanel.button.activeVisibleMin', 0.18)
    // Side-panel spacing medium
    property int sidePanelSpacingMedium:val('sidePanel.spacingMedium', 8)
    // Hover behavior
    property int panelHoverFadeMs:val('panel.hover.fadeMs', 120)
    // Panel menu metrics
    property int panelMenuWidth:val('panel.menu.width', 180)
    property int panelSubmenuWidth:val('panel.menu.submenuWidth', 180)
    property int panelMenuPadding:val('panel.menu.padding', 4)
    property int panelMenuItemSpacing:val('panel.menu.itemSpacing', 2)
    property int panelMenuItemHeight:val('panel.menu.itemHeight', 26)
    property int panelMenuRadius:val('panel.menu.radius', 0)
    property int panelMenuItemRadius:val('panel.menu.itemRadius', 0)
    property int panelMenuHeightExtra:val('panel.menu.heightExtra', 12)
    property int panelMenuAnchorYOffset:val('panel.menu.anchorYOffset', 4)
    property int panelSubmenuGap:val('panel.menu.submenuGap', 12)
    property int panelMenuChevronSize:val('panel.menu.chevronSize', 15)
    property int panelMenuIconSize:val('panel.menu.iconSize', 16)
    // Panel menu item font scale (relative to Theme.fontSizeSmall)
    property real panelMenuItemFontScale: val('panel.menu.itemFontScale', 0.90)
    // Panel capsule border defaults
    property real panelCapsuleBorderOpacity: val('panel.capsule.borderOpacity', 0.08)
    property int panelCapsuleBorderWidth: val('panel.capsule.borderWidth', uiBorderWidth)
    property real panelCapsuleBorderInset: val('panel.capsule.borderInset', -panelCapsuleBorderWidth)
    property color panelCapsuleBorderColor: {
        const overrideColor = val('panel.capsule.borderColor', undefined)
        return overrideColor !== undefined
            ? overrideColor
            : Color.withAlpha(textPrimary, panelCapsuleBorderOpacity)
    }
    // Side panel exports
    property int sidePanelCornerRadius: val('sidePanel.cornerRadius', 9)
    property int sidePanelSpacing: val('sidePanel.spacing', 12)
    property int sidePanelSpacingTight: val('sidePanel.spacingTight', 6)
    property int sidePanelSpacingSmall: val('sidePanel.spacingSmall', 4)
    property int sidePanelAlbumArtSize: val('sidePanel.albumArtSize', 200)
    // Inner blocks radius for side panel cards/sections
    property int sidePanelInnerRadius: val('sidePanel.innerRadius', 0)
    // Hover background radius factor for side panel buttons (0..1 of height)
    property real sidePanelButtonHoverRadiusFactor: val('sidePanel.buttonHoverRadiusFactor', 0.5)
    // Side panel selector minimal width
    property int sidePanelSelectorMinWidth: val('sidePanel.selector.minWidth', 120)
    property int sidePanelWeatherWidth: val('sidePanel.weather.width', 440)
    property int sidePanelWeatherHeight: val('sidePanel.weather.height', 180)
    property real sidePanelWeatherLeftColumnRatio: val('sidePanel.weather.leftColumnRatio', 0.32)
    property int uiIconSizeLarge: val('ui.iconSizeLarge', 28)
    // Overlay radius and larger corner
    property int panelOverlayRadius: val('panel.overlayRadius', 20)
    property int cornerRadiusLarge: val('shape.cornerRadiusLarge', 12)
    // Generic UI spacings/margins
    property int uiMarginLarge: val('ui.margin.large', 32)
    property int uiMarginMedium: val('ui.margin.medium', 16)
    property int uiPaddingMedium: val('ui.padding.medium', 14)
    property int uiSpacingLarge: val('ui.spacing.large', 18)
    property int uiSpacingSmall: val('ui.spacing.small', 10)
    property int uiSpacingXSmall: val('ui.spacing.xsmall', 2)
    property int uiGapTiny: val('ui.gap.tiny', 1)
    property int uiControlHeight: val('ui.control.height', 48)
    // UI shadows (used by text overlays, etc.)
    property real uiShadowOpacity: val('ui.shadow.opacity', 0.6)
    property real uiShadowBlur: val('ui.shadow.blur', 0.8)
    property int uiShadowOffsetX: val('ui.shadow.offsetX', 0)
    property int uiShadowOffsetY: val('ui.shadow.offsetY', 1)
    // UI border thickness
    property int uiBorderWidth: val('ui.border.width', 1)
    // UI small-visibility epsilon for hover fades, etc.
    property real uiVisibilityEpsilon: val('ui.visibilityEpsilon', 0.01)
    // UI "none" tokens for consistency
    property int uiMarginNone: val('ui.margin.none', 0)
    property int uiSpacingNone: val('ui.spacing.none', 0)
    property int uiBorderNone: val('ui.border.noneWidth', 0)
    property int uiRadiusNone: val('ui.radius.none', 0)
    // UI common opacities
    property real uiRippleOpacity: val('ui.ripple.opacity', 0.18)
    property real uiIconEmphasisOpacity: val('ui.icon.emphasisOpacity', 0.9)
    // Workspace indicator tuning
    property int wsIconSpacing:val('ws.icon.spacing', 1)
    // Optional overrides for submap icon mapping
    property var wsSubmapIconOverrides:(function(){ var v = val('ws.submap.icon.overrides', undefined); return (v && typeof v === 'object') ? v : ({}); })()
    // Color of the submap icon
    property color wsSubmapIconColor: val('ws.submap.icon.color', accentPrimary)
    // Workspace label/icon paddings
    // Values validated by ThemeConstraints in tooling
    property int wsLabelPadding:val('ws.label.padding', 6)
    property int wsLabelLeftPadding:val('ws.label.leftPadding.normal', 2)
    property int wsLabelLeftPaddingTerminal:val('ws.label.leftPadding.terminal', -2)
    property int wsIconInnerPadding:val('ws.icon.innerPadding', 1)
    // NetworkUsage icon tuning
    property real networkIconScale: val('network.icon.scale', 2.0)
    // Dedicated link indicator icon tuning
    property real networkLinkIconScale: val('network.link.icon.scale', 1.0)
    // VPN indicator opacities
    property real vpnConnectedOpacity: val('vpn.connectedOpacity', 0.8)
    property real vpnDisconnectedOpacity: val('vpn.disconnectedOpacity', 0.45)
    // VPN icon/layout tuning and accent mix
    property real vpnIconScale: val('vpn.icon.scale', 1.0)
    property real vpnAccentSaturateBoost: val('vpn.accent.saturateBoost', 0.12)
    property real vpnAccentLightenTowardWhite: val('vpn.accent.lightenTowardWhite', 0.20)
    property real vpnDesaturateAmount: val('vpn.desaturateAmount', 0.45)
    // UI animation timings
    property int uiAnimQuickMs: val('ui.anim.quickMs', 120)
    property int uiAnimRotateMs: val('ui.anim.rotateMs', 160)
    property int uiAnimRippleMs: val('ui.anim.rippleMs', 320)
    // UI spinner
    property int uiSpinnerDurationMs: val('ui.spinner.durationMs', 1000)
    // Media emphasis scaling for icons
    property real mediaIconScaleEmphasis: val('media.iconScaleEmphasis', 1.15)
    // MPD flags
    property real mpdFlagsIconScale: val('media.mpd.flags.iconScale', 0.95)
    // Media album art fallback icon opacity
    property real mediaAlbumArtFallbackOpacity: val('media.albumArt.fallbackOpacity', 0.4)
    // Media time alphas
    property real mediaTimeAlphaPlaying: val('media.time.alpha.playing', 1.0)
    property real mediaTimeAlphaPaused: val('media.time.alpha.paused', 0.8)
    // MPD flags polling (fallback interval)
    property int mpdFlagsFallbackMs: val('media.mpd.flags.fallbackMs', 2500)
    // Time/Clock module
    property real timeFontScale: val('time.font.scale', 1.0)
    property int timeFontWeight:val('time.font.weight', Font.Medium)
    property color timeTextColor: val('time.text.color', textPrimary)
    // Keyboard layout module
    property int keyboardHeight:val('keyboard.height', panelHeight)
    property int keyboardMargin:val('keyboard.margin', 4)
    property int keyboardMinWidth:val('keyboard.minWidth', 40)
    property real keyboardIconScale: val('keyboard.icon.scale', 1.0)
    property int keyboardIconSpacing:val('keyboard.icon.spacing', 4)
    property int keyboardIconPadding:val('keyboard.icon.padding', 4)
    property real keyboardTextPadding: val('keyboard.text.padding', 1.5)
    property real keyboardFontScale: val('keyboard.font.scale', 0.9)
    property int keyboardRadius:val('keyboard.radius', cornerRadiusSmall)
    // Keyboard opacity + text emphasis
    property real keyboardNormalOpacity: val('keyboard.opacity.normal', 1.0)
    property real keyboardHoverOpacity: val('keyboard.opacity.hover', 1.0)
    property bool keyboardTextBold: !!val('keyboard.text.bold', false)
    // Keyboard colors
    property color keyboardBgColor: val('keyboard.colors.bg', background)
    property color keyboardHoverBgColor: val('keyboard.colors.hoverBg', surfaceHover)
    property color keyboardTextColor: val('keyboard.colors.text', textPrimary)
    property color keyboardIconColor: val('keyboard.colors.icon', textSecondary)
    // UI easing (configurable via string names)
    property int uiEasingQuick: easingType(val('ui.anim.easing.quick', 'OutQuad'), 'OutQuad')
    property int uiEasingRotate: easingType(val('ui.anim.easing.rotate', 'OutCubic'), 'OutCubic')
    property int uiEasingRipple: easingType(val('ui.anim.easing.ripple', 'InOutCubic'), 'InOutCubic')
    property int uiEasingStdOut: easingType(val('ui.anim.easing.stdOut', 'OutCubic'), 'OutCubic')
    property int uiEasingStdIn: easingType(val('ui.anim.easing.stdIn', 'InCubic'), 'InCubic')
    property int uiEasingInOut: easingType(val('ui.anim.easing.inOut', 'InOutQuad'), 'InOutQuad')
    // Calendar popup sizing
    property int calendarWidth: val('calendar.size.width', 280)
    property int calendarHeight: val('calendar.size.height', 320)
    property int calendarPopupMargin: val('calendar.popupMargin', 2)
    property int calendarBorderWidth: val('calendar.borderWidth', 1)
    property int calendarCellSize: val('calendar.cellSize', 28)
    property int calendarHolidayDotSize: val('calendar.holidayDotSize', 3)
    // Calendar explicit spacings/margins
    property int calendarDowSpacing: val('calendar.dow.spacing', 0)
    property int calendarDowSideMargin: val('calendar.dow.sideMargin', 0)
    property int calendarGridSpacing: val('calendar.grid.spacing', 0)
    // Calendar font sizes (logical px before per-screen scaling)
    property int calendarTitleFontPx: val('calendar.font.titlePx', 18)
    property int calendarDowFontPx: val('calendar.font.dowPx', 15)
    property int calendarDayFontPx: val('calendar.font.dayPx', 24)
    // Calendar DOW styles
    property bool calendarDowItalic: val('calendar.dow.italic', true)
    property bool calendarDowUnderline: val('calendar.dow.underline', true)
    // Calendar shape factors
    property real calendarCellRadiusFactor: val('calendar.cell.radiusFactor', 0.33)
    property real calendarHolidayDotRadiusFactor: val('calendar.holidayDot.radiusFactor', 0.5)
    // Calendar opacities
    property real calendarTitleOpacity: val('calendar.opacity.title', 0.7)
    property real calendarDowOpacity: val('calendar.opacity.dow', 0.9)
    property real calendarOtherMonthDayOpacity: val('calendar.opacity.otherMonthDay', 0.3)
    // Tunable factor for dark accent on calendar highlights (today/selected/hover)
    property real calendarAccentDarken: val('calendar.accentDarken', 0.8)
    // Spectrum opacities
    property real spectrumFillOpacity: val('spectrum.fillOpacity', 0.35)
    property real spectrumPeakOpacity: val('spectrum.peakOpacity', 0.7)
    // Derived accent/surface/border tokens (formula-based)
    // Keep simple and perceptually stable; expose tokens for reuse
    // Each derived token may be overridden by matching *Override property in Theme.json
    property color accentHover: (val('colors.overrides.accentHover', themeData.accentHoverOverride) !== undefined)
        ? val('colors.overrides.accentHover', themeData.accentHoverOverride) : Color.towardsWhite(accentPrimary, 0.2)
    property color accentActive: (val('colors.overrides.accentActive', themeData.accentActiveOverride) !== undefined)
        ? val('colors.overrides.accentActive', themeData.accentActiveOverride) : Color.towardsBlack(accentPrimary, 0.2)
    property color accentDarkStrong: (val('colors.overrides.accentDarkStrong', themeData.accentDarkStrongOverride) !== undefined)
        ? val('colors.overrides.accentDarkStrong', themeData.accentDarkStrongOverride) : Color.towardsBlack(accentPrimary, 0.8)
    property color surfaceHover: (val('colors.overrides.surfaceHover', themeData.surfaceHoverOverride) !== undefined)
        ? val('colors.overrides.surfaceHover', themeData.surfaceHoverOverride) : Color.withAlpha(textPrimary, 0.06)
    property color surfaceActive: (val('colors.overrides.surfaceActive', themeData.surfaceActiveOverride) !== undefined)
        ? val('colors.overrides.surfaceActive', themeData.surfaceActiveOverride) : Color.withAlpha(textPrimary, 0.10)
    property color borderSubtle: (val('colors.overrides.borderSubtle', themeData.borderSubtleOverride) !== undefined)
        ? val('colors.overrides.borderSubtle', themeData.borderSubtleOverride) : Color.withAlpha(textPrimary, 0.15)
    property color borderStrong: (val('colors.overrides.borderStrong', themeData.borderStrongOverride) !== undefined)
        ? val('colors.overrides.borderStrong', themeData.borderStrongOverride) : Color.withAlpha(textPrimary, 0.30)
    property color overlayWeak: (val('colors.overrides.overlayWeak', themeData.overlayWeakOverride) !== undefined)
        ? val('colors.overrides.overlayWeak', themeData.overlayWeakOverride) : Color.withAlpha(shadow, 0.08)
    property color overlayStrong: (val('colors.overrides.overlayStrong', themeData.overlayStrongOverride) !== undefined)
        ? val('colors.overrides.overlayStrong', themeData.overlayStrongOverride) : Color.withAlpha(shadow, 0.18)
}
