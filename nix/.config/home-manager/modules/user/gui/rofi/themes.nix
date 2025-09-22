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
    # no extra activation/cleanup needed anymore
  in lib.mkMerge (
    map (e: xdg.mkXdgDataSource e.dst {
      source = config.lib.file.mkOutOfStoreSymlink "${config.neg.dotfilesRoot}/nix/.config/home-manager/modules/user/gui/rofi/${e.src}";
      recursive = false;
    }) themeLinks
  )
)
