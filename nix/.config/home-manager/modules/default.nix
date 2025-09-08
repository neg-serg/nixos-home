{ lib, config, ... }:
with lib;
let
  cfg = config.features;
in {
  options.features = {
    profile = mkOption {
      type = types.enum [ "full" "lite" ];
      default = "full";
      description = "Profile preset that adjusts feature defaults: full or lite.";
    };
    gui = mkEnableOption "enable GUI stack (wayland/hyprland, quickshell, etc.)" // { default = true; };
    mail = mkEnableOption "enable Mail stack (notmuch, isync, vdirsyncer, etc.)" // { default = true; };
    hack = mkEnableOption "enable Hack/security tooling stack" // { default = true; };
    dev = {
      enable = mkEnableOption "enable Dev stack (toolchains, editors, hack tooling)" // { default = true; };
    };
  };

  imports = [
    ./cli
    ./db
    ./dev
    ./distros
    ./flatpak
    ./hardware
    ./main
    ./media
    ./misc
    ./secrets
    ./text
    ./user
  ];

  # Apply profile defaults. Users can still override flags after this.
  config = mkIf (cfg.profile == "lite") {
    features.gui = mkDefault false;
    features.mail = mkDefault false;
    features.hack = mkDefault false;
    features.dev.enable = mkDefault false;
  };
}
