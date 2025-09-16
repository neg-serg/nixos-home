# Руководство для агента (репозиторий Home Manager)

Этот репозиторий настроен под Home Manager + flakes и содержит небольшой набор хелперов, чтобы держать модули согласованными, а активацию — тихой. Здесь описано, чем пользоваться и как валидировать изменения.

## Хелперы и соглашения

- Размещение
  - Базовые хелперы: `modules/lib/neg.nix`
  - XDG‑хелперы для файлов: `modules/lib/xdg-helpers.nix`
  - Флаги/опции: `modules/features.nix`
- XDG‑хелперы (предпочтительно)
  - Текст/ссылки в конфиге: `xdg.mkXdgText`, `xdg.mkXdgSource`
  - Текст/ссылки в data: `xdg.mkXdgDataText`, `xdg.mkXdgDataSource`
  - Текст/ссылки в cache: `xdg.mkXdgCacheText`, `xdg.mkXdgCacheSource`
  - Используйте их вместо ad‑hoc shell, чтобы избежать конфликтов симлинков/директорий во время активации.
- Активационные хелперы (из `lib.neg`)
  - `mkEnsureRealDir path` / `mkEnsureRealDirsMany [..]` — гарантируют реальные директории до `linkGeneration`
  - `mkEnsureAbsent path` / `mkEnsureAbsentMany [..]` — удаляют конфликтующие файлы/каталоги до `linkGeneration`
  - `mkEnsureDirsAfterWrite [..]` — создают runtime‑директории после `writeBoundary`
  - `mkEnsureMaildirs base [boxes..]` — создают Maildir‑деревья после `writeBoundary`
  - Сводные XDG‑фиксы:
    - `mkXdgFixParents { configs = attrNames config.xdg.configFile; datas = attrNames config.xdg.dataFile; caches = attrNames config.xdg.cacheFile; /* опционально */ preserveConfigPatterns = [ "some-app/*" ]; }`
      - По умолчанию `preserveConfigPatterns = []`. Передавайте паттерны из конкретного модуля, если нужно сохранить родителя‑симлинк для части дерева (например, внешнее управление поддеревом конфигурации приложения).
    - `mkXdgFixTargets { configs = …; datas = …; caches = …; }`
    - Эти фиксы подключены в `modules/user/xdg/default.nix` как `home.activation.xdgFixParents` и `home.activation.xdgFixTargets`.
  - Общие пользовательские пути готовятся через:
    - `ensureCommonDirs`, `cleanSwayimgWrapper`, `ensureGmailMaildirs`
- Предустановки systemd (user)
  - Всегда используйте `config.lib.neg.systemdUser.mkUnitFromPresets { presets = [..]; }`
  - Типичные пресеты:
    - Сервис в GUI‑сессии: `["graphical"]`
    - Требуется сеть online: `["netOnline"]`
    - Обычный пользовательский сервис: `["defaultWanted"]`
    - Таймер: `["timers"]`
    - Порядок для DBus‑сокета: `["dbusSocket"]`
  - Добавляйте `after`/`wants`/`partOf`/`wantedBy` только при необходимости.

## Заметки по Hyprland

- Автоперезагрузка отключена, чтобы избежать гонок inotify во время активации (`disable_autoreload = 1`).
- Нет `hyprctl reload` при активации; только ручная перезагрузка (hotkey в `bindings.conf`).
- Пины hy3/Hyprland проверяются на совместимость в `features.nix`; при обновлении — расширяйте матрицу.

## Сообщения коммитов

- Формат: `[scope] subject` (английский, повелительное наклонение).
  - Примеры: `[activation] reduce noise`, `[features] add flag`, `[gui/hypr] normalize rules`.
  - Допускается несколько скоупов: `[xdg][activation] ...`
  - Исключения: `Merge ...`, `Revert ...`, `fixup!`, `squash!`, `WIP`.
- Держите изменения узкими и сфокусированными; без случайных «попутных» правок.

## Быстрые задачи

- Форматирование: `just fmt` (обёртка над `nix fmt`)
- Проверки: `just check` (flake‑чеки, сборка доков)
- Только линт: `just lint` (statix, deadnix, shellcheck, ruff/black при наличии)
- Переключить HM: `just hm-neg` (или `just hm-lite`)

## Ограждения

- Не возвращайте автоперезагрузку Hyprland и reload‑хуки в активации.
- Для файлов под `~/.config` используйте XDG‑хелперы + `mkDotfilesSymlink` вместо ручного shell.
- Используйте флаги‑фичи (`features.*`) с `mkIf`; если родитель выключен, дети по умолчанию выключены.
- Quickshell: `quickshell/.config/quickshell/Settings.json` в `.gitignore`; не добавляйте обратно.

## Валидация

- Локальная проверка: `nix flake check -L` (может собрать небольшие доки/чеки)
- Быстрый просмотр фич (без сборки): соберите `checks.x86_64-linux.hm-eval-neg-retro-off` и посмотрите JSON
- Переключение HM (вживую): `home-manager switch --flake .#neg`

## Обновление hy3/Hyprland

- Обновите пины в `flake.nix` и расширьте матрицу в `modules/features.nix`:
  - Добавьте `{ hv = "<версия hyprland>"; rev = "<коммит hy3>"; }` в `compatible`.
  - Держите Hyprland и hy3 в одной связке, чтобы избежать API‑несовместимости.

