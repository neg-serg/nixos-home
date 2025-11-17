# Panel Background Transparency / Прозрачность фона панелей

This short doc explains how to control the panels’ background transparency via Settings. Русская версия ниже.

---

## English (EN)

### What it does
- `Bar/Bar.qml` reads `panelBgAlphaScale` to compute the base panel background alpha. The value (0..1) multiplies the theme background alpha; `0.2` ≈ five times more transparent.

### How to set
Edit `~/.config/quickshell/Settings.json` (live‑reloads):

```json
{
  "panelBgAlphaScale": 0.2
}
```

Notes:
- Higher values darken the bar; lower values make it more transparent.
- The color and original alpha come from `Theme.background`; the scale is applied on top of that.

### Interaction with the wedge shader
- The wedge subtracts from the panel fill. With very transparent panels the wedge appears more subtle. If you want a stronger look, either increase `QS_WEDGE_WIDTH_PCT` or reduce transparency (increase `panelBgAlphaScale`).
- When debugging (`QS_WEDGE_DEBUG=1`), bars may run on `WlrLayer.Overlay`, so the “hole” shows whatever is behind the panel window.
- See `Docs/SHADERS.md` for shader flags and troubleshooting.

### Widget capsules (per-module backgrounds)
- Panel rows are now fully transparent; every widget owns its own rounded capsule.
- Colors come from `Settings.settings.widgetBackgrounds`. Each module looks up its name, then `default`, and finally falls back to `#000000` (fully opaque).
- `Components/WidgetCapsule` now hardcodes the same `#000000` fallback so every capsule (and pill) is solid unless you override the helper or provide per-widget colors.
- Known keys: `clock`, `workspaces`, `network`, `vpn`, `weather`, `media`, `systemTray`, `volume`, `microphone`, `mpdFlags`. You can add more as new widgets adopt the helper.
- Example:

```json
{
  "widgetBackgrounds": {
    "default": "#000000",
    "media": "rgba(15, 18, 30, 0.85)",
    "systemTray": "#201f2dcc"
  }
}
```

Tips:
- Stick to CSS-style colors (`rgba()`, `#rrggbbaa`, `hsl()`).
- Keep base alpha in the 0.7–0.85 range for the requested darker main-panel capsules.
- Capsule padding/height are standardized via `Helpers/CapsuleMetrics.js`. For icon+label widgets prefer `Components/CenteredCapsuleRow.qml`, which already wraps `WidgetCapsule`, centers content, and handles font/icon alignment without custom rows.
- Prefer the shared `Components/WidgetCapsule.qml` wrapper whenever you add/edit a widget: it already looks up colors via `Helpers/WidgetBg.js`, applies borders, and mirrors the capsule metrics. Override `backgroundKey`, `paddingScale`, or `verticalPaddingScale` only when a module truly needs different spacing.
- If the capsule needs click/tap behavior, use `Components/CapsuleButton.qml` (or wrappers like `CenteredCapsuleRow`) instead of hand-written `MouseArea`+`HoverHandler`.
- Audio-level widgets (volume/microphone) must go through `Components/AudioLevelCapsule.qml`; it embeds `PillIndicator`, handles hover/scroll, and collapses cleanly when hidden.
- Inline reveal capsules (system tray hover box, future inline menus) should use `Components/InlineTrayCapsule.qml` so borders/hover/clip settings stay consistent.

### Panel side margins & flush layout
- Both panel windows now read `panelSideMarginPx` from `Settings.json`. If the key is missing, `Theme.panel.sideMargin` (18px by default) is used.
- This single number applies to the left and right bars, so the tray can hug the outer edge without hidden spacers.
- Example:

```json
{
  "panelSideMarginPx": 12
}
```

### Right-row lineup (reference)
Right bar widgets are capsule-based and spacing-free. Left → right order:
1. `Media` capsule (optional, follows `showMediaInBar` and player activity).
2. `LocalMods.MpdFlags` (only when MPD is the active player and Media capsule is visible).
3. System tray wrapper (rounded capsule around `SystemTray`).
4. `Microphone` capsule (conditional on mic service visibility).
5. `Volume` capsule.

Keep this order intact so separators remain unnecessary and hover hot-zones are predictable.

When the right panel hides (monitor removed, bar toggled, etc.), its seam window and separators still disappear in lockstep, but the shader-backed background fill now stays so the translucent plate remains instead of popping away.

### Network cluster behavior
- The “net cluster” on the left bar now uses a single `LocalMods.NetClusterCapsule`: VPN + link icons share the leading slot while throughput text lives in the label lane.
- `NetClusterCapsule` now always uses the Material `lan` glyph for the link status unless you explicitly override `linkIconDefault`. The status fallback icons (`iconConnected`/`iconNoInternet`/`iconDisconnected`) still apply when `useStatusFallbackIcons` is enabled, and VPN glyph swaps are doable via `vpnIconDefault`.
- Only the icon changes color on failure: warning (`Settings.networkNoInternetColor`) when there is link but no internet; error (`Settings.networkNoLinkColor`) when the physical link drops. In the healthy state the link glyph now reuses the accent color so Ethernet activity pops more, while throughput text remains neutral. Use `Helpers/ConnectivityUi.js` to keep formatting/colors consistent across VPN/link/speed modules.
- Spacing between the VPN and ethernet icons uses a dedicated `network.capsule.gapTightenPx` token: we subtract that many pixels from the leading slot spacing and halve it for side margins, so raising the value squeezes both glyphs symmetrically. Adjust `network.capsule.iconHorizontalMargin` (overridden to `0` in Theme) if you want the red pill bounds to hug the glyph even tighter.
- Icon scale/baseline adjustments come from `Theme.network.icon.scale` / `.vAdjust`. Capsule padding/spacing still follow the same Theme tokens, so alignment stays identical even when VPN visibility toggles.

---

## Русский (RU)

### Что делает
- `Bar/Bar.qml` читает `panelBgAlphaScale` из Settings. Значение (0..1) умножает альфу базового цвета темы; `0.2` ≈ в 5 раз прозрачнее.

### Как настроить
Отредактируйте `~/.config/quickshell/Settings.json` (перечитывается на лету):

```json
{
  "panelBgAlphaScale": 0.2
}
```

Примечания:
- Управляйте прозрачностью только через `panelBgAlphaScale`: больше — темнее, меньше — прозрачнее.
- Цвет и исходная альфа берутся из `Theme.background`; сверху применяется ваш множитель.

### Связка с шейдером клина
- Клин вычитает заливку панели. При сильной прозрачности панели клин выглядит более «мягко». Чтобы усилить эффект, либо увеличьте ширину клина (`QS_WEDGE_WIDTH_PCT`), либо уменьшите прозрачность панели (увеличьте `panelBgAlphaScale`).
- В отладке (`QS_WEDGE_DEBUG=1`) панели могут работать на слое `WlrLayer.Overlay` — «дырка» будет показывать то, что под окном панели в композиторе.
- За флагами шейдера и диагностикой см. `Docs/SHADERS.md`.

### Капсулы виджетов (фон для каждого модуля)
- Ряды панели теперь полностью прозрачные; каждый виджет рисует свою скруглённую «капсулу».
- Цвета берутся из `Settings.settings.widgetBackgrounds`. Модуль ищет ключ со своим именем, затем `default`, а после — запасной `#000000` (полностью непрозрачный).
- Общий `Components/WidgetCapsule` теперь жёстко использует тот же `#000000` как запасной цвет, так что капсулы (и pill) сплошные, пока вы явно не переопределите helper или карту.
- Известные ключи: `clock`, `workspaces`, `network`, `vpn`, `weather`, `media`, `systemTray`, `volume`, `microphone`, `mpdFlags`. Добавляйте новые по мере появления модулей.
- Пример:

```json
{
  "widgetBackgrounds": {
    "default": "#000000",
    "media": "rgba(15, 18, 30, 0.85)",
    "systemTray": "#201f2dcc"
  }
}
```

Подсказки:
- Используйте css-цвета (`rgba()`, `#rrggbbaa`, `hsl()`).
- Держите базовую непрозрачность в диапазоне 0.7–0.85, чтобы основной ряд панели выглядел заметно темнее.
- Паддинги и высота капсул унифицированы через `Helpers/CapsuleMetrics.js`. Для типовых «иконка + текст» используйте `Components/CenteredCapsuleRow.qml` — там уже есть `WidgetCapsule`, центрирование и выравнивание по базовой линии, так что индивидуальные Row/FontMetrics не нужны.
- Для всех новых/обновлённых модулей используйте общий компонент `Components/WidgetCapsule.qml`: он сам подбирает цвет через `Helpers/WidgetBg.js`, настраивает hover-подсветку, рамку и метрики. Свойства `backgroundKey`, `hoverColorOverride`, `paddingScale`, `verticalPaddingScale` меняйте только если конкретному виджету действительно нужны другие отступы.
- Нужна кликабельная капсула — начинайте с `Components/CapsuleButton.qml` (или тех, кто его использует), чтобы не размножать `MouseArea`/`TapHandler`.
- Виджеты уровня громкости/микрофона обязаны использовать `Components/AudioLevelCapsule.qml`: внутри уже есть `PillIndicator`, обработка hover/скролла и автосворачивание.
- Для «встроенных» капсул (вроде ховера системного трея) используйте `Components/InlineTrayCapsule.qml`, чтобы фон, рамка и обрезка совпадали с остальными.

### Отступы по краям панели
- Обе панели читают значение `panelSideMarginPx` из `Settings.json`. Если ключ не задан, используется `Theme.panel.sideMargin` (по умолчанию 18 px).
- Одно число применяется и слева, и справа, поэтому трею больше не нужны скрытые распорки, чтобы прижаться к краю экрана.
- Пример:

```json
{
  "panelSideMarginPx": 12
}
```

### Состав правой части панели
Правый ряд виджетов теперь без внешних отступов и полностью на капсулах. Порядок слева направо:
1. Капсула `Media` (опционально, зависит от `showMediaInBar` и активности плеера).
2. `LocalMods.MpdFlags` (показывается только когда активен MPD и виден блок Media).
3. Обёртка системного трея (скруглённая капсула + hover-подсветка вокруг `SystemTray`).
4. Капсула `Microphone` (условно, пока микрофонный модуль хочет отображаться).
5. Капсула `Volume`.

Не меняйте порядок — так не нужны разделители, а рабочие зоны мыши предсказуемы.

Когда правая часть панели скрывается (монитор отключён, панель выключена и т. п.), seam-окно и разделители по‑прежнему убираются синхронно, а шейдерный прямоугольник полупрозрачного фона остаётся на месте, чтобы не было резких скачков визуала.

### Поведение сетевого кластера
- «Нет-кластер» на левой панели теперь рисуется одной `LocalMods.NetClusterCapsule`: иконки VPN и линка делят общий leading-slot, а текст трафика остаётся в центральной метке.
- `NetClusterCapsule` теперь всегда показывает `lan`, если вы явно не переопределили `linkIconDefault`. Резервные иконки состояний (`iconConnected`/`iconNoInternet`/`iconDisconnected`) продолжают использоваться, когда включён `useStatusFallbackIcons`, а VPN‑глиф можно поменять через `vpnIconDefault`.
- При проблемах меняется только цвет иконки: warning (`Settings.networkNoInternetColor`), если линк есть, но «интернет не пингуется», и error (`Settings.networkNoLinkColor`), если физический линк пропал. В норме глиф линка теперь красится в accent, чтобы Ethernet заметнее выделялся, а текст скоростей остаётся нейтральным. Цвета/форматирование вынесены в `Helpers/ConnectivityUi.js`, чтобы VPN/Link/Usage выглядели одинаково.
- Чтобы иконки VPN и Ethernet стояли ближе, заведён отдельный токен `network.capsule.gapTightenPx`: мы вычитаем его из spacing и наполовину — из внешних отступов leading-слота. Чем больше значение, тем плотнее пара; по умолчанию стоит `8`. При необходимости отдельно регулировать ширину красного прямоугольника, меняйте `network.capsule.iconHorizontalMargin` (в теме выставлен `0`).
- Масштаб и вертикальный сдвиг иконок задаются `Theme.network.icon.scale` / `.vAdjust`. Все паддинги и spacing по-прежнему подчиняются Theme, поэтому выключенная VPN-иконка не ломает выравнивание.
