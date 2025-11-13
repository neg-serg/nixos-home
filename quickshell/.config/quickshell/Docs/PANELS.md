# Panel Background Transparency / Прозрачность фона панелей

This short doc explains how to control the panels’ background transparency via Settings. Русская версия ниже.

---

## English (EN)

### What it does
- `Bar/Bar.qml` reads two Settings to compute the base panel background alpha.
- Preferred: `panelBgAlphaScale` — a 0..1 multiplier applied to the theme background alpha.
- Fallback: `panelBgAlphaFactor` — a divisor (>0). Example: 5 means “5x more transparent”.

If neither is set, default is `panelBgAlphaScale: 0.2` (≈ five times more transparent).

### How to set
Edit `~/.config/quickshell/Settings.json` (live‑reloads):

```json
{
  "panelBgAlphaScale": 0.2,
  "panelBgAlphaFactor": 0
}
```

Notes:
- You can use either setting, but `panelBgAlphaScale` is preferred.
- The color and original alpha come from `Theme.background`; the scale is applied on top of that.

### Interaction with the wedge shader
- The wedge subtracts from the panel fill. With very transparent panels the wedge appears more subtle. If you want a stronger look, either increase `QS_WEDGE_WIDTH_PCT` or reduce transparency (increase `panelBgAlphaScale`).
- When debugging (`QS_WEDGE_DEBUG=1`), bars may run on `WlrLayer.Overlay`, so the “hole” shows whatever is behind the panel window.
- See `Docs/SHADERS.md` for shader flags and troubleshooting.

### Widget capsules (per-module backgrounds)
- Panel rows are now fully transparent; every widget owns its own rounded capsule.
- Colors come from `Settings.settings.widgetBackgrounds`. Each module looks up its name, then `default`, and finally falls back to `rgba(12, 14, 20, 0.2)` (≈80 % transparent).
- Known keys: `clock`, `workspaces`, `network`, `vpn`, `weather`, `media`, `systemTray`, `volume`, `microphone`, `mpdFlags`. You can add more as new widgets adopt the helper.
- Example:

```json
{
  "widgetBackgrounds": {
    "default": "rgba(10, 12, 20, 0.2)",
    "media": "rgba(15, 18, 30, 0.25)",
    "systemTray": "#201f2dcc"
  }
}
```

Tips:
- Stick to CSS-style colors (`rgba()`, `#rrggbbaa`, `hsl()`).
- Keep base alpha in the 0.15–0.3 range for the requested “mostly transparent” look.
- Capsule padding/height are standardized via `Helpers/CapsuleMetrics.js`; keep using `centerContent: true` on `SmallInlineStat` (and similar helpers) so icons stay vertically centered.
- Prefer the shared `Components/WidgetCapsule.qml` wrapper whenever you add/edit a widget: it already looks up colors via `Helpers/WidgetBg.js`, applies hover tint/borders, and mirrors the capsule metrics. Override `backgroundKey`, `hoverColorOverride`, `paddingScale`, or `verticalPaddingScale` only when a module truly needs different spacing.

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
3. System tray wrapper (rounded capsule around `SystemTray` with hover tint).
4. `Microphone` capsule (conditional on mic service visibility).
5. `Volume` capsule.

Keep this order intact so separators remain unnecessary and hover hot-zones are predictable.

### Network cluster behavior
- The “net cluster” lives on the left bar: `LocalMods.VpnAmneziaIndicator`, `NetworkLinkIndicator`, then `NetworkUsage`.
- `NetworkLinkIndicator` picks a random Material icon from `graph_1`…`graph_7`, `schema`, `family_sharing`, or `family_history` when the bar loads. Tweak the pool via the module’s `iconPool` list if needed.
- Only the icon changes color on failure: warning (`Settings.networkNoInternetColor`) when there is link but no internet; error (`Settings.networkNoLinkColor`) when the physical link drops. Throughput text remains in the neutral color.
- Icon scale/baseline adjustments come from `Theme.network.icon.scale` / `.vAdjust`. The capsule reuses the same hover tint logic as other widgets, so alignment stays consistent.

---

## Русский (RU)

### Что делает
- `Bar/Bar.qml` читает два параметра из Settings для расчёта альфы фона панелей.
- Предпочтительно: `panelBgAlphaScale` — множитель 0..1, умножается на альфу базового цвета темы.
- Фолбэк: `panelBgAlphaFactor` — делитель (>0). Пример: 5 означает «в 5 раз прозрачнее».

Если ничего не задано, по умолчанию используется `panelBgAlphaScale: 0.2` (≈ в 5 раз прозрачнее).

### Как настроить
Отредактируйте `~/.config/quickshell/Settings.json` (перечитывается на лету):

```json
{
  "panelBgAlphaScale": 0.2,
  "panelBgAlphaFactor": 0
}
```

Примечания:
- Можно использовать любой вариант, но предпочтительно `panelBgAlphaScale`.
- Цвет и исходная альфа берутся из `Theme.background`; сверху применяется ваш множитель.

### Связка с шейдером клина
- Клин вычитает заливку панели. При сильной прозрачности панели клин выглядит более «мягко». Чтобы усилить эффект, либо увеличьте ширину клина (`QS_WEDGE_WIDTH_PCT`), либо уменьшите прозрачность панели (увеличьте `panelBgAlphaScale`).
- В отладке (`QS_WEDGE_DEBUG=1`) панели могут работать на слое `WlrLayer.Overlay` — «дырка» будет показывать то, что под окном панели в композиторе.
- За флагами шейдера и диагностикой см. `Docs/SHADERS.md`.

### Капсулы виджетов (фон для каждого модуля)
- Ряды панели теперь полностью прозрачные; каждый виджет рисует свою скруглённую «капсулу».
- Цвета берутся из `Settings.settings.widgetBackgrounds`. Модуль ищет ключ со своим именем, затем `default`, а после — запасной `rgba(12, 14, 20, 0.2)` (≈80 % прозрачности).
- Известные ключи: `clock`, `workspaces`, `network`, `vpn`, `weather`, `media`, `systemTray`, `volume`, `microphone`, `mpdFlags`. Добавляйте новые по мере появления модулей.
- Пример:

```json
{
  "widgetBackgrounds": {
    "default": "rgba(10, 12, 20, 0.2)",
    "media": "rgba(15, 18, 30, 0.25)",
    "systemTray": "#201f2dcc"
  }
}
```

Подсказки:
- Используйте css-цвета (`rgba()`, `#rrggbbaa`, `hsl()`).
- Держите базовую прозрачность в диапазоне 0.15–0.3, чтобы фон выглядел «почти прозрачным», как требуется.
- Паддинги и высота капсул унифицированы через `Helpers/CapsuleMetrics.js`. Указывайте `centerContent: true` в `SmallInlineStat` (и аналогичных помощниках), чтобы иконки оставались по центру.
- Для всех новых/обновлённых модулей используйте общий компонент `Components/WidgetCapsule.qml`: он сам подбирает цвет через `Helpers/WidgetBg.js`, настраивает hover-подсветку, рамку и метрики. Свойства `backgroundKey`, `hoverColorOverride`, `paddingScale`, `verticalPaddingScale` меняйте только если конкретному виджету действительно нужны другие отступы.

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

### Поведение сетевого кластера
- «Нет-кластер» живёт на левой панели: `LocalMods.VpnAmneziaIndicator`, `NetworkLinkIndicator`, затем `NetworkUsage`.
- `NetworkLinkIndicator` при старте случайно выбирает Material-иконку из набора `graph_1`…`graph_7`, `schema`, `family_sharing`, `family_history`. При необходимости скорректируйте список через свойство `iconPool`.
- При проблемах меняется только цвет иконки: warning (`Settings.networkNoInternetColor`), если линк есть, но «интернет не пингуется», и error (`Settings.networkNoLinkColor`), если физический линк пропал. Текст скоростей всегда остаётся нейтральным.
- Масштаб и вертикальный сдвиг иконок задаются `Theme.network.icon.scale` / `.vAdjust`. Капсула использует те же hover-правила, что и остальные виджеты, поэтому выравнивание единообразное.
