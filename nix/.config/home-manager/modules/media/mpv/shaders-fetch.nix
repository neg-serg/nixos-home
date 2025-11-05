{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  xdgShaders = ''${config.xdg.configHome}/mpv/shaders'';
  cfg = config.features.media.aiUpscale or {};
  want = (cfg.enable or false) && (cfg.installShaders or true);
  fetchScript = pkgs.writeShellScript "install-mpv-shaders" ''
    set -euo pipefail
    dir="${config.xdg.configHome}/mpv/shaders"
    mkdir -p "$dir"
    fetch() {
      url="$1"; out="$2"
      if [ -s "$dir/$out" ]; then
        exit 0
      fi
      tmp="$dir/$out.tmp$$"
      if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$url" -o "$tmp" || exit 0
      else
        ${pkgs.curl}/bin/curl -fsSL "$url" -o "$tmp" || exit 0
      fi
      mv -f "$tmp" "$dir/$out"
    }
    # Common, well-known shader sources (best-effort)
    fetch "https://raw.githubusercontent.com/bjin/mpv-prescalers/master/FSRCNNX_x2_8-0-4-1.glsl" "FSRCNNX_x2_8-0-4-1.glsl" || true
    fetch "https://raw.githubusercontent.com/bjin/mpv-prescalers/master/KrigBilateral.glsl" "KrigBilateral.glsl" || true
    fetch "https://raw.githubusercontent.com/bloc97/Anime4K/master/glsl/Anime4K_Upscale_CNN_x2_S.glsl" "Anime4K_Upscale_CNN_x2_S.glsl" || true
    # SSimSuperRes: alternate mirrors; try both
    fetch "https://raw.githubusercontent.com/haasn/mpv-conf/master/shaders/SSimSuperRes.glsl" "SSimSuperRes.glsl" || true
    fetch "https://raw.githubusercontent.com/bjin/mpv-prescalers/master/SSimSuperRes.glsl" "SSimSuperRes.glsl" || true
  '';
in
mkIf (config.features.gui.enable or false) (
  mkMerge [
    (mkIf want {
      # Best-effort fetch before linking generation; do not fail activation on errors
      home.activation.installMpvShaders = lib.hm.dag.entryBefore ["linkGeneration"] ''
        set -eu
        ${fetchScript}
      '';
    })
  ])
