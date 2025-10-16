{ lib, config, pkgs, xdg, ... }:
lib.mkIf (config.features.gui.enable or false) (lib.mkMerge [
  # Link entire wezterm config dir under XDG config
  (xdg.mkXdgSource "wezterm" {
    source = config.lib.file.mkOutOfStoreSymlink "${config.neg.dotfilesRoot}/nix/.config/home-manager/modules/user/gui/wezterm/conf";
    recursive = true;
  })
  # Optionally install wezterm; enable if you want package via HM
  # { programs.wezterm.enable = true; }
])
