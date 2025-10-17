{ lib, config, pkgs, xdg, ... }:
lib.mkIf (config.features.gui.enable or false) (lib.mkMerge [
  {
    home.packages = config.lib.neg.pkgsList [
      pkgs.gum
      pkgs.peaclock
      pkgs.cava
      pkgs.brightnessctl
      pkgs.wirelesstools
    ];
  }
  (let mkLocalBin = import ../../../packages/lib/local-bin.nix { inherit lib; }; in mkLocalBin "kitty-panel" (builtins.readFile ./kitty/panel))
  # Live-editable config via helper (guards parent dir and target)
  (xdg.mkXdgSource "kitty" {
    source = config.lib.file.mkOutOfStoreSymlink "${config.neg.dotfilesRoot}/nix/.config/home-manager/modules/user/gui/kitty/conf";
    recursive = true;
  })
])
