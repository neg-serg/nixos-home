{pkgs, ...}: {
  imports = [
      ./floorp.nix
      ./schizofox.nix
  ];
  home.packages = with pkgs; [
    passff-host # host app for the WebExtension PassFF
    tor-browser
    tor
    torsocks # tor stuff
    tridactyl-native # native package for nix
  ];
}
