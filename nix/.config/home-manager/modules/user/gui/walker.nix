{ lib, pkgs, config, ... }:
with lib; mkIf config.features.gui {
  home.packages = [ pkgs.walker ];
}
