{ config, lib, ... }:
with lib; {
  imports =
    [
      ./files/bin.nix
      ./files/nixpkgs-config.nix
      ./envs
      ./fonts
      ./systemd
      ./terminal
      ./theme
      ./xdg
    ]
    ++ lib.optionals (config.features.gui.enable or false) [
      ./gui
      ./im
      ./x11
    ]
    ++ lib.optionals (config.features.mail.enable or false) [
      ./mail
    ]
    ++ lib.optionals (config.features.torrent.enable or false) [
      ./torrent
    ]
    ++ lib.optionals (config.features.web.enable or false) [
      ./web
    ]
    ++ lib.optionals (config.features.fun.enable or false) [
      ./fun
      ./games
    ];
}
