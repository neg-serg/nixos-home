{pkgs, ...}: {
  imports = [
    # ./firefox.nix
    ./floorp.nix
  ];
  home.packages = with pkgs; [
    passff-host # host app for the WebExtension PassFF
    tor-browser # browse web via tor
    tridactyl-native # native package for nix
    chromium # test
  ];
}
