{ lib, config, xdg, ... }:
with lib;
mkIf config.features.gui.enable (
  let
    themeFiles = [
      "theme.rasi"
      "common.rasi"
      "clip.rasi"
      "sxiv.rasi"
      "win/left_btm.rasi"
    ];
    themeLinks = map (rel: { dst = "rofi/themes/${rel}"; src = "conf/${rel}"; }) themeFiles;
    xdgDataHome = config.xdg.dataHome or ("${config.home.homeDirectory}/.local/share");
    xdgConfigHome = config.xdg.configHome or ("${config.home.homeDirectory}/.config");
  in lib.mkMerge (
    (map (e: xdg.mkXdgDataSource e.dst {
      source = config.lib.file.mkOutOfStoreSymlink "${config.neg.dotfilesRoot}/nix/.config/home-manager/modules/user/gui/rofi/${e.src}";
      recursive = false;
    }) themeLinks)
    ++ [{
      home.activation.cleanupRofiLeftovers =
        let ch = xdgConfigHome; d = xdgDataHome; in
        config.lib.neg.mkEnsureAbsentMany [
          "${d}/rofi/themes/win/center_btm.rasi"
          "${d}/rofi/themes/win/no_gap.rasi"
          "${d}/rofi/themes/neg.rasi"
          "${d}/rofi/themes/pass.rasi"
          "${ch}/rofimoji"
          "${d}/applications/rofimoji.desktop"
        ];
    }]
  )
)

