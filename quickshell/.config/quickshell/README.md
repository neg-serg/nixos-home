# Quickshell Config (User Setup)

Quick links
- Docs/SHADERS.md — shader wedge clipping, build/debug, troubleshooting (RU/EN)
- Docs/PANELS.md — panel background transparency settings (RU/EN)
- scripts/compile_shaders.sh — builds `.frag` → `.qsb` (Qt 6 Shader Tools)

Wedge Shader Quick Checklist
- Build: `nix shell nixpkgs#qt6.qtshadertools -c bash -lc 'scripts/compile_shaders.sh'`
- Test visibility: `QS_ENABLE_WEDGE_CLIP=1 QS_WEDGE_DEBUG=1 QS_WEDGE_SHADER_TEST=1 qs`
- If no magenta: ensure `.qsb` files exist, debug puts bars on `WlrLayer.Overlay`; enable `debugLogs` in `Settings.json`
- If wedge not obvious: `QS_WEDGE_WIDTH_PCT=60` and flip slope flags (`debugTriangle*SlopeUp`)
- Ensure `ShaderEffectSource.hideSource` is bound to clip `Loader.active`; temporarily raise clip `z` (e.g. 50)
- Panel transparency influences wedge appearance — see Docs/PANELS.md

Notes
- Qt 6 `ShaderEffect` requires precompiled `.qsb` files (use `qsb --glsl "100es,120,150"`).
- Run the shader build script from this directory (`~/.config/quickshell`).

Migration Log
- 2025-11: Decorative separators were removed across the bar, menus, and docs. Delete any local overrides such as `mediaTitleSeparator`, `panel.menu.separatorHeight`, `panel.sepOvershoot`, and every `ui.separator.*` token in custom `Settings.json`/`Theme.json`. Use spacing/padding only; rebuild shaders after updating themes.
