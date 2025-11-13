# Quickshell Shaders and Wedge Clip

This document summarizes how shaders are used in this Quickshell setup, how the subtractive triangular "wedge" clip works, and how to build and debug the shaders.

---

## Русский (RU)

### Обзор

- Используется Qt 6 `ShaderEffect` с заранее скомпилированными `.qsb` шейдерами.
- Основная задача — вычесть треугольный клин ("wedge") из краёв левой/правой панелей, чтобы через отверстие было видно «шов» по центру.
- Все `.frag` источники собираются в `.qsb` с помощью `qsb` (пакет `qt6.qtshadertools`).

### Файлы

- Шейдер клипа: `shaders/wedge_clip.frag` (+ собранный `shaders/wedge_clip.frag.qsb`)
- Встроенные шейдеры шва/тоновки: `shaders/seam*.frag(.qsb)`, `shaders/panel_tint_mix.frag(.qsb)`, `shaders/diag.frag(.qsb)`
- Скрипт сборки: `scripts/compile_shaders.sh`
- Интеграция: `Bar/Bar.qml`

### Сборка шейдеров

1) Установить инструменты: `nix shell nixpkgs#qt6.qtshadertools`  
2) Из каталога `~/.config/quickshell` запустить:  
   ```bash
   nix shell nixpkgs#qt6.qtshadertools -c bash -lc 'scripts/compile_shaders.sh'
   ```

Примечания:

- Qt 6 требует предварительной компиляции в формат `.qsb`. Прямые пути на `.frag` больше не поддерживаются.
- Скрипт собирает все `*.frag` → `*.frag.qsb` для GLSL профилей `100es,120,150`.

### Параметры шейдера клипа (wedge_clip.frag)

Буфер `qt_ubuf` содержит 3 вектора `vec4` с параметрами:

- `params0` — `x` ширина клина в долях ширины (0..1), `y` направление диагонали (slopeUp: 1 ↑, 0 ↓), `z` сторона клина (`+1` у правого края, `-1` у левого), `w` — не используется.
- `params1` — `x` перо/растушёвка границы (0..~0.25), `yzw` — не используются.
- `params2` — отладка: `x` — непрозрачность мадженты внутри клина, `y` — принудительное рисование мадженты поверх всего прямоугольника (проверка, что сам `ShaderEffect` вообще отрисовывается).

Семплер `sourceSampler` — это исходное содержимое (цветная заливка панели или оверлей‑тинт), которое клипуется шейдером.

### Включение/отладка (переменные окружения)

- `QS_ENABLE_WEDGE_CLIP=1` — включить путь шейдера клипа.
- `QS_WEDGE_WIDTH_PCT=NN` — ширина клина в процентах (0..100). Если не задано, берётся от геометрии `seamPanel.seamWidthPx`.
- `QS_WEDGE_DEBUG=1` — включает отладочные оверлеи (Canvas‑клины поверх панелей и маджента внутри клипа).
- `QS_WEDGE_SHADER_TEST=1` — шейдер рисует мадженту по всей области эффекта (проверка, что сам ShaderEffect виден на экране).
- `QS_WEDGE_TINT_TEST=1` — поверх содержимого панелей рисуются полупрозрачные прямоугольники (подтверждение, что окна панелей вообще видимы).

Дополнительно в `Settings.json` есть флаги для наклона диагонали:

- `debugTriangleLeftSlopeUp`, `debugTriangleRightSlopeUp` — задают направление диагонали слева/справа.

### Интеграция в QML (вкратце)

- В `Bar/Bar.qml` для левой и правой панели используются `Loader` с `ShaderEffect`, где подключён `../shaders/wedge_clip.frag.qsb`.
- Источник (`sourceSampler`) — `ShaderEffectSource` от прямоугольника заливки панели или тинта.
- При активном шейдере скрываютсяfallback‑маски `OpacityMask` (чтобы не перекрывать результат шейдера).
- На время отладки (при `QS_WEDGE_DEBUG=1`) панели переводятся на слой `WlrLayer.Overlay`, чтобы исключить перекрытия композитора.

### Диагностика «клин не виден»

1) Сначала проверить сборку: нет ли в логах Qt предупреждения про «Failed to find shader … .qsb».  
2) Запустить с жёсткими флагами:  
   ```bash
   QS_ENABLE_WEDGE_CLIP=1 QS_WEDGE_DEBUG=1 QS_WEDGE_SHADER_TEST=1 qs
   ```
   Должна появиться маджента поверх клипа на обеих панелях. Если нет — проблема со стеком слоёв/видимостью окна.
3) Проверить видимость окон панелей:  
   ```bash
   QS_ENABLE_WEDGE_CLIP=1 QS_WEDGE_DEBUG=1 QS_WEDGE_TINT_TEST=1 qs
   ```
   Должны появиться сплошные полупрозрачные подсветки поверх панелей.
4) Если ShaderEffect виден, но треугольник не «вырезается», увеличить ширину: `QS_WEDGE_WIDTH_PCT=60` (или 80) и сменить наклон в `Settings.json`.

### Ограничения/заметки

- Миграция на чистый шейдер‑путь: после успешной верификации можно удалить старые Canvas/OpacityMask‑fallback.
- Производительность: эффекты работают поверх панелей; все источники идут через `ShaderEffectSource` (live, recursive), что имеет накладные расходы — держать логи включенными только на отладку.

---

## English (EN)

### Overview

- Uses Qt 6 `ShaderEffect` with precompiled `.qsb` shaders.
- Goal: subtract a triangular wedge from the left/right bar faces so the central seam shows through.
- All `.frag` sources are compiled to `.qsb` via `qsb` (Qt Shader Tools).

### Files

- Clip shader: `shaders/wedge_clip.frag` (+ compiled `shaders/wedge_clip.frag.qsb`)
- Seam/tint helpers: `shaders/seam*.frag(.qsb)`, `shaders/panel_tint_mix.frag(.qsb)`, `shaders/diag.frag(.qsb)`
- Build script: `scripts/compile_shaders.sh`
- QML integration: `Bar/Bar.qml`

### Build the shaders

1) Get tools: `nix shell nixpkgs#qt6.qtshadertools`  
2) From `~/.config/quickshell` run:  
   ```bash
   nix shell nixpkgs#qt6.qtshadertools -c bash -lc 'scripts/compile_shaders.sh'
   ```

Notes:

- Qt 6 requires `.qsb`; raw `.frag` files aren’t accepted by `ShaderEffect` anymore.
- The script compiles all `*.frag` → `*.frag.qsb` targeting GLSL `100es,120,150`.

### wedge_clip.frag parameters

`qt_ubuf` contains three `vec4` parameter blocks:

- `params0`: `x` wedge width normalized (0..1), `y` slopeUp (1 = bottom→top, 0 = top→bottom), `z` side (`+1` right edge, `-1` left edge), `w` unused.
- `params1`: `x` feather amount (soft edge) in [0..~0.25], `yzw` unused.
- `params2`: debug — `x` overlay opacity inside the wedge, `y` force-paint whole rect with magenta (to verify the ShaderEffect is visible).

`sourceSampler` is the input (bar face or tint) that the shader clips.

### Runtime toggles (env)

- `QS_ENABLE_WEDGE_CLIP=1` — enable the shader path.
- `QS_WEDGE_WIDTH_PCT=NN` — wedge width in percent (0..100). Defaults to a value derived from `seamPanel.seamWidthPx`.
- `QS_WEDGE_DEBUG=1` — enables visual debug overlays (Canvas wedges + shader magenta overlay).
- `QS_WEDGE_SHADER_TEST=1` — shader paints magenta across the whole rect (visibility check).
- `QS_WEDGE_TINT_TEST=1` — adds full-surface semi‑transparent rectangles over the bars to confirm window visibility.

Slope direction can be changed in settings: `debugTriangleLeftSlopeUp`, `debugTriangleRightSlopeUp`.

### QML integration (short)

- In `Bar/Bar.qml`, left/right faces use a `Loader` with a `ShaderEffect` whose `fragmentShader` points to `../shaders/wedge_clip.frag.qsb`.
- The shader samples a `ShaderEffectSource` of the bar face (or tint) and subtracts a triangle near the inner edge.
- When the shader is active, legacy `OpacityMask` fallbacks are hidden to avoid overpainting.
- In debug mode (`QS_WEDGE_DEBUG=1`) bars are temporarily placed on `WlrLayer.Overlay` to rule out compositor stacking issues.

### Troubleshooting “wedge not visible”

1) Verify build: no “Failed to find shader … .qsb” warnings in logs.  
2) Run a hard visibility test:  
   ```bash
   QS_ENABLE_WEDGE_CLIP=1 QS_WEDGE_DEBUG=1 QS_WEDGE_SHADER_TEST=1 qs
   ```
   You should see magenta over the effect area. If not, it’s a stacking/visibility issue (not the shader).
3) Confirm the bar windows are visible at all:  
   ```bash
   QS_ENABLE_WEDGE_CLIP=1 QS_WEDGE_DEBUG=1 QS_WEDGE_TINT_TEST=1 qs
   ```
4) If ShaderEffect is visible but the wedge is not obvious, increase width: `QS_WEDGE_WIDTH_PCT=60` (or 80) and flip slope flags in settings if needed.

### Notes / limitations

- After validation, prefer the shader-only path and remove the legacy Canvas/OpacityMask fallbacks.
- Performance: ShaderEffect/ShaderEffectSource are live and recursive; keep verbose debug disabled outside troubleshooting.

