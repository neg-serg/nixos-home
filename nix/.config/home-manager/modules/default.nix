{ lib, config, ... }:
with lib; {
  options.features = {
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
}
