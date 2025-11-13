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

