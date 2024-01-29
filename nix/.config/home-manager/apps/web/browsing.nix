{ config, pkgs, ... }: {
  imports = [ ./floorp.nix ];
  home.packages = with pkgs; [
      passff-host # host app for the WebExtension PassFF
      proxychains-ng # autoproxy
      tor torsocks # tor stuff
      tridactyl-native # native package for nix
  ];
}
