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
  {
    home.activation.cleanKittyPanel =
      lib.hm.dag.entryBefore ["linkGeneration"] ''
        set -eu
        target="$HOME/.local/bin/kitty-panel"
        if [ -e "$target" ] && [ ! -L "$target" ]; then
          rm -f "$target"
        fi
      '';
    home.file.".local/bin/kitty-panel" = {
      executable = true;
      text = builtins.readFile ./kitty/panel;
    };
  }
  # Live-editable config via helper (guards parent dir and target)
  (xdg.mkXdgSource "kitty" {
    source = config.lib.file.mkOutOfStoreSymlink "${config.neg.dotfilesRoot}/nix/.config/home-manager/modules/user/gui/kitty/conf";
    recursive = true;
  })
])
