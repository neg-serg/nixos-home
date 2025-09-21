{ lib, config, xdg, ... }:
lib.mkIf (config.features.gui.enable or false) (lib.mkMerge [
  # Live-editable config via helper (guards parent dir and target)
  (xdg.mkXdgSource "kitty" {
    source = config.lib.file.mkOutOfStoreSymlink "${config.neg.dotfilesRoot}/nix/.config/home-manager/modules/user/gui/kitty/conf";
    recursive = true;
  })
  # Soft migration note: kitty config is managed under $XDG_CONFIG_HOME/kitty
  # If you previously used ~/.kitty.conf or ad-hoc files outside this directory,
  # migrate them into ~/.config/kitty/kitty.conf (or this module's conf dir).
  {
    warnings = [
      "Kitty config is under $XDG_CONFIG_HOME/kitty. If ~/.kitty.conf or stray configs exist elsewhere, migrate them into ~/.config/kitty."
    ];
  }
])
