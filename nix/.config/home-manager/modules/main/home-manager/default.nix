{
  lib,
  config,
  ...
}: let
  xdg = import ../../lib/xdg-helpers.nix { inherit lib; };
in {
  programs.home-manager.enable = true; # Let Home Manager install and manage itself.
}
