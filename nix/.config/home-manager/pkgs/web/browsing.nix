{pkgs, ...}: {
  imports = [
      ./floorp.nix
  ];
  home.packages = with pkgs; [
    passff-host # host app for the WebExtension PassFF
    tor-browser # browse web via tor
    torsocks # tor stuff
    tridactyl-native # native package for nix
  ];
}
