{
  lib,
  config,
  ...
}:
with lib;
  # Enable Vicinae when GUI is on. Keep config minimal per repo conventions.
  mkIf config.features.gui.enable {
    programs.vicinae.enable = true;
  }

