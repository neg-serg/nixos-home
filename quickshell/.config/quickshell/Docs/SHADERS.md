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
5) Убедиться, что источники скрываются: `ShaderEffectSource.hideSource` привязан к активности соответствующего `Loader` (иначе оригинальные прямоугольники поверх/под шейдером скрывают «дырку»).

Скриншот (Wayland): `grim -g "$(slurp)" wedge.png`.

### Ограничения/заметки

- Миграция на чистый шейдер‑путь: после успешной верификации можно удалить старые Canvas/OpacityMask‑fallback.
- Производительность: эффекты работают поверх панелей; все источники идут через `ShaderEffectSource` (live, recursive), что имеет накладные расходы — держать логи включенными только на отладку.

### Что уже поймали (проблемы и решения)

- Ошибка `Failed to find shader … .qsb` — шейдер не собран или путь указан неверно. Решение: запустить сборку из каталога `~/.config/quickshell` или дать полный путь к скрипту. Убедиться, что `fragmentShader: Qt.resolvedUrl("../shaders/<name>.frag.qsb")`.
- Ошибка `qsb: Unknown options: vk, sl` — в вашей версии `qsb` нет флагов Vulkan/Spir-V. Решение: использовать только `--glsl "100es,120,150"`.
- «Ничего не меняется» — клин не виден, хотя `QS_ENABLE_WEDGE_CLIP=1`:
  - Частая причина — базовые прямоугольники панелей (`leftBarFill/rightBarFill`) и/или их тинты всё ещё рисуются под/над шейдером и визуально закрывают «дырку». Нужно отключать исходные слои, когда активен шейдер, и оставлять только шейдерную версию. Аналогично — выключать fallback `OpacityMask` в этом режиме.
  - Убедиться, что `ShaderEffect` действительно отрисовывается: `QS_WEDGE_SHADER_TEST=1` (в этом режиме маджента закрашивает всю область эффекта).
  - Проверить видимость самих окон панелей: `QS_WEDGE_TINT_TEST=1` (полупрозрачная заливка поверх панелей должна быть видна). На время отладки можно поднять слой: `WlrLayer.Overlay`.
- Нулевая высота окна с шейдерами — Seam панель может «схлопнуться» до 0px и шейдеры становятся невидимыми. Решение: дать `implicitHeight` и показывать её после «готовности геометрии».
- Путаемся с рабочим каталогом — вызов `scripts/compile_shaders.sh` вне каталога конфигурации приводит к `No such file or directory`. Решение: запускать из `~/.config/quickshell` или явно `cd ~/.config/quickshell && scripts/compile_shaders.sh`.
- Диагональ не в ту сторону — включены противоположные флаги наклона. Решение: переключить `debugTriangleLeftSlopeUp` / `debugTriangleRightSlopeUp` в `Settings.json`.

### План доработок

1) Спрятать исходные прямоугольники заливки/тинтов, когда активен путь шейдера (оставить только ShaderEffect-версии).  
2) После подтверждения визуального результата удалить Canvas/OpacityMask‑fallback и вернуть слои панелей с Overlay на обычный Top.  
3) Экспонировать ширину клина и наклон через `Settings` (перенести с env при желании).  
4) Подточить производительность: ограничить `ShaderEffectSource` по области, снизить `live/recursive`, если это допустимо.  
5) В документации закрепить «чек‑лист» отладки и добавить примеры команд для скриншотов (Wayland: `grim`, `slurp`).

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
5) Ensure sources are hidden: bind `ShaderEffectSource.hideSource` to the corresponding clip `Loader.active`, otherwise the original rectangles over/under the effect will visually fill the “hole”.

Wayland screenshot: `grim -g "$(slurp)" wedge.png`.

### Notes / limitations

- After validation, prefer the shader-only path and remove the legacy Canvas/OpacityMask fallbacks.
- Performance: ShaderEffect/ShaderEffectSource are live and recursive; keep verbose debug disabled outside troubleshooting.

### Issues we hit (and fixes)

- `Failed to find shader … .qsb` — shader not built or wrong path. Fix: run the build from `~/.config/quickshell` (or use the full path) and ensure `fragmentShader` points to `../shaders/<name>.frag.qsb`.
- `qsb: Unknown options: vk, sl` — your `qsb` doesn’t support Vulkan/Spir-V flags. Fix: use GLSL only `--glsl "100es,120,150"`.
- “Nothing changes” even with `QS_ENABLE_WEDGE_CLIP=1`:
  - Most common: the original bar fill/tint rectangles still render under/over the shader and visually cover the hole. Hide them when the shader path is active and show only the ShaderEffect variants. Also ensure all `OpacityMask` fallbacks are disabled in shader mode.
  - Verify ShaderEffect is actually painting: `QS_WEDGE_SHADER_TEST=1` (magenta over the whole rect).
  - Confirm the bar windows are visible: `QS_WEDGE_TINT_TEST=1`. During debug it can help to place the bars on `WlrLayer.Overlay`.
  - Z-order during debug: raise the clip Loaders (e.g., `z: 50`) so their output is not hidden; avoid seam overlays on top while validating.
  - Logging: enable `Settings.json` → `"debugLogs": true` to get lines like `[bar:left] wedge shader active: true …` and overlay geometry logs.
- Zero-height shader window — the seam window may collapse to 0px; nothing renders. Fix: give it `implicitHeight` and show after geometry readiness.
- Working directory confusion — invoking `scripts/compile_shaders.sh` outside the config dir fails. Fix: run it from `~/.config/quickshell` or `cd` there first.
- Opposite wedge slope — wrong slope flags. Fix: flip `debugTriangleLeftSlopeUp` / `debugTriangleRightSlopeUp` in `Settings.json`.

### Next steps

1) Keep the shader-only path; leave debug/test flags off by default.  
2) Optionally expose wedge width and slope in persistent Settings (not only env).  
3) Improve performance: reduce `ShaderEffectSource` region to the wedge strip; review `live/recursive`.  
4) Polish visuals: tune `feather` using theme radius/scale; keep left/right in sync.  
5) Add a small Settings toggle to reset width/slope env overrides.  
6) Keep `scripts/compile_shaders.sh` documented as the canonical rebuild step.
