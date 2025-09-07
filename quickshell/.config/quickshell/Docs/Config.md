Quickshell Configuration: Settings.json and Theme.json options

Locations
- `~/.config/quickshell/Settings.json`: behavioral and global settings.
- `~/.config/quickshell/Theme.json`: theme tokens (colors, sizes, animation, etc.).
- Base directory is `${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/`. Files are created on first run with defaults.

Format
- Both files are JSON. Values in files override built‑in defaults.

Settings.json (all options)

General
- weatherCity: string, default "Moscow". City used by the weather widget.
- userAgent: string, default "NegPanel". HTTP User‑Agent; include app name and contact if possible.
- profileImage: string path, default `$HOME/.face`. User avatar.
- debugLogs: boolean, default false. Enables low‑importance debug logs.
- debugNetwork: boolean, default false. Extra logging for network layer.
- strictThemeTokens: boolean, default false. Strict warnings for missing/deprecated Theme tokens (see ThemeTokens.md).

Date & Time
- use12HourClock: boolean, default false. 12‑hour time in the bar.
- reverseDayMonth: boolean, default false. Flip day and month order in date.
- useFahrenheit: boolean, default false. Use °F for temperatures.

UI & Typography
- dimPanels: boolean, default true. Dim panels appearance.
- fontSizeMultiplier: number, default 1.0. Global font multiplier (e.g. 1.2 = +20%).

Bar/Widgets
- showMediaInBar: boolean, default false. Show the media block in the bar.
- showWeatherInBar: boolean, default false. Show weather button in the bar.
- collapseSystemTray: boolean, default true. Collapse tray icons.
- collapsedTrayIcon: string, default "expand_more". Icon when tray is collapsed (Material icon name).
- trayFallbackIcon: string, default "broken_image". Fallback tray icon name.
- trayAccentColor: color string, default "#3b7bb3". Tray button/icon accent color.
- trayPopupDarkness: number 0..1, default 0.65. Darkness blend for tray popups.
- trayAccentBrightness: number 0..1, default 0.25. Accent brightness relative to calendar accent.

Monitors & Scaling
- barMonitors: string array, default []. Which monitors show the bar (optional; otherwise automatic).
- dockMonitors: string array, default []. Monitors for dock (if used).
- monitorScaleOverrides: object { "ScreenName": number }, default {}. Per‑monitor UI scale keyed by `Screen.name`.

Media & Visualizer
- showMediaVisualizer: boolean, default false. Enable visualizer (spectrum) next to track.
- visualizerType: string, default "radial". Visualizer type identifier (reserved; current UI uses linear spectrum).
- activeVisualizerProfile: string, default "classic". Active visualizer profile name.
- visualizerProfiles: object of profiles keyed by name. Each profile can override CAVA/spectrum parameters below.
- timeBracketStyle: string, default "round". Brackets for RichText: round|square|lenticular|lenticular_black|angle|tortoise.
- mediaTitleSeparator: string, default "—". Separator between artist and title.

CAVA / Spectrum (global defaults; each may be overridden per profile in visualizerProfiles.<name>)
- cavaBars: integer, default 86. Number of bars.
- cavaFramerate: integer, default 24. Frames per second.
- cavaMonstercat: boolean, default false. Monstercat smoothing.
- cavaGravity: integer, default 150000. Gravity/decay constant.
- cavaNoiseReduction: integer, default 12. Noise reduction level.
- spectrumUseGradient: boolean, default false. Gradient fill.
- spectrumMirror: boolean, default false. Mirror spectrum.
- showSpectrumTopHalf: boolean, default false. Show top half only.
- spectrumFillOpacity: number 0..1, default 0.35. Fill opacity.
- spectrumHeightFactor: number, default 1.2. Height relative to track text size.
- spectrumOverlapFactor: number 0..1, default 0.2. Overlap on top of text.
- spectrumBarGap: number, default 1.0. Gap between bars (logical px before per‑screen scale).
- spectrumVerticalRaise: number, default 0.75. Vertical offset relative to text.

Music Players
- pinnedPlayers: string array, default []. Pinned players (priority).
- ignoredPlayers: string array, default []. Players to ignore.
- playerSelectionPriority: string array, default ["mpdPlaying","anyPlaying","mpdRecent","recent","manual","first"]. Selection algorithm priority.
- playerSelectionPreset: string, default "default". Preset name for priority ordering.

Media side panel popup
- musicPopupWidth: integer, default 840. Width (logical px; scaled per monitor).
- musicPopupHeight: integer, default 250. Height (logical px; used when content doesn’t define height).
- musicPopupPadding: integer, default 12. Inner padding (logical px).

Contrast & Accessibility
- contrastThreshold: number, default 0.5. Threshold for light/dark text selection against backgrounds.
- enforceContrastWarnings: boolean, default false. Stronger warnings for low contrast.
- debugContrast: boolean, default false. Contrast calculation debug.
- contrastWarnRatio: number, default 4.5. Target contrast ratio for warnings.

Network
- networkPingIntervalMs: integer, default 30000. Network/ping refresh interval.
- networkNoInternetColor: color string, default "#FF6E00". No‑internet status color.
- networkNoLinkColor: color string, default "#D81B60". No‑link status color.

Weather
- showWeatherInBar: boolean, default false. Weather button in bar.
- useFahrenheit: boolean, default false. Show °F.
- weatherCity: string. City for current weather and forecast.

Visualizer profiles notes
- visualizerProfiles is a dictionary of user profiles. Supported fields per profile:
  - cavaBars, cavaFramerate, cavaMonstercat, cavaGravity, cavaNoiseReduction
  - spectrumFillOpacity, spectrumHeightFactor, spectrumOverlapFactor
  - spectrumBarGap, spectrumVerticalRaise, spectrumMirror
  Any field not defined in a profile falls back to the global value.

Theme.json (short)
- All typography, colors, paddings, radii, animations, etc. are hierarchical tokens.
- Full list of tokens, types/defaults, and guidance: `Docs/ThemeTokens.md`.
- Up‑to‑date example schema: `Docs/ThemeHierarchical.json`.
- Important groups: `colors.*`, `panel.*`, `shape.*`, `tooltip.*`, `ui.*`, `ws.*`, `timers.*`, `network.*`, `media.*`, `spectrum.*`, `calendar.*`, `weather.*`, `vpn.*`, `time.*`, `keyboard.*`, `volume.*`, `sidePanel.*`.
- Strict mode (`Settings.settings.strictThemeTokens = true`) logs warnings for missing tokens and deprecated flat keys. Flat keys are removed after 2025‑11‑01.

Tools
- Validate theme: `node Tools/validate-theme.mjs [--theme Theme.json] [--schema Docs/ThemeHierarchical.json] [--strict]`.
- Generate theme schema: `node Tools/generate-theme-schema.mjs` (updates `Docs/ThemeHierarchical.json`).
- Validate settings: `node Tools/validate-settings.mjs [--settings ~/.config/quickshell/Settings.json] [--schema Docs/SettingsSchema.json]`.

Settings.json schema and samples
- JSON Schema: `Docs/SettingsSchema.json` (Draft‑07) — types, defaults, and allowed values.
- Preset examples:
  - `Docs/SettingsMinimal.json` — minimal typical overrides.
  - `Docs/SettingsVisualizerSoft.json` — a soft visualizer profile and activation.

Подсказки
- Значения цветов — строка в формате `#RRGGBB` или `#AARRGGBB`.
- Целые величины — логические пиксели до масштабирования экрана; в рантайме масштабируются функцией `Theme.scale(Screen)` и пер‑мониторными настройками.
- Если не уверены в конкретном токене темы — ищите его использование в `Settings/Theme.qml` и документации `Docs/ThemeTokens.md`.
