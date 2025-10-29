{
  lib,
  config,
  ...
}: let
  xdg = import ../../../lib/xdg-helpers.nix {inherit lib;};
in
  # Live-editable config via helper (guards parent dir and target)
  xdg.mkXdgSource "nvim" {
    source = config.lib.file.mkOutOfStoreSymlink "${config.neg.dotfilesRoot}/nvim/.config/nvim";
    recursive = true;
  }
