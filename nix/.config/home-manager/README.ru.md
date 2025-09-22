# Конфигурация Home Manager

Этот репозиторий содержит конфигурацию Home Manager (flakes) для пользовательской среды. Включает модульную настройку GUI (Hyprland), CLI‑инструментов, мультимедиа, почты, секретов и др.

- Гайд для агента (как работать в репо): см. `AGENTS.md`
- Правила код‑стайла для Nix‑модулей: `STYLE.md`
- Флаги и опции: `modules/features.nix` (с проверкой совместимости hy3/Hyprland)

## Быстрые задачи (нужен `just`)

- Форматирование: `just fmt`
- Проверки: `just check`
- Только линт: `just lint`
- Переключить HM: `just hm-neg` или `just hm-lite`

## Заметки

- Автоперезагрузка Hyprland отключена; перезагружайте вручную хоткеем.
- Quickshell Settings.json игнорируется и не должен добавляться в репозиторий.
- Конфиг Hyprland разбит по `modules/user/gui/hypr/conf`:
  - `bindings/*.conf`: apps, media, notify, resize, tiling, tiling-helpers, wallpaper, misc
  - `init.conf`, `rules.conf`, `workspaces.conf`, `autostart.conf`
  - Файлы линкованы в `~/.config/hypr` через Home Manager.
- Rofi: враппер `~/.local/bin/rofi` обеспечивает поиск темы (относительно конфига и в XDG data).
  - Темы находятся в `~/.config/rofi` и `~/.local/share/rofi/themes`; Mod4+c использует тему clip.
  - Линки тем генерируются из компактного списка (без ручных дублей в модуле).

## Быстрый старт

- Требования
  - Nix с включёнными flakes (`nix --version` должен работать; в конфиге Nix выставьте `experimental-features = nix-command flakes`).
  - Home Manager доступен (через flakes).
  - Опционально: `just` для удобных команд.

- Клонирование и переключение
  - Клонируйте в путь ваших dotfiles (по умолчанию `~/.dotfiles`):
    - `git clone git@github.com:neg-serg/nixos-home.git ~/.dotfiles`
  - Переключитесь на основной профиль:
    - `home-manager switch --flake ~/.dotfiles/nix/.config/home-manager#neg`
  - Минимальный профиль “lite”:
    - `home-manager switch --flake ~/.dotfiles/nix/.config/home-manager#neg-lite`

- Профили и фичи
  - Профиль задаётся опцией `features.profile` (`full` по умолчанию, `lite` для headless/minimal).
  - Включайте/выключайте стеки в `home.nix` через `features.*` (например, `features.gui.enable`, `features.mail.vdirsyncer.enable`).
  - Стек GPG включается `features.gpg.enable`.
  - Предпочтения Mozilla: `features.web.prefs.fastfox.enable` — быстрые твики (включено в full, выключено в lite).
  - Браузер по умолчанию: `features.web.default` = `floorp | firefox | librewolf | nyxt | yandex`.
    - Выбранный браузер доступен как `config.lib.neg.web.defaultBrowser`.
    - Полная таблица — `config.lib.neg.web.browsers`.

- Секреты (sops-nix)
  - Секреты лежат в `secrets/` и подключаются через sops-nix из `home.nix` и модулей.
  - Убедитесь, что ключ `age` доступен, затем расшифровка произойдёт при активации. См. `secrets/` и `.sops.yaml`.

## Команды

- Форматирование: `just fmt`
- Проверки: `just check`
- Только линт: `just lint`
- Переключить HM: `just hm-neg` или `just hm-lite`

## Полезно знать

- Перезагрузка Hyprland — только вручную (см. hotkey в `modules/user/gui/hypr/conf/bindings.conf`).
- Юниты systemd (user) используют пресеты через `lib.neg.systemdUser.mkUnitFromPresets`.
- См. `AGENTS.md` для API‑хелперов и соглашений; `STYLE.md` — для стиля и коммит‑месседжей.

## Просмотрщики и лаунчеры

- Просмотр изображений
  - Враппер `swayimg-first` ставится как `~/.local/bin/swayimg` и `~/.local/bin/sx`.
    - `sx` вызывает `swayimg-first` для удобства.
    - В Hypr заданы правила для `swayimg` (float/size/position) и роутинг воркспейсов.
  - Легаси‑враппер `sxivnc` пробует `nsxiv → sxiv → swayimg` и оставлен для старых скриптов.

- Лаунчер Rofi
  - `~/.local/bin/rofi` гарантирует, что `-theme <name|name.rasi>` находит тему (относительно конфига или в XDG data).
  - `clip.rasi`, `sxiv.rasi` и требуемые `win/*.rasi` линкуются в `$XDG_DATA_HOME/rofi/themes` для использования через `-theme`.
  - Для emoji‑пикера можно добавить свой `~/.local/bin/rofi-emoji`.

- Браузеры Mozilla
  - Firefox, LibreWolf и Floorp настраиваются через единый конструктор `mkBrowser` в `modules/user/web/mozilla-common-lib.nix`.
  - Каждый модуль вызывает `common.mkBrowser { name, package, profileId ? "default"; }` и может расширять конфиг.
  - Используйте `settingsExtra`, `addonsExtra`, `policiesExtra`, `nativeMessagingExtra`, `profileExtra` для переопределений.

## Заметки для разработчиков

- Сабжекты коммитов должны начинаться со скоупа `[scope]` (принуждается хуком `.githooks/commit-msg`).
  - Включить хуки: `just hooks-enable` или `git config core.hooksPath .githooks`
