# Консолидация для общего отчёта

Цель — собрать все точки управления и шаги, чтобы быстро воспроизвести текущее состояние (Nix/Home Manager + Quickshell), сделать скриншоты и сформировать общий отчёт.

## Что включено

- Emacs через emacs-overlay: `emacs30-pgtk` с native-comp и доп. tree-sitter (в т.ч. QML).
  - Переключатель: `features.dev.emacs.enable` (по умолчанию включено, если не меняли).
- Cantata (MPD-клиент, Qt6, с патчами скриптов плейлистов и зависимостями Wayland/gstreamer).
  - Автозапуск: `media.audio.mpd.cantata.autostart = false` (чтобы не мешало).
- Trader Workstation (IBKR TWS) как нативный пакет (отключено по умолчанию).
  - Переключатель: `features.finance.tws.enable = false` (включать при необходимости).
- Quickshell (панель): диагональные разделители/«шов», отладочные треугольники, акцент из темы.
  - Треугольники берут цвет из темы (`Theme.accentPrimary`) и прозрачность от `seamOpacity` панели.
  - Предупреждения Wayland/QQuickItem устранены — координаты считаются в локальном пространстве QML.

## Точки управления (настройки)

Файл: `~/.config/quickshell/Settings.json` (автоматически создаётся/обновляется). Ключи:

- `debugLogs`: печать маловажных debug‑логов (false).
- `debugSeamFullWidth`: голубой debug‑оверлей на всю ширину панели (true по умолчанию).
- `debugTriangleLeft` / `debugTriangleRight`: показывать левый/правый треугольник (true/true).
- `debugTriangleLeftSlopeUp` / `debugTriangleRightSlopeUp`: направление диагонали
  - true: снизу‑слева → вверх‑вправо
  - false: сверху‑слева → вниз‑вправо

Токены темы: `~/.config/quickshell/Theme.json` (читаются через `Settings/Theme.qml`).
- Цвет акцента: `colors.accent.primary` (например, `#006FCC`).

## Команды сборки/применения

- Home Manager: `home-manager switch --flake ~/.dotfiles/nix/.config/home-manager#<user>`
- Перезапуск панели: `qs` (или перезапуск сервиса, если обёрнуто в systemd user).
- Скриншоты (Wayland): `grim /tmp/screen.png`

## Скриншоты для отчёта

1) Включить нужные оверлеи/треугольники через `Settings.json`.
2) Перезапустить `qs` (панель перечитает конфиг).
3) Снять скриншот: `grim /tmp/quickshell_report.png`.

## Стиль коммитов

- Формат: `[scope] Императивное краткое описание`
  - Примеры: 
    - `[gui/quickshell] Make seam triangles translucent (use seamOpacity)`
    - `[docs] Add consolidated report assembly guide`

## Частые вопросы

- «Что будет при 100% прозрачности?» — Если opacity=0, элемент не виден, но остаётся в иерархии и не влияет на раскладку. Треугольники — `Canvas` без `MouseArea`, поэтому клики не перехватываются. Для полного отключения лучше поставить `debugTriangleLeft/Right = false`.

## TODO для отчёта

- Перенос Firefox‑модуля с профилями/XPI и shared `userChrome.css` (не трогая текущий профиль).
- MSI/ASUS control center: сверить потребности и оформить модуль под ASUS (отключён по умолчанию).
- Финальная проверка `home-manager build` в чистой среде и фиксация известных предупреждений.

