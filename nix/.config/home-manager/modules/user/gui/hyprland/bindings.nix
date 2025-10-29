{
  lib,
  config,
  xdg,
  ...
}:
with lib; let
  bindingFiles = [
    "resize.conf"
    "apps.conf"
    "special.conf"
    "wallpaper.conf"
    "tiling.conf"
    "tiling-helpers.conf"
    "media.conf"
    "notify.conf"
    "misc.conf"
    "_resets.conf"
  ];
  mkHyprSource = rel:
    xdg.mkXdgSource ("hypr/" + rel) {
      source = config.lib.file.mkOutOfStoreSymlink "${config.neg.dotfilesRoot}/nix/.config/home-manager/modules/user/gui/hypr/conf/${rel}";
      recursive = false;
    };
in
  mkIf config.features.gui.enable (
    lib.mkMerge (map (f: mkHyprSource ("bindings/" + f)) bindingFiles)
  )
